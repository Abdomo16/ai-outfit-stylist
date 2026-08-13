import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import 'outfit_image_collage.dart';

class SavedOutfitCard extends StatelessWidget {
  final Map<String, dynamic> outfit;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SavedOutfitCard({
    super.key,
    required this.outfit,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final outfitData = outfit['outfit_data'] as Map<String, dynamic>? ?? {};
    final name = outfitData['name'] as String? ?? 'Saved Outfit';
    final occasion = outfitData['occasion'] as String? ?? '';
    final style =
        outfitData['stylePreference'] as String? ??
        outfitData['occasion'] as String? ??
        '';

    // Extract image URLs from items list
    final rawItems = outfitData['items'] as List<dynamic>? ?? [];
    final imageUrls = rawItems
        .map((i) {
          final item = i as Map<String, dynamic>? ?? {};
          return (item['imageUrl'] ?? item['image_path']) as String?;
        })
        .where((url) => url != null && url.isNotEmpty)
        .cast<String>()
        .take(4)
        .toList();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image collage
                SizedBox(
                  height: 140,
                  child: OutfitImageCollage(
                    imageUrls: imageUrls,
                    fallbackStyle: style.isEmpty ? '' : style,
                  ),
                ),
                // Info
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (occasion.isNotEmpty)
                        Text(
                          occasion,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            // Share button
            Positioned(
              top: 0,
              right: 40,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  final text =
                      'Check out this outfit I styled: $name'
                      '${occasion.isNotEmpty ? ' for $occasion' : ''}!';
                  Share.share(text);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
            // Delete button
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
),
    );
  }
}
