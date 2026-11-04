import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/ai_service.dart';
import '../../../data/datasources/calendar_service.dart';
import '../../../data/datasources/weather_service.dart';
import '../../../data/models/clothing_item_model.dart';
import '../../../data/models/outfit_model.dart';
import '../../../data/repositories/plan_repository.dart';
import '../../../data/repositories/routine_repository.dart';
import '../../../data/repositories/wardrobe_repository.dart';
import '../../../data/repositories/wear_log_repository.dart';
import '../occasion_mapper.dart';
import '../egypt.dart';
import '../plan_day.dart';
import '../week_routine.dart';

class PlanView {
  final bool loading;
  final String? error;
  final String? id;
  final List<PlanDay> days;

  /// The user's usual week; empty until they set it up.
  final WeekRoutine routine;

  /// Where the forecast is read; null uses the phone's location.
  final Governorate? homeCity;

  /// The phone's location could not be read and no governorate is set,
  /// so the user should pick one.
  final bool needsCity;

  const PlanView({
    this.loading = false,
    this.error,
    this.id,
    this.days = const [],
    this.routine = WeekRoutine.empty,
    this.homeCity,
    this.needsCity = false,
  });

  PlanView copyWith({
    bool? loading,
    String? error,
    String? id,
    List<PlanDay>? days,
    WeekRoutine? routine,
    Governorate? homeCity,
    bool clearHomeCity = false,
    bool? needsCity,
    bool clearError = false,
  }) {
    return PlanView(
      loading: loading ?? this.loading,
      error: clearError ? null : error ?? this.error,
      id: id ?? this.id,
      days: days ?? this.days,
      routine: routine ?? this.routine,
      homeCity: clearHomeCity ? null : homeCity ?? this.homeCity,
      needsCity: needsCity ?? (clearError ? false : this.needsCity),
    );
  }
}

class PlanCubit extends Cubit<PlanView> {
  PlanCubit({
    required this.kind,
    required WardrobeRepository wardrobe,
    required AIService ai,
    required WeatherService weather,
    required CalendarService calendar,
    required WearLogRepository wearLog,
    required PlanRepository plans,
    RoutineRepository? routine,
  }) : _wardrobe = wardrobe,
       _ai = ai,
       _weather = weather,
       _calendar = calendar,
       _wearLog = wearLog,
       _plans = plans,
       _routine = routine,
       super(const PlanView());

  final String kind;
  final WardrobeRepository _wardrobe;
  final AIService _ai;
  final WeatherService _weather;
  final CalendarService _calendar;
  final WearLogRepository _wearLog;
  final PlanRepository _plans;
  final RoutineRepository? _routine;
  final Map<String, Set<String>> _locks = {};

  PlanView get ready => state;

