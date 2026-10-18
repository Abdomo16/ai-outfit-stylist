import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/pending_wardrobe_item.dart';
import '../../../../l10n/app_localizations.dart';
import '../utils/wardrobe_labels.dart';

/// Asks which partly visible items to add. Resolves to the kept items, or
/// an empty list when the user skips or dismisses the sheet.
Future<List<PendingWardrobeItem>> showPartialItemsSheet(
  BuildContext context,
  List<PendingWardrobeItem> items,
) async {
  final kept = await showModalBottomSheet<List<PendingWardrobeItem>>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.large)),
    ),
    builder: (context) => _PartialItemsSheet(items: items),
  );
  return kept ?? const [];
}

const _animation = Duration(milliseconds: 180);

class _PartialItemsSheet extends StatefulWidget {
  final List<PendingWardrobeItem> items;

  const _PartialItemsSheet({required this.items});

  @override
  State<_PartialItemsSheet> createState() => _PartialItemsSheetState();
}

class _PartialItemsSheetState extends State<_PartialItemsSheet> {
  final Set<PendingWardrobeItem> _keep = {};

  void _toggle(PendingWardrobeItem item) {
    setState(() {
      if (!_keep.remove(item)) _keep.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.crop_free_rounded, color: AppColors.white, size: 28),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.partialItemsTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.partialItemsBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: widget.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm + 4),
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    return _PendingCard(
                      item: item,
                      selected: _keep.contains(item),
                      onTap: () => _toggle(item),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, size: 20, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm + 4),
                    Expanded(
                      child: Text(
                        l10n.partialItemsTip,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, const <PendingWardrobeItem>[]),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.onSurface,
                          side: BorderSide(color: colors.outline),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.medium),
                          ),
                        ),
                        child: Text(
                          l10n.partialSkip,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _keep.isEmpty
                            ? null
                            : () => Navigator.pop(
                                  context,
                                  widget.items.where(_keep.contains).toList(),
                                ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.18),
                          disabledForegroundColor: AppColors.primary.withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.medium),
                          ),
                        ),
                        child: Text(
                          l10n.partialKeepCount(_keep.length),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final PendingWardrobeItem item;
  final bool selected;
  final VoidCallback onTap;

  const _PendingCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final preview = item.previewBytes;
    final hidden = item.reason == PendingWardrobeItem.hidden;

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: _animation,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(AppSpacing.sm + 2),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.06)
                : colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.medium + 4),
            border: Border.all(
              color: selected ? AppColors.primary : colors.outline,
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.18)
                    : colors.shadow.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                child: Container(
                  width: 72,
                  height: 88,
                  color: AppColors.white,
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: preview == null
                      ? Icon(Icons.checkroom_rounded, color: colors.onSurfaceVariant)
                      : Image.memory(preview, fit: BoxFit.contain, gaplessPlayback: true),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      WardrobeLabels.type(l10n, item.type).toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.itemTitle(
                        WardrobeLabels.color(l10n, item.color),
                        WardrobeLabels.type(l10n, item.type),
                      ),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hidden ? Icons.layers_outlined : Icons.crop_rounded,
                            size: 14,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              hidden ? l10n.partialReasonHidden : l10n.partialReasonCutOff,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _CheckBadge(selected: selected),
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
      duration: _animation,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primary : AppColors.transparent,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: AnimatedSwitcher(
        duration: _animation,
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: selected
            ? const Icon(Icons.check_rounded, key: ValueKey('on'), size: 18, color: AppColors.white)
            : const SizedBox.shrink(key: ValueKey('off')),
      ),
    );
  }
}
