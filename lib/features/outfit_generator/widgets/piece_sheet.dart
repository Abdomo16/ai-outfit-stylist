import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/wardrobe_colors.dart';
import '../../../../data/models/clothing_item_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../wardrobe/utils/wardrobe_labels.dart';
import '../../wardrobe/widgets/wardrobe_item_image.dart';

/// Opens a piece of an outfit: its photo and details, with pin and swap.
/// The sheet closes before [onPin] or [onSwap] runs.
Future<void> showPieceSheet(
  BuildContext context, {
  required ClothingItemModel item,
  required bool locked,
  required VoidCallback onPin,
  required VoidCallback onSwap,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => PieceSheet(
      item: item,
      locked: locked,
      onPin: () {
        Navigator.pop(sheetContext);
        onPin();
      },
      onSwap: () {
        Navigator.pop(sheetContext);
        onSwap();
      },
    ),
  );
}

class PieceSheet extends StatelessWidget {
  const PieceSheet({
    super.key,
    required this.item,
    required this.locked,
    required this.onPin,
    required this.onSwap,
  });

  final ClothingItemModel item;
  final bool locked;
  final VoidCallback onPin;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final swatch = WardrobeColors.swatchFor(item.color, item.hex);
    final cutout = item.cutoutUrl;
    final hasCutout = cutout != null && cutout.startsWith('http');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 260,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(hasCutout ? 0 : 14),
                child: WardrobeItemImage(
                  imageUrl: hasCutout ? cutout : item.imageUrl,
                  backdrop: hasCutout
                      ? Colors.transparent
                      : WardrobeItemImage.defaultBackdrop,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (item.category != null)
              Text(
                WardrobeLabels.category(l10n, item.category!).toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 0.8,
                ),
              ),
            Text(
              WardrobeLabels.type(l10n, item.type),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if (swatch != null) ...[
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: swatch,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.outline),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    WardrobeLabels.colors(l10n, item),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPin,
                    icon: Icon(
                      locked ? Icons.push_pin : Icons.push_pin_outlined,
                    ),
                    label: Text(locked ? l10n.pinned : l10n.pin),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onSwap,
                    icon: const Icon(Icons.swap_horiz),
                    label: Text(l10n.swap),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
