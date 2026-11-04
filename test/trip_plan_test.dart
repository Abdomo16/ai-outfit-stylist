import 'package:flutter_test/flutter_test.dart';
import 'package:outfit_selctor/data/datasources/weather_service.dart';
import 'package:outfit_selctor/data/models/outfit_model.dart';
import 'package:outfit_selctor/features/plans/destinations.dart';
import 'package:outfit_selctor/features/plans/plan_day.dart';

DailyRow _row(DateTime date, double high, double low, {int code = 0}) {
  return DailyRow(date: date, high: high, low: low, code: code, wind: 10);
}

TripStop _stop(DateTime start, DateTime end) {
  return TripStop(
    label: 'Dahab',
    latitude: 28.5,
    longitude: 34.5,
    start: start,
    end: end,
  );
}

void main() {
  group('destinations', () {
    test('lists the tourist spots and all 27 governorates', () {
      expect(egyptDestinations.length, greaterThan(27 + 10));
      expect(
        egyptDestinations.map((place) => place.id).toSet().length,
        egyptDestinations.length,
      );
      expect(popularDestinations, isNotEmpty);
    });

    test('finds places in English, Arabic and by other names', () {
      List<String> ids(String query) =>
          searchDestinations(query).map((place) => place.id).toList();
      expect(ids('sharm'), contains('sharm'));
      expect(ids('شرم'), contains('sharm'));
      // أ typed as ا, and without the article.
      expect(ids('اسوان'), contains('aswan'));
      expect(ids('ساحل'), contains('north_coast'));
      expect(ids('sahel'), contains('north_coast'));
      expect(ids('العلمين'), contains('north_coast'));
      expect(ids('zzz'), isEmpty);
    });

    test('a trip is dressed for what the place is known for', () {
      Destination byId(String id) =>
          egyptDestinations.firstWhere((place) => place.id == id);
      expect(byId('hurghada').occasion, 'beach');
      expect(byId('red_sea').occasion, 'beach');
      expect(byId('south_sinai').occasion, 'beach');
      expect(byId('luxor').occasion, 'sightseeing');
      expect(byId('siwa').occasion, 'sightseeing');
      expect(byId('cairo').occasion, 'everyday');
      for (final place in egyptDestinations) {
        expect(tripOccasions, contains(place.occasion));
      }
    });
  });

  group('typical weather', () {
    test('averages the same dates over past years', () {
      final rows = [
        _row(DateTime(2023, 12, 20), 20, 8),
        _row(DateTime(2024, 12, 20), 22, 10),
        _row(DateTime(2025, 12, 20), 24, 12),
        _row(DateTime(2025, 12, 21), 30, 20),
      ];
      final days = typicalDays(
        rows,
        start: DateTime(2026, 12, 20),
        end: DateTime(2026, 12, 21),
      );
      expect(days, hasLength(2));
      expect(days.first.date, DateTime(2026, 12, 20));
      expect(days.first.high, 22);
      expect(days.first.low, 10);
      expect(days.first.weather, 'mild');
      expect(days.first.season, 'winter');
      expect(days.every((day) => day.typical), isTrue);
      expect(days.last.weather, 'hot');
    });

    test('is rainy only when it rained on most of those days', () {
      final rows = [
        _row(DateTime(2024, 1, 5), 20, 12, code: 61),
        _row(DateTime(2025, 1, 5), 20, 12, code: 61),
        _row(DateTime(2023, 1, 5), 20, 12),
        _row(DateTime(2024, 1, 6), 20, 12, code: 61),
        _row(DateTime(2025, 1, 6), 20, 12),
      ];
      final days = typicalDays(
        rows,
        start: DateTime(2027, 1, 5),
        end: DateTime(2027, 1, 6),
      );
      expect(days.map((day) => day.weather), ['rain', 'mild']);
    });

    test('29 February reads the 28th of past years', () {
      final days = typicalDays(
        [_row(DateTime(2027, 2, 28), 21, 11)],
        start: DateTime(2028, 2, 29),
        end: DateTime(2028, 2, 29),
      );
      expect(days.single.high, 21);
    });
  });

  test('a cool night asks for a jacket', () {
    expect(needsLayer(null), isFalse);
    expect(needsLayer(22), isFalse);
    expect(needsLayer(coolNight), isTrue);
    expect(needsLayer(9), isTrue);
  });

  group('trip stops', () {
    test('count both ends', () {
      expect(_stop(DateTime(2026, 12, 1), DateTime(2026, 12, 1)).days, 1);
      expect(_stop(DateTime(2026, 12, 1), DateTime(2026, 12, 4)).days, 4);
    });

    test('overlap when they share a day', () {
      final stop = _stop(DateTime(2026, 12, 3), DateTime(2026, 12, 5));
      expect(
        stop.overlaps(DateTime(2026, 12, 5), DateTime(2026, 12, 7)),
        isTrue,
      );
      expect(
        stop.overlaps(DateTime(2026, 12, 1), DateTime(2026, 12, 3)),
        isTrue,
      );
      expect(
        stop.overlaps(DateTime(2026, 12, 1), DateTime(2026, 12, 9)),
        isTrue,
      );
      expect(
        stop.overlaps(DateTime(2026, 12, 6), DateTime(2026, 12, 8)),
        isFalse,
      );
      expect(
        stop.overlaps(DateTime(2026, 11, 30), DateTime(2026, 12, 2)),
        isFalse,
      );
    });

    test('keep their occasion and forecast through copyWith', () {
      final stop = _stop(
        DateTime(2026, 12, 3),
        DateTime(2026, 12, 5),
      ).copyWith(occasion: 'beach', forecast: const []);
      expect(stop.occasion, 'beach');
      expect(stop.copyWith(start: DateTime(2026, 12, 2)).forecast, isEmpty);
      expect(stop.copyWith(clearForecast: true).forecast, isNull);
    });
  });

  test('a plan day remembers that its weather is typical', () {
    final day = PlanDay(
      date: DateTime(2027, 3, 1),
      occasion: 'beach',
      weather: 'mild',
      season: 'spring',
      city: 'Dahab',
      typical: true,
      outfit: OutfitModel(
        id: 'o',
        name: '',
        occasion: 'beach',
        items: const [],
      ),
    );
    expect(PlanDay.fromJson(day.toJson()).typical, isTrue);
    expect(day.copyWith(occasion: 'sightseeing').typical, isTrue);
    final forecast = PlanDay.fromJson({...day.toJson()}..remove('typical'));
    expect(forecast.typical, isFalse);
  });
}