  Future<void> loadLatest() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final routine = await _loadRoutine();
      final city = await _loadHomeCity();
      final row = await _plans.latest(kind);
      if (row == null) {
        emit(state.copyWith(loading: false, routine: routine, homeCity: city));
        return;
      }
      final rawDays = row['days'];
      if (rawDays is! List) {
        emit(state.copyWith(loading: false, routine: routine, homeCity: city));
        return;
      }
      emit(
        PlanView(
          routine: routine,
          homeCity: city,
          id: row['id']?.toString(),
          days: [
            for (final day in rawDays)
              if (day is Map) PlanDay.fromJson(Map<String, dynamic>.from(day)),
          ],
        ),
      );
    } catch (error) {
      emit(state.copyWith(loading: false, error: error.toString()));
    }
  }

  Future<void> generateWeek() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final wardrobe = await _requireWardrobe();
      final city = state.homeCity;
      final double latitude;
      final double longitude;
      if (city != null) {
        latitude = city.latitude;
        longitude = city.longitude;
      } else {
        try {
          final position = await _weather.requirePosition();
          latitude = position.latitude;
          longitude = position.longitude;
        } on LocationRequiredException {
          emit(state.copyWith(loading: false, needsCity: true));
          return;
        }
      }
      final forecast = await _weather.forecastAt(
        latitude: latitude,
        longitude: longitude,
        days: 7,
      );
      final events = await _calendar.eventsBetween(
        DateTime.now(),
        DateTime.now().add(const Duration(days: 8)),
      );
      final routine = state.routine;
      final used = await _wornIds();
      final days = <PlanDay>[];
      for (final day in forecast) {
        var (:main, :later) = occasionsForDay(day.date, events, routine);
        // On Eid a free day is spent with family, dressed up.
        final season = egyptSeasonOn(day.date);
        if (main == 'everyday' &&
            (season == EgyptSeason.eidFitr || season == EgyptSeason.eidAdha)) {
          main = 'family';
        }
        final outfit = await _recommend(
          wardrobe: wardrobe,
          occasion: main,
          weather: day.weather,
          season: day.season,
          low: day.low?.round(),
          exclude: used,
        );
        days.add(
          PlanDay(
            date: day.date,
            occasion: main,
            weather: day.weather,
            season: day.season,
            outfit: outfit,
            later: later,
            high: day.high?.round(),
            low: day.low?.round(),
          ),
        );
        used.addAll(_ids(outfit));
      }
      if (days.isEmpty) {
        throw Exception('Could not read the weather. Try again.');
      }
      final id = await _plans.save(
        kind: 'week',
        title: 'This week',
        startsOn: days.first.date,
        days: days.map((day) => day.toJson()).toList(),
      );
      emit(PlanView(id: id, days: days, routine: routine, homeCity: city));
    } catch (error) {
      emit(state.copyWith(loading: false, error: error.toString()));
    }
  }

  Future<void> generateTrip(
    List<TripStop> stops, {
    String occasion = 'everyday',
  }) async {
    if (stops.isEmpty) {
      emit(state.copyWith(error: 'Add at least one city.'));
      return;
    }
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final wardrobe = await _requireWardrobe();
      final used = await _wornIds();
      final days = <PlanDay>[];
      for (final stop in stops) {
        final forecast = await _weather.forecastAt(
          latitude: stop.latitude,
          longitude: stop.longitude,
          start: stop.start,
          end: stop.end,
        );
        for (final day in forecast) {
          final outfit = await _recommend(
            wardrobe: wardrobe,
            occasion: occasion,
            weather: day.weather,
            season: day.season,
            exclude: used,
          );
          days.add(
            PlanDay(
              date: day.date,
              occasion: occasion,
              weather: day.weather,
              season: day.season,
              city: stop.label,
              outfit: outfit,
              high: day.high?.round(),
              low: day.low?.round(),
            ),
          );
          used.addAll(_ids(outfit));
        }
      }
      if (days.isEmpty) {
        throw Exception('Could not read the weather. Try again.');
      }
      final id = await _plans.save(
        kind: 'trip',
        title: stops.map((stop) => stop.label).join(' · '),
        startsOn: days.first.date,
        days: days.map((day) => day.toJson()).toList(),
      );
      emit(
        PlanView(
          id: id,
          days: days,
          routine: state.routine,
          homeCity: state.homeCity,
        ),
      );
    } catch (error) {
      emit(state.copyWith(loading: false, error: error.toString()));
    }
  }

  /// The pieces pinned on [day].
  Set<String> locksFor(PlanDay day) => {...?_locks[isoDate(day.date)]};

  Future<void> toggleLock(PlanDay day, String itemId) async {
    final key = isoDate(day.date);
    final locks = _locks.putIfAbsent(key, () => {});
    if (!locks.add(itemId)) locks.remove(itemId);
    await _replaceDay(day, lockIds: locks.toList());
  }

  Future<void> swapPiece(PlanDay day, String itemId) async {
    final key = isoDate(day.date);
    _locks[key]?.remove(itemId);
    await _replaceDay(
      day,
      lockIds: _locks[key]?.toList() ?? [],
      swapId: itemId,
    );
  }

  Future<void> regenerateDay(PlanDay day) {
    final locks = _locks[isoDate(day.date)]?.toList() ?? const <String>[];
    return _replaceDay(day, lockIds: locks);
  }

  /// Saves the user's usual week, then plans the week with it.
  Future<void> saveRoutine(WeekRoutine routine) async {
    final repository = _routine;
    if (repository == null) return;
    emit(state.copyWith(loading: true, clearError: true));
    try {
      await repository.save(routine);
    } catch (error) {
      emit(state.copyWith(loading: false, error: error.toString()));
      return;
    }
    emit(state.copyWith(routine: routine));
    await generateWeek();
  }

  /// Reads the forecast for [city] from now on (null: the phone's
  /// location) and plans the week again with it.
  Future<void> setHomeCity(Governorate? city) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      await _routine?.saveHomeCity(city);
    } catch (error) {
      emit(state.copyWith(loading: false, error: error.toString()));
      return;
    }
    emit(state.copyWith(homeCity: city, clearHomeCity: city == null));
    await generateWeek();
  }

  /// Dresses [day] for [occasion] instead, keeping its pinned pieces.
  Future<void> changeOccasion(PlanDay day, String occasion) {
    if (occasion == day.occasion) return Future.value();
    final locks = _locks[isoDate(day.date)]?.toList() ?? const <String>[];
    return _replaceDay(
      day.copyWith(
        occasion: occasion,
        later: day.later.where((other) => other != occasion).toList(),
      ),
      lockIds: locks,
    );
  }

  Future<void> markWorn(PlanDay day) => _wearLog.saveWorn(day.outfit, day.date);

  Future<void> _replaceDay(
    PlanDay day, {
    List<String> lockIds = const [],
    String? swapId,
  }) async {
    final current = state;
    if (current.days.isEmpty) return;
    emit(current.copyWith(loading: true, clearError: true));
    try {
      final wardrobe = await _requireWardrobe();
      final used = await _wornIds();
      for (final other in current.days) {
        if (isoDate(other.date) == isoDate(day.date)) continue;
        used.addAll(_ids(other.outfit));
      }
      used.removeAll(lockIds);
      final outfit = await _recommend(
        wardrobe: wardrobe,
        occasion: day.occasion,
        weather: day.weather,
        season: day.season,
        low: day.low,
        exclude: used,
        lockIds: lockIds,
        swapId: swapId,
      );
      final days = [
        for (final existing in current.days)
          isoDate(existing.date) == isoDate(day.date)
              ? day.copyWith(outfit: outfit)
              : existing,
      ];
      if (current.id != null) {
        await _plans.updateDays(
          current.id!,
          days.map((item) => item.toJson()).toList(),
        );
      }
      emit(current.copyWith(loading: false, days: days, clearError: true));
    } catch (error) {
      emit(current.copyWith(loading: false, error: error.toString()));
    }
  }

  Future<WeekRoutine> _loadRoutine() async {
    try {
      return await _routine?.load() ?? WeekRoutine.empty;
    } catch (_) {
      return WeekRoutine.empty;
    }
  }

  Future<Governorate?> _loadHomeCity() async {
    try {
      return await _routine?.loadHomeCity();
    } catch (_) {
      return null;
    }
  }

  Future<List<ClothingItemModel>> _requireWardrobe() async {
    final wardrobe = await _wardrobe.getClothingItems();
    if (wardrobe.isEmpty) {
      throw Exception('Your wardrobe is empty. Please add items first.');
    }
    return wardrobe;
  }

  Future<Set<String>> _wornIds() async {
    try {
      return (await _wearLog.recentItemIds()).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<OutfitModel> _recommend({
    required List<ClothingItemModel> wardrobe,
    required String occasion,
    required String weather,
    required String season,
    required Set<String> exclude,
    int? low,
    List<String> lockIds = const [],
    String? swapId,
  }) {
    final blocked = {...exclude}..removeAll(lockIds);
    return _ai.getRecommendations(
      wardrobe: wardrobe,
      occasion: occasion,
      weather: weather,
      season: season,
      lockIds: lockIds,
      swapId: swapId,
      excludeIds: blocked.toList(),
      layer: needsLayer(low),
    );
  }

  Set<String> _ids(OutfitModel outfit) {
    return outfit.items.map((item) => item.id).whereType<String>().toSet();
  }
}
