import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/weather_service.dart';
import '../../../features/outfit_generator/utils/context_labels.dart';
import '../../../l10n/app_localizations.dart';

/// The stop's weather at a glance: the usual conditions and the hottest
/// and coolest it gets.
class TripWeatherPreview extends StatelessWidget {
  const TripWeatherPreview({super.key, required this.forecast});

  final List<DayForecast>? forecast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final days = forecast;
    final style = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
    );

    if (days == null) {
      return Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(l10n.checkingWeather, style: style),
        ],
      );
    }
    if (days.isEmpty) return const SizedBox.shrink();

    final counts = <String, int>{};
    for (final day in days) {
      counts[day.weather] = (counts[day.weather] ?? 0) + 1;
    }
    final usual = counts.entries
        .reduce((a, b) => b.value > a.value ? b : a)
        .key;
    final highs = [for (final day in days) ?day.high];
    final lows = [for (final day in days) ?day.low];
    final typical = days.any((day) => day.typical);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(tripWeatherIcon(usual), size: 18, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                ContextLabels.weather(l10n, usual),
                style: theme.textTheme.labelLarge,
              ),
              const Spacer(),
              if (highs.isNotEmpty) ...[
                Icon(Icons.arrow_upward_rounded, size: 14, color: style?.color),
                Text(
                  '${highs.reduce((a, b) => a > b ? a : b).round()}Â°',
                  style: style,
                ),
                const SizedBox(width: 8),
              ],
              if (lows.isNotEmpty) ...[
                Icon(
                  Icons.arrow_downward_rounded,
                  size: 14,
                  color: style?.color,
                ),
                Text(
                  '${lows.reduce((a, b) => a < b ? a : b).round()}Â°',
                  style: style,
                ),
              ],
            ],
          ),
          if (typical) ...[
            const SizedBox(height: 6),
            Text(l10n.typicalWeatherHint, style: style),
          ],
        ],
      ),
    );
  }
}

/// "Nov 5 – Nov 7", or one date when [start] and [end] are the same day.
String tripDateRange(BuildContext context, DateTime start, DateTime end) {
  final format = DateFormat.MMMd(
    Localizations.localeOf(context).toLanguageTag(),
  );
  if (DateUtils.isSameDay(start, end)) return format.format(start);
  return '${format.format(start)} â€“ ${format.format(end)}';
}

IconData tripWeatherIcon(String weather) {
  return switch (weather) {
    'hot' => Icons.wb_sunny_outlined,
    'cold' => Icons.ac_unit_rounded,
    'rain' => Icons.umbrella_outlined,
    _ => Icons.cloud_outlined,
  };
}
