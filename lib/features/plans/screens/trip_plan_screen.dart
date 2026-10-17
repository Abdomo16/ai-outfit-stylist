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
import '../plan_day.dart';
import '../widgets/plan_day_tile.dart';

class TripPlanScreen extends StatefulWidget {
  const TripPlanScreen({super.key});

  @override
  State<TripPlanScreen> createState() => _TripPlanScreenState();
}

class _TripPlanScreenState extends State<TripPlanScreen> {
  final _city = TextEditingController();
  final List<TripStop> _stops = [];
  List<CityMatch> _matches = [];
  String _occasion = 'everyday';

  @override
  void dispose() {
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (context) => PlanCubit(
        kind: 'trip',
        wardrobe: WardrobeRepositoryImpl(aiService: AIService()),
        ai: AIService(),
        weather: WeatherService(),
        calendar: CalendarService(),
        wearLog: WearLogRepository(),
        plans: PlanRepository(),
      )..loadLatest(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.planTrip)),
            body: BlocBuilder<PlanCubit, PlanView>(
              builder: (context, state) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  children: [
                    TextField(
                      controller: _city,
                      decoration: InputDecoration(labelText: l10n.searchCity),
                      onSubmitted: (_) => _search(),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(onPressed: _search, child: Text(l10n.search)),
                    ),
                    for (final match in _matches)
                      ListTile(
                        title: Text(match.label),
                        onTap: () => _add(match),
                      ),
                    for (var i = 0; i < _stops.length; i++)
                      ListTile(
                        title: Text(_stops[i].label),
                        subtitle: Text(
                          '${_stops[i].start.toString().split(' ').first} – ${_stops[i].end.toString().split(' ').first}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _stops.removeAt(i)),
                        ),
                      ),
                    DropdownButton<String>(
                      value: _occasion,
                      items: [
                        for (final name in [
                          'everyday',
                          'work',
                          'university',
                          'party',
                          'gym',
                          'date night',
                        ])
                          DropdownMenuItem(value: name, child: Text(name)),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _occasion = value);
                      },
                    ),
                    if (state.error != null)
                      Text(state.error!, style: const TextStyle(color: AppColors.error)),
                    if (state.loading)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    for (final day in state.days) PlanDayTile(day: day),
                    if (state.days.isNotEmpty) PackingList(days: state.days),
                    ElevatedButton(
                      onPressed: state.loading
                          ? null
                          : () => context.read<PlanCubit>().generateTrip(
                              _stops,
                              occasion: _occasion,
                            ),
                      child: Text(l10n.generateTrip),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _search() async {
    final matches = await WeatherService().searchCities(_city.text);
    if (!mounted) return;
    setState(() => _matches = matches);
  }

  Future<void> _add(CityMatch match) async {
    final now = DateTime.now();
    final start = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 16)),
      initialDate: now,
    );
    if (start == null || !mounted) return;
    final end = await showDatePicker(
      context: context,
      firstDate: start,
      lastDate: start.add(const Duration(days: 16)),
      initialDate: start,
    );
    if (end == null) return;
    setState(() {
      _stops.add(
        TripStop(
          label: match.label,
          latitude: match.latitude,
          longitude: match.longitude,
          start: start,
          end: end,
        ),
      );
      _matches = [];
      _city.clear();
    });
  }
}
