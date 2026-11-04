import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/ai_service.dart';
import '../../../data/datasources/calendar_service.dart';
import '../../../data/datasources/weather_service.dart';
import '../../../data/repositories/plan_repository.dart';
import '../../../data/repositories/wardrobe_repository_impl.dart';
import '../../../data/repositories/wear_log_repository.dart';
import '../../../features/outfit_generator/utils/context_labels.dart';
import '../../../l10n/app_localizations.dart';
import '../cubit/plan_cubit.dart';
import '../destinations.dart';
import '../plan_day.dart';
import '../widgets/plan_day_tile.dart';
import '../widgets/trip_dates_sheet.dart';
import '../widgets/trip_weather_preview.dart';
import 'week_routine_screen.dart';

/// Longest trip, in days; each day is one outfit to style.
const int maxTripDays = 21;

/// Furthest a trip can start or end, in days from today. Past the
/// forecast, the weather comes from the same dates in past years.
const int tripReachDays = 300;

class TripPlanScreen extends StatelessWidget {
  const TripPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      child: const TripPlanView(),
    );
  }
}

/// The trip planner, reading the [PlanCubit] provided above it.
class TripPlanView extends StatefulWidget {
  const TripPlanView({super.key});

  @override
  State<TripPlanView> createState() => _TripPlanViewState();
}

class _TripPlanViewState extends State<TripPlanView> {
  final _search = TextEditingController();
  final _weather = WeatherService();
  final List<TripStop> _stops = [];

