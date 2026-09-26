import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class WardrobeEmptyState extends StatelessWidget {
  final String? category;
  final VoidCallback? onAddPressed;

  const WardrobeEmptyState({
    super.key,
    this.category,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isFiltered = category != null && category != 'All';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surface,
                border: Border.all(color: colors.outline),
              ),
              child: Icon(
                Icons.checkroom_outlined,
                size: 56,
                color: AppColors.primary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isFiltered ? 'No $category items yet' : 'Your wardrobe is empty',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isFiltered
                  ? 'Try selecting another category or add your first $category piece.'
                  : 'Start building your digital wardrobe by adding your favorite pieces.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onAddPressed != null && !isFiltered) ...[
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton.icon(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add),
                label: const Text('Add First Item'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
