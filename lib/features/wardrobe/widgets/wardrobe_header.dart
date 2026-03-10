import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class WardrobeHeader extends StatelessWidget {
  const WardrobeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          const Text(
            'My Digital Wardrobe',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.search,
                size: 20,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                // Future search implementation
              },
            ),
          ),
        ],
      ),
    );
  }
}
