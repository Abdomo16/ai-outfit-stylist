import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/ai_service.dart';
import '../../../data/datasources/calendar_service.dart';
import '../../../data/datasources/reminder_service.dart';
import '../../../data/datasources/weather_service.dart';
import '../../../data/repositories/plan_repository.dart';
import '../../../data/repositories/routine_repository.dart';
import '../../../data/repositories/wardrobe_repository_impl.dart';
import '../../../data/repositories/wear_log_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../outfit_generator/utils/context_labels.dart';
import '../../wardrobe/utils/wardrobe_labels.dart';
import '../cubit/plan_cubit.dart';
import '../plan_day.dart';
import '../week_routine.dart';
import '../widgets/plan_day_lips.dart';
import '../widgets/governorate_picker.dart';
import '../widgets/plan_day_tile.dart';
import 'week_routine_screen.dart';

class WeekPlanScreen extends StatelessWidget {
  const WeekPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlanCubit(
        kind: 'week',
        wardrobe: WardrobeRepositoryImpl(aiService: AIService()),
        ai: AIService(),
        weather: WeatherService(),
        calendar: CalendarService(),
        wearLog: WearLogRepository(),
        plans: PlanRepository(),
        routine: RoutineRepository(),
      )..loadLatest(),
      child: const _WeekPlanView(),
    );
  }
}

class _WeekPlanView extends StatefulWidget {
  const _WeekPlanView();

  @override
  State<_WeekPlanView> createState() => _WeekPlanViewState();
}

class _WeekPlanViewState extends State<_WeekPlanView> {
  int _selectedIndex = 0;
  int _shownDays = 0;

  /// Sets tonight's and the coming evenings' reminders from the plan.
  void _scheduleReminders(List<PlanDay> days) {
    final l10n = AppLocalizations.of(context);
    final reminders = [
      for (final day in days)
        (
          day: day.date,
          title:
              l10n.reminderNotificationTitle(
                ContextLabels.occasion(l10n, day.occasion),
              ) +
              (day.high == null ? '' : ' · ${day.high}°'),
          body: day.outfit.items
              .map(
                (item) =>
                    '${WardrobeLabels.type(l10n, item.type)} (${WardrobeLabels.colors(l10n, item)})',
              )
              .join(', '),
        ),
    ];
    ReminderService()
        .schedule(reminders, channelName: l10n.reminderTitle)
        .catchError((Object error) {
          debugPrint('Could not schedule reminders: $error');
        });
  }

  int _todayOrZero(List<PlanDay> days) {
    final today = DateTime.now();
    final todayIndex = days.indexWhere(
      (d) =>
          d.date.year == today.year &&
          d.date.month == today.month &&
          d.date.day == today.day,
    );
    return todayIndex >= 0 ? todayIndex : 0;
  }

  Future<void> _editRoutine(PlanView state) async {
    final cubit = context.read<PlanCubit>();
    final routine = await Navigator.push<WeekRoutine>(
      context,
      MaterialPageRoute(
        builder: (_) => WeekRoutineScreen(initial: state.routine),
      ),
    );
    if (routine != null) await cubit.saveRoutine(routine);
  }

  Future<void> _pickCity(PlanView state) async {
    final cubit = context.read<PlanCubit>();
    final choice = await showGovernoratePicker(
      context,
      current: state.homeCity,
    );
    if (choice != null) await cubit.setHomeCity(choice.city);
  }

  int _resolveIndex(List<PlanDay> days) {
    if (days.isEmpty) return 0;
    if (_selectedIndex >= days.length) return _todayOrZero(days);
    return _selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocConsumer<PlanCubit, PlanView>(
      listenWhen: (prev, next) => !identical(prev.days, next.days),
      listener: (context, state) {
        if (state.days.isEmpty) return;
        _scheduleReminders(state.days);
        if (state.days.length != _shownDays) {
          _shownDays = state.days.length;
          setState(() => _selectedIndex = _todayOrZero(state.days));
        }
      },
      builder: (context, state) {
        final selectedIndex = _resolveIndex(state.days);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(l10n.thisWeek),
            actions: [
              IconButton(
                tooltip: l10n.myWeek,
                onPressed: state.loading ? null : () => _editRoutine(state),
                icon: const Icon(Icons.edit_calendar_rounded),
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _CityChip(
                      label:
                          state.homeCity?.name(
                            Localizations.localeOf(context).languageCode,
                          ) ??
                          l10n.myLocation,
                      onTap: state.loading ? null : () => _pickCity(state),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (state.loading && state.days.isNotEmpty) ...[
                    const LinearProgressIndicator(minHeight: 2),
                    const SizedBox(height: 16),
                  ],
                  if (state.error != null) ...[
                    _PlanMessage(
                      icon: Icons.info_outline_rounded,
                      message: state.error!,
                      color: colors.error,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (state.needsCity && !state.loading) ...[
                    _PromptCard(
                      icon: Icons.location_off_outlined,
                      title: l10n.pickCityTitle,
                      message: l10n.pickCityPrompt,
                      action: l10n.pickGovernorate,
                      onTap: () => _pickCity(state),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (state.routine.isEmpty && !state.loading) ...[
                    _PromptCard(
                      icon: Icons.edit_calendar_rounded,
                      title: l10n.setUpWeek,
                      message: l10n.routinePrompt,
                      action: l10n.setUpWeek,
                      onTap: () => _editRoutine(state),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (state.loading && state.days.isEmpty)
                    _LoadingPlan(message: l10n.loadingWeekPlan)
                  else if (state.days.isEmpty)
                    _EmptyPlan(message: l10n.weekEmpty)
                  else ...[
                    PlanDayLips(
                      days: state.days,
                      selectedIndex: selectedIndex,
                      onSelect: (index) =>
                          setState(() => _selectedIndex = index),
                    ),
                    const SizedBox(height: 16),
                    PlanDayTile(
                      day: state.days[selectedIndex],
                      busy: state.loading,
                    ),
                  ],
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
              // heightFactor 1 keeps the bar as tall as its button; a plain
              // Center fills the screen and hides the plan.
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: state.loading
                            ? null
                            : () => context.read<PlanCubit>().generateWeek(),
                        icon: const Icon(Icons.auto_awesome_rounded, size: 19),
                        label: Text(l10n.generateWeek),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Where the forecast comes from; tapping it changes the governorate.
class _CityChip extends StatelessWidget {
  const _CityChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      shape: StadiumBorder(side: BorderSide(color: colors.outline)),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 7, 6, 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on_outlined, size: 17, color: colors.primary),
              const SizedBox(width: 4),
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A highlighted card asking the user to set something up.
class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String message;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.onPrimaryContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(onPressed: onTap, child: Text(action)),
        ],
      ),
    );
  }
}

class _LoadingPlan extends StatelessWidget {
  const _LoadingPlan({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _EmptyPlan extends StatelessWidget {
  const _EmptyPlan({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: colors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanMessage extends StatelessWidget {
  const _PlanMessage({
    required this.icon,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: colors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colors.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
