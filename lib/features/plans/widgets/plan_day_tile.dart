import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/clothing_item_model.dart';
import '../../../features/outfit_generator/utils/context_labels.dart';
import '../../../l10n/app_localizations.dart';
import '../../wardrobe/utils/wardrobe_labels.dart';
import '../cubit/plan_cubit.dart';
import '../plan_day.dart';
import '../day_tips.dart';
import '../reason_text.dart';
import '../../outfit_generator/widgets/outfit_preview_card.dart';
import '../../outfit_generator/widgets/piece_sheet.dart';
import '../screens/week_routine_screen.dart';
import '../week_routine.dart';

class PlanDayTile extends StatelessWidget {
  const PlanDayTile({super.key, required this.day, this.busy = false});

  final PlanDay day;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final cubit = context.read<PlanCubit>();
    final reasons = localizedReasons(
      l10n,
      day.outfit,
      weather: ContextLabels.weather(l10n, day.weather),
      season: ContextLabels.season(l10n, day.season),
    );
    final tips = tipsFor(day);
    final egyptSeason = egyptSeasonLabel(l10n, day.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: 19,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MaterialLocalizations.of(
                        context,
                      ).formatMediumDate(day.date),
                      style: theme.textTheme.titleMedium,
                    ),
                    if (day.city != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        day.city!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ContextBadge(
                icon: _weatherIcon(day.weather),
                label: day.high == null
                    ? ContextLabels.weather(l10n, day.weather)
                    : '${day.high}°${day.low == null ? '' : ' / ${day.low}°'}'
                          ' · ${ContextLabels.weather(l10n, day.weather)}',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ContextBadge(
                icon: occasionIcon(day.occasion),
                label: ContextLabels.occasion(l10n, day.occasion),
                trailing: Icons.expand_more_rounded,
                onTap: busy ? null : () => _pickOccasion(context, cubit),
              ),
              for (final occasion in day.later)
                _ContextBadge(
                  icon: occasionIcon(occasion),
                  label: l10n.laterToday(
                    ContextLabels.occasion(l10n, occasion),
                  ),
                  subtle: true,
                ),
              if (egyptSeason != null)
                _ContextBadge(
                  icon: tips.contains(DayTip.ramadan)
                      ? Icons.nightlight_round
                      : Icons.celebration_outlined,
                  label: egyptSeason,
                  subtle: true,
                )
              else
                _ContextBadge(
                  icon: Icons.wb_sunny_outlined,
                  label: ContextLabels.season(l10n, day.season),
                  subtle: true,
                ),
            ],
          ),
          const SizedBox(height: 14),
          OutfitPreviewCard(
            outfit: day.outfit,
            height: 300,
            loading: busy,
            pinnedIds: cubit.locksFor(day),
            onPieceTap: busy
                ? null
                : (item) => showPieceSheet(
                    context,
                    item: item,
                    locked: cubit.locksFor(day).contains(item.id),
                    onPin: () => cubit.toggleLock(day, item.id!),
                    onSwap: () => cubit.swapPiece(day, item.id!),
                  ),
          ),
          if (tips.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < tips.length; i++) ...[
                    if (i > 0) const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _tipIcon(tips[i]),
                          size: 17,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tipText(l10n, tips[i]),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (reasons.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 17,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reasons.first,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 0,
            alignment: WrapAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: busy
                    ? null
                    : () async {
                        try {
                          await cubit.markWorn(day);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.wornToday)),
                          );
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.couldNotSaveWear)),
                          );
                        }
                      },
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: Text(l10n.markWorn),
              ),
              TextButton.icon(
                onPressed: busy ? null : () => cubit.regenerateDay(day),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(l10n.regenerateDay),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

IconData _tipIcon(DayTip tip) {
  return switch (tip) {
    DayTip.rain => Icons.umbrella_outlined,
    DayTip.veryHot => Icons.wb_sunny_outlined,
    DayTip.cold => Icons.ac_unit_rounded,
    DayTip.coolEvening => Icons.dark_mode_outlined,
    DayTip.ramadan => Icons.nightlight_round,
    DayTip.eid => Icons.celebration_outlined,
  };
}

IconData _weatherIcon(String weather) {
  return switch (weather) {
    'hot' => Icons.wb_sunny_outlined,
    'cold' => Icons.ac_unit_rounded,
    'rain' => Icons.umbrella_outlined,
    _ => Icons.cloud_outlined,
  };
}

/// Asks what the day is for; a new answer re-dresses the day.
extension on PlanDayTile {
  Future<void> _pickOccasion(BuildContext context, PlanCubit cubit) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.large),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.dayOccasionTitle,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final occasion in ['everyday', ...WeekRoutine.occasions])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(occasionIcon(occasion)),
                  title: Text(ContextLabels.occasion(l10n, occasion)),
                  trailing: occasion == day.occasion
                      ? Icon(
                          Icons.check_rounded,
                          color: Theme.of(sheetContext).colorScheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.pop(sheetContext, occasion),
                ),
            ],
          ),
        ),
      ),
    );
    if (choice != null) await cubit.changeOccasion(day, choice);
  }
}

class _ContextBadge extends StatelessWidget {
  const _ContextBadge({
    required this.icon,
    required this.label,
    this.subtle = false,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool subtle;
  final IconData? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final badge = _badge(context, colors);
    if (onTap == null) return badge;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: badge,
      ),
    );
  }

  Widget _badge(BuildContext context, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: subtle ? colors.surfaceContainerLow : colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: subtle ? colors.onSurfaceVariant : colors.onPrimaryContainer,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: subtle
                  ? colors.onSurfaceVariant
                  : colors.onPrimaryContainer,
              letterSpacing: 0,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 2),
            Icon(
              trailing,
              size: 16,
              color: subtle
                  ? colors.onSurfaceVariant
                  : colors.onPrimaryContainer,
            ),
          ],
        ],
      ),
    );
  }
}

class PackingList extends StatelessWidget {
  const PackingList({super.key, required this.days});

  final List<PlanDay> days;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final seen = <String>{};
    final pieces = <ClothingItemModel>[];
    for (final day in days) {
      for (final item in day.outfit.items) {
        final id = item.id ?? '${item.type}-${item.color}';
        if (seen.add(id)) pieces.add(item);
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.packingList, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final item in pieces)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '${WardrobeLabels.type(l10n, item.type)} · ${WardrobeLabels.colors(l10n, item)}',
            ),
          ),
      ],
    );
  }
}
