import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import '../models/clothing_item_model.dart';
import '../models/outfit_model.dart';
import '../models/pending_wardrobe_item.dart';
import '../../config/env.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class UploadJobStatus {
  final String jobId;
  final String status;
  final List<ClothingItemModel> items;

  /// Partly visible items waiting for the user to keep or skip them.
  final List<PendingWardrobeItem> pending;
  final String? error;

  const UploadJobStatus({
    required this.jobId,
    required this.status,
    this.items = const [],
    this.pending = const [],
    this.error,
  });

  bool get isDone => status == 'done';
  bool get isFailed => status == 'failed';
  bool get isProcessing => status == 'processing';
}

class AIService {
  final http.Client _client = http.Client();

  static const Duration _pollInterval = Duration(milliseconds: 800);
  static const Duration _jobTimeout = Duration(minutes: 3);

  /// Uploads a photo and waits for it. The result holds the saved items and
  /// the partly visible ones still waiting for [keepPendingItems].
  Future<UploadJobStatus> uploadWardrobeImage(
    File imageFile, {
    required String userId,
  }) async {
    final jobId = await startWardrobeUpload(imageFile, userId: userId);
    final result = await waitForUploadJob(jobId);
    if (result.isFailed) {
      throw Exception(result.error ?? 'Upload job failed');
    }
    return result;
  }

  /// Saves the pending items in [ids] and drops the job's other pending
  /// items. An empty list skips them all.
  Future<void> keepPendingItems(
    String jobId,
    List<String> ids,
    String accessToken,
  ) async {
    final response = await _client
        .post(
          Uri.parse('${Env.aiBackendUrl}/wardrobe/jobs/$jobId/keep'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({'ids': ids}),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to keep items. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }

  Future<String> startWardrobeUpload(
    File imageFile, {
    required String userId,
  }) async {
    final ext = p.extension(imageFile.path).toLowerCase();
    String mimeType = 'jpeg';
    if (ext == '.png') {
      mimeType = 'png';
    } else if (ext == '.webp') {
      mimeType = 'webp';
    } else if (ext == '.gif') {
      mimeType = 'gif';
    }

    final boundary =
        '----FormBoundary${Random().nextInt(0xFFFFFF).toRadixString(16)}';
    final filename = p.basename(imageFile.path);
    final fileBytes = await imageFile.readAsBytes();

    final bodyBytes = <int>[];
    final header =
        '--$boundary\r\nContent-Disposition: form-data; name="file"; filename="$filename"\r\nContent-Type: image/$mimeType\r\n\r\n';
    bodyBytes.addAll(header.codeUnits);
    bodyBytes.addAll(fileBytes);
    bodyBytes.addAll(
      '\r\n--$boundary\r\nContent-Disposition: form-data; name="user_id"\r\n\r\n$userId\r\n--$boundary--\r\n'
          .codeUnits,
    );

    Future<http.Response> doPost(String url) async {
      return await _client
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'multipart/form-data; boundary=$boundary',
            },
            body: bodyBytes,
          )
          .timeout(const Duration(seconds: 60));
    }

    var response = await doPost('${Env.aiBackendUrl}/wardrobe/upload/');

    if (response.statusCode == 307 || response.statusCode == 308) {
      final location = response.headers['location'];
      if (location != null) {
        final redirectUrl = location.startsWith('http')
            ? location
            : '${Env.aiBackendUrl}$location';
        response = await doPost(redirectUrl);
      }
    }

    if (response.statusCode == 202 ||
        response.statusCode == 200 ||
        response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final jobId = jsonResponse['job_id'] as String?;
      if (jobId != null && jobId.isNotEmpty) {
        return jobId;
      }
      // Legacy sync response with items already present.
      if (jsonResponse['items'] is List) {
        return '';
      }
    }

    throw Exception(
      'Failed to start upload. Status: ${response.statusCode}, Body: ${response.body}',
    );
  }

