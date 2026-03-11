import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'saved_outfit_card.dart';
import '../models/saved_outfit_model.dart';

class SavedOutfitsSection extends StatelessWidget {
  const SavedOutfitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Saved Outfits',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: mockSavedOutfits.map((outfit) {
              return SavedOutfitCard(
                imageUrl: outfit.imageUrl,
                title: outfit.title,
                savedTime: outfit.savedTime,
                onTap: () {},
                onFavoriteTap: () {},
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
