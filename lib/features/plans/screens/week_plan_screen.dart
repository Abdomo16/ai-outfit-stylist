import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/datasources/ai_service.dart';
import '../../../data/datasources/calendar_service.dart';
import '../../../data/datasources/weather_service.dart';
import '../../../data/repositories/plan_repository.dart';
import '../../../data/repositories/wardrobe_repository_impl.dart';
import '../../../data/repositories/wear_log_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../cubit/plan_cubit.dart';
import '../widgets/plan_day_tile.dart';

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
      )..loadLatest(),
      child: const _WeekPlanView(),
    );
  }
}

class _WeekPlanView extends StatelessWidget {
  const _WeekPlanView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(l10n.thisWeek)),
      body: BlocBuilder<PlanCubit, PlanView>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(state.error!, style: TextStyle(color: AppColors.error)),
                ),
              if (state.loading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.days.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(l10n.weekEmpty),
                ),
              for (final day in state.days) PlanDayTile(day: day),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: state.loading
                    ? null
                    : () => context.read<PlanCubit>().generateWeek(),
                child: Text(l10n.generateWeek),
              ),
            ],
          );
        },
      ),
    );
  }
}
