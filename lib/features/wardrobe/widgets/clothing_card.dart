import 'package:flutter/material.dart';
import '../../../../data/models/clothing_item_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../screens/clothing_detail_screen.dart';
import '../utils/wardrobe_labels.dart';
import 'color_dots.dart';
import 'wardrobe_item_image.dart';

class ClothingCard extends StatelessWidget {
  final ClothingItemModel item;

  /// While true, a tap toggles selection instead of opening the details.
  final bool selectionMode;
  final bool selected;
  final VoidCallback? onLongPress;
  final VoidCallback? onSelectToggle;

  const ClothingCard({
    super.key,
    required this.item,
    this.selectionMode = false,
    this.selected = false,
    this.onLongPress,
    this.onSelectToggle,
  });

  static const _animation = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () {
        if (selectionMode) {
          onSelectToggle?.call();
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ClothingDetailScreen(item: item)),
        );
      },
      onLongPress: onLongPress,
      child: AnimatedScale(
        scale: selected ? 0.95 : 1.0,
        duration: _animation,
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: _animation,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(
              color: selected ? AppColors.primary : colors.outline,
              width: selected ? 2.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.25)
                    : colors.shadow.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppRadius.large),
                        topRight: Radius.circular(AppRadius.large),
                      ),
                      child: WardrobeItemImage(imageUrl: item.imageUrl),
                    ),
                    IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: selected ? 1 : 0,
                        duration: _animation,
                        child: ColoredBox(
                          color: AppColors.primary.withValues(alpha: 0.14),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: AppSpacing.sm,
                      end: AppSpacing.sm,
                      child: AnimatedOpacity(
                        opacity: selectionMode ? 1 : 0,
                        duration: _animation,
                        child: _CheckBadge(selected: selected),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            WardrobeLabels.type(l10n, item.type).toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ColorDots(item: item, size: 10),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      WardrobeLabels.title(l10n, item),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckBadge extends StatelessWidget {
  final bool selected;

  const _CheckBadge({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: ClothingCard._animation,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primary : AppColors.white.withValues(alpha: 0.85),
        border: Border.all(
          color: selected ? AppColors.white : AppColors.primary.withValues(alpha: 0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: ClothingCard._animation,
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: selected
            ? const Icon(Icons.check, key: ValueKey('on'), size: 18, color: AppColors.white)
            : const SizedBox.shrink(key: ValueKey('off')),
      ),
    );
  }
}
