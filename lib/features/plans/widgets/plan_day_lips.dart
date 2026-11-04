import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../plan_day.dart';
import '../screens/week_routine_screen.dart';

class PlanDayLips extends StatelessWidget {
  const PlanDayLips({
    super.key,
    required this.days,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<PlanDay> days;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final selected = index == selectedIndex;
          final weekday = _weekdayAbbrev(isAr, day.date.weekday);
          final dayNum = '${day.date.day}';

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelect(index),
              borderRadius: BorderRadius.circular(AppRadius.large),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: 58,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? colors.primary : colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(
                    color: selected ? colors.primary : colors.outline,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      weekday,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: selected
                            ? colors.onPrimary.withValues(alpha: 0.85)
                            : colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dayNum,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: selected ? colors.onPrimary : colors.onSurface,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // The day's occasion, so the week reads at a glance.
                    Icon(
                      occasionIcon(day.occasion),
                      size: 15,
                      color: selected
                          ? colors.onPrimary.withValues(alpha: 0.9)
                          : day.occasion == 'everyday'
                          ? colors.onSurfaceVariant.withValues(alpha: 0.5)
                          : colors.primary,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static String _weekdayAbbrev(bool isAr, int weekday) {
    if (isAr) {
      return const ['أحد', 'إثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت'][weekday -
          1];
    }
    return const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
  }
}
