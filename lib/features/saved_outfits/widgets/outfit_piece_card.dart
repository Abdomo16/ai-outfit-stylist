import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class OutfitPieceCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const OutfitPieceCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final imageUrl = (item['imageUrl'] ?? item['image_path']) as String?;
    final name = (item['name'] ?? item['type'] ?? 'Clothing Item') as String;
    final category = (item['type'] ?? item['category'] ?? 'Unknown') as String;
    final color = (item['color'] ?? '') as String;
    final pattern = (item['pattern'] ?? '') as String;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _imageFallback(category),
                  )
                : _imageFallback(category),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                if (color.isNotEmpty || pattern.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    [if (color.isNotEmpty) color, if (pattern.isNotEmpty) pattern].join(' • '),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback(String category) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.12),
      child: Icon(
        _categoryIcon(category),
        color: AppColors.primary,
        size: 32,
      ),
    );
  }

  IconData _categoryIcon(String category) {
    final c = category.toLowerCase();
    if (c.contains('shirt') || c.contains('top') || c.contains('blouse')) {
      return Icons.checkroom;
    }
    if (c.contains('jacket') || c.contains('coat') || c.contains('hoodie')) {
      return Icons.ice_skating;
    }
    if (c.contains('pant') || c.contains('jean') || c.contains('skirt')) {
      return Icons.airline_seat_individual_suite;
    }
    if (c.contains('shoe') || c.contains('boot') || c.contains('sneaker')) {
      return Icons.directions_walk;
    }
    if (c.contains('hat')) {
      return Icons.emoji_people;
    }
    if (c.contains('bag')) {
      return Icons.shopping_bag;
    }
    return Icons.checkroom;
  }
}