  /// Places outside Egypt from the last worldwide search; null until one.
  List<CityMatch>? _worldMatches;
  bool _searchingWorld = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocBuilder<PlanCubit, PlanView>(
      builder: (context, state) {
        final query = _search.text.trim();
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(title: Text(l10n.planTrip)),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    onChanged: (_) => setState(() => _worldMatches = null),
                    onSubmitted: (_) {
                      if (searchDestinations(query).isEmpty) _searchWorld();
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText: l10n.searchDestination,
                      suffixIcon: query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () => setState(() {
                                _search.clear();
                                _worldMatches = null;
                              }),
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (query.isEmpty)
                    _PopularDestinations(onPick: _addDestination)
                  else
                    _SearchResults(
                      query: query,
                      worldMatches: _worldMatches,
                      searchingWorld: _searchingWorld,
                      onPick: _addDestination,
                      onPickWorld: _addWorldCity,
                      onSearchWorld: _searchWorld,
                    ),
                  const SizedBox(height: 24),
                  if (_stops.isNotEmpty) ...[
                    _SectionTitle(
                      title: l10n.yourTrip,
                      trailing: l10n.tripDayCount(
                        _stops.fold(0, (sum, stop) => sum + stop.days),
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (var i = 0; i < _stops.length; i++)
                      _StopCard(
                        stop: _stops[i],
                        enabled: !state.loading,
                        onDates: () => _changeDates(i),
                        onRemove: () => setState(() => _stops.removeAt(i)),
                        onOccasion: (occasion) => setState(
                          () => _stops[i] = _stops[i].copyWith(
                            occasion: occasion,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                  ] else if (state.days.isEmpty && !state.loading)
                    _TripEmpty(
                      title: l10n.tripEmptyTitle,
                      message: l10n.tripEmptyMessage,
                    ),
                  if (state.error != null) ...[
                    _ErrorMessage(message: state.error!),
                    const SizedBox(height: 16),
                  ],
                  if (state.loading && state.days.isEmpty)
                    _LoadingTrip(message: l10n.loadingTripPlan)
                  else if (state.days.isNotEmpty) ...[
                    if (state.loading) ...[
                      const LinearProgressIndicator(minHeight: 2),
                      const SizedBox(height: 16),
                    ],
                    for (final group in _byCity(state.days)) ...[
                      _CityHeader(days: group),
                      const SizedBox(height: 10),
                      for (final day in group)
                        PlanDayTile(day: day, busy: state.loading),
                      const SizedBox(height: 8),
                    ],
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        border: Border.all(color: colors.outline),
                      ),
                      child: PackingList(days: state.days),
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
                        onPressed: state.loading || _stops.isEmpty
                            ? null
                            : () => context.read<PlanCubit>().generateTrip(
                                List.of(_stops),
                              ),
                        icon: const Icon(Icons.auto_awesome_rounded, size: 19),
                        label: Text(l10n.generateTrip),
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

  /// Consecutive days in the same city, in order.
  List<List<PlanDay>> _byCity(List<PlanDay> days) {
    final groups = <List<PlanDay>>[];
    for (final day in days) {
      if (groups.isNotEmpty && groups.last.last.city == day.city) {
        groups.last.add(day);
      } else {
        groups.add([day]);
      }
    }
    return groups;
  }

  Future<void> _searchWorld() async {
    final query = _search.text.trim();
    if (query.isEmpty) return;
    setState(() => _searchingWorld = true);
    try {
      final matches = await _weather.searchCities(query);
      if (!mounted) return;
      setState(() => _worldMatches = matches);
    } catch (_) {
      if (!mounted) return;
      _say(AppLocalizations.of(context).searchFailed);
    } finally {
      if (mounted) setState(() => _searchingWorld = false);
    }
  }

  Future<void> _addDestination(Destination place) {
    final language = Localizations.localeOf(context).languageCode;
    return _addStop(
      label: place.name(language),
      latitude: place.latitude,
      longitude: place.longitude,
      occasion: place.occasion,
    );
  }

  Future<void> _addWorldCity(CityMatch city) {
    return _addStop(
      label: city.label,
      latitude: city.latitude,
      longitude: city.longitude,
      occasion: 'everyday',
    );
  }

  Future<void> _addStop({
    required String label,
    required double latitude,
    required double longitude,
    required String occasion,
  }) async {
    FocusScope.of(context).unfocus();
    final room = maxTripDays - _tripDays(_stops);
    if (room <= 0) {
      _say(AppLocalizations.of(context).tripTooLong(maxTripDays));
      return;
    }
    final picked = await _pickDates(
      city: label,
      latitude: latitude,
      longitude: longitude,
      initial: _nextFreeRange(),
      others: _stops,
      editing: false,
    );
    if (picked == null || !mounted) return;
    final stop = TripStop(
      label: label,
      latitude: latitude,
      longitude: longitude,
      start: picked.range.start,
      end: picked.range.end,
      occasion: occasion,
      forecast: picked.forecast,
    );
    setState(() {
      _stops
        ..add(stop)
        ..sort((a, b) => a.start.compareTo(b.start));
      _search.clear();
      _worldMatches = null;
    });
    if (stop.forecast == null) await _loadForecast(stop);
  }

  Future<void> _changeDates(int index) async {
    final old = _stops[index];
    final picked = await _pickDates(
      city: old.label,
      latitude: old.latitude,
      longitude: old.longitude,
      initial: DateTimeRange(start: old.start, end: old.end),
      others: [
        for (final other in _stops)
          if (!identical(other, old)) other,
      ],
      editing: true,
    );
    if (picked == null || !mounted) return;
    final stop = old.copyWith(
      start: picked.range.start,
      end: picked.range.end,
      forecast: picked.forecast,
      clearForecast: picked.forecast == null,
    );
    setState(() {
      final at = _stops.indexWhere((other) => identical(other, old));
      if (at < 0) return;
      _stops
        ..[at] = stop
        ..sort((a, b) => a.start.compareTo(b.start));
    });
    if (stop.forecast == null) await _loadForecast(stop);
  }

  int _tripDays(Iterable<TripStop> stops) =>
      stops.fold(0, (sum, stop) => sum + stop.days);

  /// Asks for a stop's days. The [others] stops' days cannot be picked,
  /// and the whole trip stays within [maxTripDays].
  Future<TripDates?> _pickDates({
    required String city,
    required double latitude,
    required double longitude,
    required DateTimeRange initial,
    required List<TripStop> others,
    required bool editing,
  }) {
    return showTripDatesSheet(
      context,
      city: city,
      initial: initial,
      taken: [
        for (final other in others)
          DateTimeRange(start: other.start, end: other.end),
      ],
      lastDay: _lastDay(),
      maxDays: maxTripDays - _tripDays(others),
      editing: editing,
      loadWeather: (start, end) => _weather.tripDays(
        latitude: latitude,
        longitude: longitude,
        start: start,
        end: end,
      ),
    );
  }

  /// Reads the weather for [stop] so its card can show it. A failure
  /// leaves an empty forecast; generating reads it again.
  Future<void> _loadForecast(TripStop stop) async {
    List<DayForecast> days;
    try {
      days = await _weather.tripDays(
        latitude: stop.latitude,
        longitude: stop.longitude,
        start: stop.start,
        end: stop.end,
      );
    } catch (_) {
      days = const [];
    }
    if (!mounted) return;
    // The stop may have been replaced meanwhile, e.g. a new occasion.
    final index = _stops.indexWhere(
      (other) =>
          other.label == stop.label &&
          other.start == stop.start &&
          other.end == stop.end,
    );
    if (index < 0) return;
    setState(() => _stops[index] = _stops[index].copyWith(forecast: days));
  }

  /// Starts the day after the last stop ends, so stops follow each other.
  DateTimeRange _nextFreeRange() {
    final now = DateTime.now();
    var start = DateTime(now.year, now.month, now.day);
    for (final stop in _stops) {
      if (daysBetween(start, stop.end) >= 0) {
        start = DateTime(stop.end.year, stop.end.month, stop.end.day + 1);
      }
    }
    final last = _lastDay();
    if (start.isAfter(last)) start = last;
    var end = DateTime(start.year, start.month, start.day + 2);
    if (end.isAfter(last)) end = last;
    return DateTimeRange(start: start, end: end);
  }

  DateTime _lastDay() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + tripReachDays);
  }

  void _say(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
        if (trailing != null)
          Text(
            trailing!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _PopularDestinations extends StatelessWidget {
  const _PopularDestinations({required this.onPick});

  final ValueChanged<Destination> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.popularDestinations),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final place in popularDestinations)
              ActionChip(
                avatar: Icon(
                  occasionIcon(place.occasion),
                  size: 17,
                  color: colors.primary,
                ),
                label: Text(place.name(language)),
                onPressed: () => onPick(place),
              ),
          ],
        ),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.query,
    required this.worldMatches,
    required this.searchingWorld,
    required this.onPick,
    required this.onPickWorld,
    required this.onSearchWorld,
  });

  final String query;
  final List<CityMatch>? worldMatches;
  final bool searchingWorld;
  final ValueChanged<Destination> onPick;
  final ValueChanged<CityMatch> onPickWorld;
  final VoidCallback onSearchWorld;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final matches = searchDestinations(query).take(8).toList();
    final world = worldMatches;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: colors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (matches.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Text(
                l10n.noDestinationMatch,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          for (final place in matches)
            ListTile(
              leading: Icon(occasionIcon(place.occasion)),
              title: Text(place.name(language)),
              subtitle: place.occasion == 'everyday'
                  ? null
                  : Text(ContextLabels.occasion(l10n, place.occasion)),
              trailing: const Icon(Icons.add_rounded),
              onTap: () => onPick(place),
            ),
          const Divider(height: 1),
          if (world == null)
            ListTile(
              leading: searchingWorld
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.public_rounded, color: colors.primary),
              title: Text(
                l10n.searchOutsideEgypt,
                style: TextStyle(color: colors.primary),
              ),
              onTap: searchingWorld ? null : onSearchWorld,
            )
          else if (world.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.noPlaceFound,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            )
          else
            for (final city in world)
              ListTile(
                leading: const Icon(Icons.public_rounded),
                title: Text(city.label),
                trailing: const Icon(Icons.add_rounded),
                onTap: () => onPickWorld(city),
              ),
        ],
      ),
    );
  }
}

