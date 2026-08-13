import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

String styleImage(String style) {
  final s = style.toLowerCase();
  if (s.contains('formal') || s.contains('business') || s.contains('elegant')) {
    return 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800&fit=crop';
  }
  if (s.contains('street') || s.contains('urban')) {
    return 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800&fit=crop';
  }
  if (s.contains('casual')) {
    return 'https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?w=800&fit=crop';
  }
  return 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800&fit=crop';
}

class OutfitImageCollage extends StatelessWidget {
  final List<String> imageUrls;
  final String fallbackStyle;
  final double errorIconSize;

  const OutfitImageCollage({
    super.key,
    required this.imageUrls,
    this.fallbackStyle = '',
    this.errorIconSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    final urls = imageUrls.where((u) => u.isNotEmpty).toList();
    if (urls.isEmpty) {
      return _buildImage(styleImage(fallbackStyle));
    }
    if (urls.length == 1) {
      return _buildImage(urls[0]);
    }
    if (urls.length == 2) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildImage(urls[0])),
          const SizedBox(width: 2),
          Expanded(child: _buildImage(urls[1])),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildImage(urls[0])),
        const SizedBox(width: 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildImage(urls[1])),
              const SizedBox(height: 2),
              Expanded(
                child: _buildImage(urls.length > 2 ? urls[2] : urls[1]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: AppColors.primary.withValues(alpha: 0.1),
        child: Icon(
          Icons.checkroom,
          size: errorIconSize,
          color: AppColors.primary,
        ),
      ),
    );
  }
}