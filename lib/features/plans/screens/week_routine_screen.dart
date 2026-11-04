import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/ai_service.dart';
import '../../../data/datasources/reminder_service.dart';
import '../../../features/outfit_generator/widgets/ask_ai_bar.dart';
import '../../../features/outfit_generator/utils/context_labels.dart';
import '../../../l10n/app_localizations.dart';
import '../week_routine.dart';

IconData occasionIcon(String occasion) {
  return switch (occasion) {
    'university' => Icons.school_outlined,
    'work' => Icons.work_outline_rounded,
    'gym' => Icons.fitness_center_rounded,
    'date night' => Icons.favorite_border_rounded,
    'party' => Icons.celebration_outlined,
    'formal' => Icons.business_center_outlined,
    'family' => Icons.groups_outlined,
    'travel' => Icons.flight_outlined,
    'beach' => Icons.beach_access_outlined,
    'sightseeing' => Icons.account_balance_outlined,
    'wedding' => Icons.diamond_outlined,
    _ => Icons.weekend_outlined,
  };
}

/// The weekday's full name in the app's language.
String weekdayName(BuildContext context, int weekday) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  // 1 January 2024 was a Monday, so day N of that week is weekday N.
  return DateFormat.EEEE(locale).format(DateTime(2024, 1, weekday));
}

/// Lets the user set what they usually do each weekday. Pops with the new
/// [WeekRoutine], or null when they leave without saving.
class WeekRoutineScreen extends StatefulWidget {
  const WeekRoutineScreen({super.key, required this.initial, this.parse});

  final WeekRoutine initial;

  /// Reads a routine from what the user wrote or said. Defaults to the
  /// backend's routine reader.
  final Future<({Map<String, dynamic> days, String reply})> Function(
    String message,
    String locale,
  )?
  parse;

  @override
  State<WeekRoutineScreen> createState() => _WeekRoutineScreenState();
}

class _WeekRoutineScreenState extends State<WeekRoutineScreen> {
  late WeekRoutine _routine = widget.initial.isEmpty
      ? WeekRoutine.suggested
      : widget.initial;
  bool _reading = false;
  final _reminders = ReminderService();
  bool? _remind;

  @override
  void initState() {
    super.initState();
    _reminders.isEnabled().then((on) {
      if (mounted) setState(() => _remind = on);
    });
  }

  Future<void> _setRemind(bool on) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _remind = on);
    var saved = false;
    try {
      saved = await _reminders.setEnabled(on);
    } catch (_) {}
    if (!mounted) return;
    if (!saved) {
      setState(() => _remind = !on);
      messenger.showSnackBar(SnackBar(content: Text(l10n.reminderDenied)));
    }
  }

  Future<void> _describe(String message) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    setState(() => _reading = true);
    try {
      final parse =
          widget.parse ??
          (message, locale) =>
              AIService().parseRoutine(message: message, locale: locale);
      final result = await parse(message, locale);
      final heard = WeekRoutine.fromJson(result.days);
      if (!mounted) return;
      if (heard.isEmpty) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.routineNotUnderstood)),
        );
        return;
      }
      setState(() => _routine = _routine.merged(heard));
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.reply.isEmpty ? l10n.routineFilled : result.reply,
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.routineReadFailed)));
      }
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myWeek)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text(l10n.routineTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                l10n.routineHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              AskAiBar(
                title: l10n.describeWeekTitle,
                subtitle: l10n.describeWeekSubtitle,
                hint: l10n.describeWeekHint,
                examples: [
                  l10n.describeWeekExample1,
                  l10n.describeWeekExample2,
                ],
                onSend: _reading ? (_) {} : _describe,
              ),
              if (_reading) ...[
                const SizedBox(height: 10),
                const LinearProgressIndicator(minHeight: 2),
              ],
              const SizedBox(height: 16),
              for (final weekday in WeekRoutine.weekOrder)
                _DayCard(
                  title: weekdayName(context, weekday),
                  selected: _routine.occasionsOn(weekday),
                  onToggle: (occasion) => setState(
                    () => _routine = _routine.toggled(weekday, occasion),
                  ),
                ),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(color: colors.outline),
                ),
                child: SwitchListTile(
                  secondary: Icon(
                    Icons.notifications_active_outlined,
                    color: colors.primary,
                  ),
                  title: Text(l10n.reminderTitle),
                  subtitle: Text(l10n.reminderSubtitle),
                  value: _remind ?? false,
                  onChanged: _remind == null ? null : _setRemind,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.outline)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, _routine),
                icon: const Icon(Icons.auto_awesome_rounded, size: 19),
                label: Text(l10n.saveRoutine),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.title,
    required this.selected,
    required this.onToggle,
  });

  final String title;
  final List<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final full = selected.length >= WeekRoutine.maxPerDay;
    final summary = selected.isEmpty
        ? l10n.routineFreeDay
        : selected.map((o) => ContextLabels.occasion(l10n, o)).join('  →  ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: selected.isEmpty
              ? colors.outline
              : colors.primary.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  summary,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: selected.isEmpty
                        ? colors.onSurfaceVariant
                        : colors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final occasion in WeekRoutine.occasions)
                FilterChip(
                  avatar: Icon(occasionIcon(occasion), size: 16),
                  label: Text(ContextLabels.occasion(l10n, occasion)),
                  showCheckmark: false,
                  selected: selected.contains(occasion),
                  onSelected: full && !selected.contains(occasion)
                      ? null
                      : (_) => onToggle(occasion),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
