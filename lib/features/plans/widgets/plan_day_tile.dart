import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/weather_service.dart';
import '../../../data/models/clothing_item_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../wardrobe/utils/wardrobe_labels.dart';
import '../cubit/plan_cubit.dart';
import '../plan_day.dart';
import '../reason_text.dart';

class PlanDayTile extends StatelessWidget {
  const PlanDayTile({super.key, required this.day});

  final PlanDay day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final cubit = context.read<PlanCubit>();
    final reasons = localizedReasons(
      l10n,
      day.outfit,
      weather: day.weather,
      season: day.season,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${isoDate(day.date)}${day.city == null ? '' : ' · ${day.city}'}',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text('${day.occasion} · ${day.weather}', style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          for (final item in day.outfit.items)
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${WardrobeLabels.type(l10n, item.type)} · ${WardrobeLabels.colors(l10n, item)}',
                  ),
                ),
                if (item.id != null) ...[
                  IconButton(
                    tooltip: l10n.pin,
                    onPressed: () => cubit.toggleLock(day, item.id!),
                    icon: const Icon(Icons.push_pin_outlined, size: 18),
                  ),
                  IconButton(
                    tooltip: l10n.swap,
                    onPressed: () => cubit.swapPiece(day, item.id!),
                    icon: const Icon(Icons.swap_horiz, size: 18),
                  ),
                ],
              ],
            ),
          if (reasons.isNotEmpty)
            Text(reasons.first, style: theme.textTheme.bodySmall),
          Row(
            children: [
              TextButton(
                child: Text(l10n.markWorn),
                onPressed: () async {
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
              ),
              TextButton(
                onPressed: () => cubit.regenerateDay(day),
                child: Text(l10n.regenerateDay),
              ),
            ],
          ),
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