/// One place on the trip: its dates, the weather there, and what the
/// days are for.
class _StopCard extends StatelessWidget {
  const _StopCard({
    required this.stop,
    required this.enabled,
    required this.onDates,
    required this.onRemove,
    required this.onOccasion,
  });

  final TripStop stop;
  final bool enabled;
  final VoidCallback onDates;
  final VoidCallback onRemove;
  final ValueChanged<String> onOccasion;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Icon(
                  Icons.place_outlined,
                  size: 20,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stop.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    InkWell(
                      onTap: enabled ? onDates : null,
                      borderRadius: BorderRadius.circular(AppRadius.small),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                '${tripDateRange(context, stop.start, stop.end)}'
                                ' Â· ${l10n.tripDayCount(stop.days)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.edit_calendar_outlined,
                              size: 15,
                              color: colors.primary,
                              semanticLabel: l10n.changeDates,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.removeStop,
                onPressed: enabled ? onRemove : null,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: TripWeatherPreview(forecast: stop.forecast),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final occasion in tripOccasions)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      avatar: Icon(occasionIcon(occasion), size: 16),
                      label: Text(ContextLabels.occasion(l10n, occasion)),
                      selected: stop.occasion == occasion,
                      onSelected: enabled ? (_) => onOccasion(occasion) : null,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Above a city's days in the plan.
class _CityHeader extends StatelessWidget {
  const _CityHeader({required this.days});

  final List<PlanDay> days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(Icons.place_outlined, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            days.first.city ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium,
          ),
        ),
        Text(
          tripDateRange(context, days.first.date, days.last.date),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _TripEmpty extends StatelessWidget {
  const _TripEmpty({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        children: [
          Icon(
            Icons.luggage_outlined,
            size: 32,
            color: colors.onPrimaryContainer,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingTrip extends StatelessWidget {
  const _LoadingTrip({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
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

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: 18, color: colors.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message, style: TextStyle(color: colors.error)),
        ),
      ],
    );
  }
}
