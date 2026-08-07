import 'package:flutter/material.dart';
import 'dart:io';
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
          // Display dynamically generated collage of wardrobe items
          SizedBox(
            height: 350,
            width: double.infinity,
            child: _buildItemsCollage(),
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

    if (items.isEmpty) {
      items.addAll(outfit.items.map((item) => item.name));
    }

    if (items.isNotEmpty) {
      return items.join(' ${String.fromCharCode(0x2022)} ');
    }

    return items.isNotEmpty ? items.join(' • ') : outfit.explanation;
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

  Widget _buildItemsCollage() {
    final itemsWithImage = outfit.items
        .where((item) => item.imageUrl != null && item.imageUrl!.isNotEmpty)
        .toList();

    if (itemsWithImage.isEmpty) {
      if (outfit.imageUrl != null && outfit.imageUrl!.isNotEmpty) {
        return _buildImage(outfit.imageUrl!);
      }
      return _buildImage(_onlineImageForStyle(outfit.stylePreference));
    }

    if (itemsWithImage.length == 1) {
      return _buildImage(itemsWithImage[0].imageUrl!);
    }

    if (itemsWithImage.length == 2) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildImage(itemsWithImage[0].imageUrl!)),
          const SizedBox(width: 2),
          Expanded(child: _buildImage(itemsWithImage[1].imageUrl!)),
        ],
      );
    }

    if (itemsWithImage.length == 3) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildImage(itemsWithImage[0].imageUrl!)),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildImage(itemsWithImage[1].imageUrl!)),
                const SizedBox(height: 2),
                Expanded(child: _buildImage(itemsWithImage[2].imageUrl!)),
              ],
            ),
          ),
        ],
      );
    }

    // 4 or more
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: itemsWithImage.length > 4 ? 4 : itemsWithImage.length,
      itemBuilder: (context, index) {
        return _buildImage(itemsWithImage[index].imageUrl!);
      },
    );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('http')) {
      return Container(
        color: Colors.white,
        child: Image.network(
          url,
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
                size: 40,
                color: Colors.grey.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.white,
        child: Image.file(
          File(url),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFFF5F5F5),
            child: Center(
              child: Icon(
                Icons.checkroom,
                size: 40,
                color: Colors.grey.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      );
    }
  }
}
