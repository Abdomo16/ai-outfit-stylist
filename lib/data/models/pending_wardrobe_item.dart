import 'dart:convert';
import 'dart:typed_data';

/// An item the backend held back because only part of it is in the photo.
/// It joins the wardrobe only if the user keeps it.
class PendingWardrobeItem {
  static const cutOff = 'cut_off';
  static const hidden = 'hidden';

  /// Upload job that holds the item.
  final String jobId;
  final String id;

  /// [cutOff] or [hidden].
  final String reason;
  final String type;
  final String? category;
  final String color;
  final Uint8List? previewBytes;

  const PendingWardrobeItem({
    required this.jobId,
    required this.id,
    required this.reason,
    required this.type,
    this.category,
    required this.color,
    this.previewBytes,
  });

  factory PendingWardrobeItem.fromJson(String jobId, Map<String, dynamic> json) {
    final preview = json['preview_base64'] as String?;
    return PendingWardrobeItem(
      jobId: jobId,
      id: json['id'].toString(),
      reason: (json['reason'] ?? cutOff) as String,
      type: (json['type'] ?? 'Unknown') as String,
      category: json['category'] as String?,
      color: (json['color'] ?? 'Unknown') as String,
      previewBytes: preview == null || preview.isEmpty ? null : base64Decode(preview),
    );
  }
}
