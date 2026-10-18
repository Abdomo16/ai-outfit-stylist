import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/wardrobe_taxonomy.dart';
import '../../../../l10n/app_localizations.dart';
import '../utils/wardrobe_labels.dart';

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
    final l10n = AppLocalizations.of(context);
    final isFiltered = category != null && category != WardrobeTaxonomy.all;
    final label = isFiltered ? WardrobeLabels.category(l10n, category!) : '';

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
              isFiltered ? 'No $label items yet' : l10n.emptyWardrobeTitle,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isFiltered
                  ? 'Try selecting another category or add your first $label piece.'
                  : l10n.emptyWardrobeBody,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onAddPressed != null && !isFiltered) ...[
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton.icon(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add),
                label: Text(l10n.addClothes),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
