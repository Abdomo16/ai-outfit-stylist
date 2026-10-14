import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import '../models/clothing_item_model.dart';
import '../models/outfit_model.dart';
import '../../config/env.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class AIService {
  final http.Client _client = http.Client();

  Future<List<ClothingItemModel>> uploadWardrobeImage(
    File imageFile, {
    required String userId,
  }) async {
    final ext = p.extension(imageFile.path).toLowerCase();
    String mimeType = 'jpeg';
    if (ext == '.png') {
      mimeType = 'png';
    } else if (ext == '.webp')
      mimeType = 'webp';
    else if (ext == '.gif')
      mimeType = 'gif';

    // Build a random boundary
    final boundary =
        '----FormBoundary${Random().nextInt(0xFFFFFF).toRadixString(16)}';
    final filename = p.basename(imageFile.path);
    final fileBytes = await imageFile.readAsBytes();

    // Build the multipart body manually
    final bodyBytes = <int>[];
    final header =
        '--$boundary\r\nContent-Disposition: form-data; name="file"; filename="$filename"\r\nContent-Type: image/$mimeType\r\n\r\n';
    bodyBytes.addAll(header.codeUnits);
    bodyBytes.addAll(fileBytes);
    bodyBytes.addAll(
        '\r\n--$boundary\r\nContent-Disposition: form-data; name="user_id"\r\n\r\n$userId\r\n--$boundary--\r\n'
            .codeUnits);

    // Helper to POST to a given URL
    Future<http.Response> doPost(String url) async {
      return await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'multipart/form-data; boundary=$boundary'},
        body: bodyBytes,
      );
    }

    var response = await doPost('${Env.aiBackendUrl}/wardrobe/upload/');

    // Follow 307 manually if needed
    if (response.statusCode == 307 || response.statusCode == 308) {
      final location = response.headers['location'];
      if (location != null) {
        // location may be absolute or relative
        final redirectUrl = location.startsWith('http')
            ? location
            : '${Env.aiBackendUrl}$location';
        response = await doPost(redirectUrl);
      }
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final itemsList = jsonResponse['items'] as List<dynamic>? ?? [];
      return itemsList
          .map(
            (item) => ClothingItemModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw Exception(
        'Failed to upload image. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }

  Future<OutfitModel> getRecommendations({
    required List<ClothingItemModel> wardrobe,
    required String occasion,
    String? style,
    required String weather,
    required String season,
    List<String> lockIds = const [],
    String? swapId,
  }) async {
    final uri = Uri.parse('${Env.aiBackendUrl}/recommend/');

    final payload = <String, dynamic>{
      "wardrobe": wardrobe.map((item) {
        return {
          "id": _encodeId(item.id),
          "type": item.category,
          "confidence": item.confidence ?? 1.0,
          "color": item.color,
          "hex": item.hex ?? '',
          "pattern": item.pattern ?? 'solid',
          "style": item.style,
          "season": item.season ?? 'all',
          "embedding": item.embedding ?? [],
          "image_path": item.imageUrl ?? '',
        };
      }).toList(),
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

    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      // Remap imageUrls: backend may return local server paths.
      // We use the 1-based `id` from the response to look up the correct
      // Supabase-hosted URL from the wardrobe list we sent.
      if (jsonResponse['outfit'] is List) {
        final outfitList = jsonResponse['outfit'] as List<dynamic>;
        for (final rawItem in outfitList) {
          if (rawItem is Map<String, dynamic>) {
            final itemId = rawItem['id']?.toString();
            if (itemId == null) continue;
            ClothingItemModel? wardrobeItem;
            for (final item in wardrobe) {
              if (item.id == itemId) {
                wardrobeItem = item;
                break;
              }
            }
            if (wardrobeItem != null &&
                wardrobeItem.imageUrl != null &&
                wardrobeItem.imageUrl!.startsWith('http')) {
              rawItem['imageUrl'] = wardrobeItem.imageUrl;
              rawItem['image_path'] = wardrobeItem.imageUrl;
            }
          }
        }
      }

      return OutfitModel.fromJson(jsonResponse, stylePreference: style);
    } else {
    throw Exception(
      'Failed to get recommendations. Status: ${response.statusCode}, Body: ${response.body}',
    );
  }
}

Object? _encodeId(String? id) {
  if (id == null || id.isEmpty) return null;
  return int.tryParse(id) ?? id;
}
}
