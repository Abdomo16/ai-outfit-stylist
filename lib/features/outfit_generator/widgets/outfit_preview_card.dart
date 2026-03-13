import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/outfit_model.dart';

class OutfitPreviewCard extends StatelessWidget {
  final OutfitModel outfit;

  const OutfitPreviewCard({super.key, required this.outfit});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //  static online photo until AI generation is live
          SizedBox(
            height: 350,
            width: double.infinity,
            child: Image.network(
              _onlineImageForStyle(outfit.stylePreference),
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: const Color(0xFFF5F5F5),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                          : null,
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFF5F5F5),
                child: Center(
                  child: Icon(
                    Icons.checkroom,
                    size: 80,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
          // Details Bottom Area
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  outfit.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _buildOutfitDescription(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildOutfitDescription() {
    final items = <String>[];
    if (outfit.top != null) items.add(outfit.top!.name);
    if (outfit.bottom != null) items.add(outfit.bottom!.name);
    if (outfit.shoes != null) items.add(outfit.shoes!.name);
    if (outfit.accessories != null) items.add(outfit.accessories!.name);

    if (outfit.accessories == null && items.isNotEmpty) {
      items.add('Silver Watch');
    }

    return items.join(' • ');
  }

  /// Maps the chosen style to a curated online outfit photo.
  /// Replace with real AI-generated URLs once the backend is ready.
  String _onlineImageForStyle(String style) {
    final s = style.toLowerCase();
    if (s.contains('elegant') ||
        s.contains('formal') ||
        s.contains('business')) {
      return 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800&fit=crop';
    }
    if (s.contains('street') || s.contains('urban')) {
      return 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800&fit=crop';
    }
    if (s.contains('vintage') || s.contains('retro') || s.contains('classic')) {
      return 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=800&fit=crop';
    }
    if (s.contains('casual')) {
      return 'https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?w=800&fit=crop';
    }
    // default — minimalist / everything else
    return 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800&fit=crop';
  }
}
