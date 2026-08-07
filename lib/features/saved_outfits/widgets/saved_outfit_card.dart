import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';

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
                  child: _buildCollage(imageUrls, outfitData),
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

  Widget _buildCollage(List<String> urls, Map<String, dynamic> outfitData) {
    if (urls.isEmpty) {
      // Fallback to style-based online image
      final style =
          outfitData['stylePreference'] as String? ??
          outfitData['occasion'] as String? ??
          '';
      return _buildNetworkImage(_styleImage(style));
    }

    if (urls.length == 1) {
      return _buildNetworkImage(urls[0]);
    }

    if (urls.length == 2) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildNetworkImage(urls[0])),
          const SizedBox(width: 2),
          Expanded(child: _buildNetworkImage(urls[1])),
        ],
      );
    }

    // 3+
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildNetworkImage(urls[0])),
        const SizedBox(width: 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildNetworkImage(urls[1])),
              const SizedBox(height: 2),
              Expanded(
                child: _buildNetworkImage(urls.length > 2 ? urls[2] : urls[1]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: AppColors.primary.withValues(alpha: 0.1),
        child: const Icon(Icons.checkroom, size: 32, color: AppColors.primary),
      ),
    );
  }

  String _styleImage(String style) {
    final s = style.toLowerCase();
    if (s.contains('formal') ||
        s.contains('business') ||
        s.contains('elegant')) {
      return 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=400&fit=crop';
    }
    if (s.contains('street') || s.contains('urban')) {
      return 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400&fit=crop';
    }
    if (s.contains('casual')) {
      return 'https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?w=400&fit=crop';
    }
    return 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=400&fit=crop';
  }
}
