import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class WardrobeHeader extends StatelessWidget {
  const WardrobeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
          Text(
            'My Digital Wardrobe',
            style: theme.textTheme.headlineSmall,
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.search,
                size: 20,
                color: colors.onSurfaceVariant,
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