  Future<UploadJobStatus> getUploadJobStatus(String jobId) async {
    final response = await _client
        .get(Uri.parse('${Env.aiBackendUrl}/wardrobe/jobs/$jobId'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to get job status. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }

    final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
    final itemsList = jsonResponse['items'] as List<dynamic>? ?? [];
    final pendingList = jsonResponse['pending'] as List<dynamic>? ?? [];
    return UploadJobStatus(
      jobId: jobId,
      status: (jsonResponse['status'] as String?) ?? 'processing',
      items: itemsList
          .map(
            (item) => ClothingItemModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      pending: pendingList
          .map(
            (item) => PendingWardrobeItem.fromJson(
              jobId,
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      error: jsonResponse['error'] as String?,
    );
  }

  Future<UploadJobStatus> waitForUploadJob(String jobId) async {
    if (jobId.isEmpty) {
      return const UploadJobStatus(jobId: '', status: 'done');
    }

    final deadline = DateTime.now().add(_jobTimeout);
    while (DateTime.now().isBefore(deadline)) {
      final status = await getUploadJobStatus(jobId);
      if (status.isDone || status.isFailed) {
        return status;
      }
      await Future<void>.delayed(_pollInterval);
    }
    throw Exception('Upload job timed out');
  }

  /// Deletes the signed-in user's items and their photos. Returns the ids the
  /// backend deleted; ids owned by someone else are ignored.
  Future<List<String>> deleteWardrobeItems(
    List<String> ids,
    String accessToken,
  ) async {
    final response = await _client
        .post(
          Uri.parse('${Env.aiBackendUrl}/wardrobe/items/delete'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({'ids': ids}),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete items. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['deleted'] as List<dynamic>? ?? [])
        .map((id) => id.toString())
        .toList();
  }

  Future<OutfitModel> getRecommendations({
    required List<ClothingItemModel> wardrobe,
    required String occasion,
    String? style,
    required String weather,
    required String season,
    List<String> lockIds = const [],
    String? swapId,
    List<String> excludeIds = const [],
    bool layer = false,
  }) async {
    final uri = Uri.parse('${Env.aiBackendUrl}/recommend/');

    final payload = <String, dynamic>{
      "wardrobe": _wardrobePayload(wardrobe),
      "occasion": occasion,
      "weather": weather,
      "season": season,
    };
    if (style != null) {
      payload["style"] = style;
    }
    if (lockIds.isNotEmpty) {
      payload["lock_ids"] = lockIds.map(_encodeId).toList();
    }
    if (swapId != null) {
      payload["swap_id"] = _encodeId(swapId);
    }
    if (excludeIds.isNotEmpty) {
      payload["exclude_ids"] = excludeIds.map(_encodeId).toList();
    }
    if (layer) {
      // A cool night: the backend picks a look with a jacket if it can.
      payload["layer"] = true;
    }

    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      _fillFromWardrobe(jsonResponse, wardrobe);
      return OutfitModel.fromJson(jsonResponse, stylePreference: style);
    } else {
      throw Exception(
        'Failed to get recommendations. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }

  /// Sends one chat message to the AI stylist. [currentOutfit] is the look
  /// being tweaked, if any.
  Future<ChatResult> chat({
    required String message,
    required List<ChatTurn> history,
    required List<ClothingItemModel> wardrobe,
    OutfitModel? currentOutfit,
    String? weather,
    String? season,
    List<String> excludeIds = const [],
    String? locale,
  }) async {
    final payload = <String, dynamic>{
      "message": message,
      "history": history.map((turn) => turn.toJson()).toList(),
      "wardrobe": _wardrobePayload(wardrobe),
      "occasion": currentOutfit?.occasion,
      "weather": weather,
      "season": season,
      "current_outfit_ids": [
        for (final item in currentOutfit?.items ?? const <ClothingItemModel>[])
          if (item.id != null) _encodeId(item.id),
      ],
      "exclude_ids": excludeIds.map(_encodeId).toList(),
      "locale": locale,
    };

    final response = await _client
        .post(
          Uri.parse('${Env.aiBackendUrl}/chat/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode != 200) {
      throw Exception(
        'Chat failed. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final rawOutfit = body['outfit'];
    OutfitModel? outfit;
    if (rawOutfit is Map<String, dynamic>) {
      _fillFromWardrobe(rawOutfit, wardrobe);
      outfit = OutfitModel.fromJson(rawOutfit);
    }
    return ChatResult(
      reply: (body['reply'] as String?)?.trim() ?? '',
      outfit: outfit,
      usedFallback: body['used_fallback'] == true,
      noMatch: body['no_match'] == true,
    );
  }

  /// Reads the user's usual week from a sentence, e.g. "university Sunday
  /// to Wednesday and gym on Tuesday". Returns the days it understood,
  /// keyed as the app stores a routine, and a short confirmation.
  Future<({Map<String, dynamic> days, String reply})> parseRoutine({
    required String message,
    String? locale,
  }) async {
    final response = await _client
        .post(
          Uri.parse('${Env.aiBackendUrl}/chat/routine'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"message": message, "locale": locale}),
        )
        .timeout(const Duration(seconds: 45));
    if (response.statusCode != 200) {
      throw Exception(
        'Routine failed. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final days = body['days'];
    return (
      days: days is Map<String, dynamic> ? days : <String, dynamic>{},
      reply: (body['reply'] as String?)?.trim() ?? '',
    );
  }

  List<Map<String, dynamic>> _wardrobePayload(
    List<ClothingItemModel> wardrobe,
  ) {
    return wardrobe.map((item) {
      return {
        "id": _encodeId(item.id),
        "type": item.type,
        "category": item.category,
        "confidence": item.confidence ?? 1.0,
        "color": item.color,
        "hex": item.hex ?? '',
        "pattern": item.pattern ?? 'solid',
        "style": item.style,
        "season": item.season ?? 'all',
        "embedding": item.embedding ?? [],
        "image_path": item.imageUrl ?? '',
      };
    }).toList();
  }

  /// Recommend responses carry only labels, so copy each piece's photo and
  /// measured colors from the wardrobe.
  void _fillFromWardrobe(
    Map<String, dynamic> json,
    List<ClothingItemModel> wardrobe,
  ) {
    final outfitList = json['outfit'];
    if (outfitList is! List) return;
    final byId = {for (final item in wardrobe) item.id: item};
    for (final rawItem in outfitList) {
      if (rawItem is! Map<String, dynamic>) continue;
      final wardrobeItem = byId[rawItem['id']?.toString()];
      if (wardrobeItem == null) continue;
      final imageUrl = wardrobeItem.imageUrl;
      if (imageUrl != null && imageUrl.startsWith('http')) {
        rawItem['imageUrl'] = imageUrl;
        rawItem['image_path'] = imageUrl;
      }
      rawItem['cutout_path'] ??= wardrobeItem.cutoutUrl;
      rawItem['hex'] ??= wardrobeItem.hex;
      rawItem['secondary_color'] ??= wardrobeItem.secondaryColor;
      rawItem['secondary_hex'] ??= wardrobeItem.secondaryHex;
    }
  }
}

class ChatTurn {
  final String role;
  final String content;

  const ChatTurn({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class ChatResult {
  final String reply;
  final OutfitModel? outfit;
  final bool usedFallback;

  /// An outfit was wanted but nothing in the wardrobe fits.
  final bool noMatch;

  const ChatResult({
    required this.reply,
    this.outfit,
    this.usedFallback = false,
    this.noMatch = false,
  });
}

Object? _encodeId(String? id) {
  if (id == null || id.isEmpty) return null;
  return int.tryParse(id) ?? id;
}
