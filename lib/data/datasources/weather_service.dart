import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/plans/egypt.dart';

class WeatherConditions {
  final String weather;
  final String season;

  const WeatherConditions({required this.weather, required this.season});
}

class LocationRequiredException implements Exception {
  final String message;

  const LocationRequiredException([
    this.message = "Allow location to build today's outfit.",
  ]);
}

String mapWeather({
  required double temperature,
  required int weatherCode,
  required double windSpeed,
}) {
  if (_isWet(weatherCode)) return 'rain';
  if (temperature >= 28) return 'hot';
  if (temperature <= 16 || windSpeed >= 40) return 'cold';
  return 'mild';
}

String seasonForMonth(int month) {
  if (month == 12 || month <= 2) return 'winter';
  if (month <= 5) return 'spring';
  if (month <= 8) return 'summer';
  return 'autumn';
}

bool _isWet(int code) {
  return (code >= 51 && code <= 67) ||
      (code >= 71 && code <= 77) ||
      (code >= 80 && code <= 86) ||
      (code >= 95 && code <= 99);
}

String isoDate(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

String _isoDate(DateTime date) => isoDate(date);

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// [date] [years] years earlier; 29 February becomes the 28th.
DateTime _yearsBefore(DateTime date, int years) {
  final day = date.month == 2 && date.day == 29 ? 28 : date.day;
  return DateTime(date.year - years, date.month, day);
}

/// One day of Open-Meteo's daily weather.
class DailyRow {
  final DateTime date;
  final double high;
  final double? low;
  final int code;
  final double wind;

  const DailyRow({
    required this.date,
    required this.high,
    this.low,
    required this.code,
    required this.wind,
  });

  DayForecast toForecast() => DayForecast(
    date: date,
    weather: mapWeather(temperature: high, weatherCode: code, windSpeed: wind),
    season: seasonForMonth(date.month),
    high: high,
    low: low,
  );
}

/// Days [start] to [end] as they usually are: each day's past [rows] on
/// the same date, averaged. Rainy when it rained on most of them.
List<DayForecast> typicalDays(
  List<DailyRow> rows, {
  required DateTime start,
  required DateTime end,
}) {
  String key(DateTime date) {
    final day = date.month == 2 && date.day == 29 ? 28 : date.day;
    return '${date.month}-$day';
  }

  double average(Iterable<double> values) =>
      values.reduce((a, b) => a + b) / values.length;

  final byDate = <String, List<DailyRow>>{};
  for (final row in rows) {
    byDate.putIfAbsent(key(row.date), () => []).add(row);
  }
  final days = <DayForecast>[];
  for (
    var date = _dateOnly(start);
    !date.isAfter(end);
    date = DateTime(date.year, date.month, date.day + 1)
  ) {
    final past = byDate[key(date)];
    if (past == null) continue;
    final lows = [for (final row in past) ?row.low];
    final wet = past.where((row) => _isWet(row.code)).length * 2 > past.length;
    final high = average(past.map((row) => row.high));
    days.add(
      DayForecast(
        date: date,
        weather: mapWeather(
          temperature: high,
          // 61 is moderate rain, 0 a clear sky.
          weatherCode: wet ? 61 : 0,
          windSpeed: average(past.map((row) => row.wind)),
        ),
        season: seasonForMonth(date.month),
        high: high,
        low: lows.isEmpty ? null : average(lows),
        typical: true,
      ),
    );
  }
  return days;
}

class WeatherService {
  /// Prefs key of the home governorate the user picked in the week plan.
  static const String homeCityKey = 'home_city';

  /// Open-Meteo forecasts this many days, today included.
  static const int forecastHorizon = 16;

  /// Years averaged for the typical weather past [forecastHorizon].
  static const int typicalYears = 3;

  static const String _dailyFields =
      'weather_code,temperature_2m_max,temperature_2m_min,wind_speed_10m_max';

  /// Today's weather at the home governorate when one is set, otherwise
  /// at the phone's location.
  Future<WeatherConditions> current() async {
    Governorate? home;
    try {
      final prefs = await SharedPreferences.getInstance();
      home = Governorate.byId(prefs.getString(homeCityKey));
    } catch (_) {}
    final double latitude;
    final double longitude;
    if (home != null) {
      latitude = home.latitude;
      longitude = home.longitude;
    } else {
      final position = await requirePosition();
      latitude = position.latitude;
      longitude = position.longitude;
    }
    final days = await forecastAt(
      latitude: latitude,
      longitude: longitude,
      days: 1,
    );
    return WeatherConditions(
      weather: days.first.weather,
      season: days.first.season,
    );
  }

  Future<Position> requirePosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw const LocationRequiredException();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationRequiredException();
    }

    return Geolocator.getCurrentPosition();
  }

  Future<List<DayForecast>> forecastAt({
    required double latitude,
    required double longitude,
    int days = 7,
    DateTime? start,
    DateTime? end,
  }) async {
    final params = <String, String>{
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'daily': _dailyFields,
      'timezone': 'auto',
    };
    if (start != null && end != null) {
      params['start_date'] = _isoDate(start);
      params['end_date'] = _isoDate(end);
    } else {
      params['forecast_days'] = days.toString();
    }
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', params);
    return [for (final row in await _dailyRows(uri)) row.toForecast()];
  }

  /// Days [start] to [end] at a place: the forecast as far as it reaches,
  /// then the typical weather for the rest (see [typicalAt]).
  Future<List<DayForecast>> tripDays({
    required double latitude,
    required double longitude,
    required DateTime start,
    required DateTime end,
    DateTime? today,
  }) async {
    final now = _dateOnly(today ?? DateTime.now());
    final lastForecast = now.add(const Duration(days: forecastHorizon - 1));
    final days = <DayForecast>[];
    if (!start.isAfter(lastForecast)) {
      days.addAll(
        await forecastAt(
          latitude: latitude,
          longitude: longitude,
          start: start,
          end: end.isAfter(lastForecast) ? lastForecast : end,
        ),
      );
    }
    if (end.isAfter(lastForecast)) {
      days.addAll(
        await typicalAt(
          latitude: latitude,
          longitude: longitude,
          start: start.isAfter(lastForecast)
              ? start
              : lastForecast.add(const Duration(days: 1)),
          end: end,
          today: now,
        ),
      );
    }
    return days;
  }

  /// The usual weather on days [start] to [end], too far ahead for a
  /// forecast: the same dates over the last [typicalYears] years, averaged.
  Future<List<DayForecast>> typicalAt({
    required double latitude,
    required double longitude,
    required DateTime start,
    required DateTime end,
    DateTime? today,
  }) async {
    // The archive lags the present by a few days.
    final latest = _dateOnly(
      today ?? DateTime.now(),
    ).subtract(const Duration(days: 7));
    // One small request per year: a single range across all the years is
    // slow enough for the archive to time out.
    final years = await Future.wait([
      for (var back = 1; back <= typicalYears; back++)
        _archiveRows(
          latitude: latitude,
          longitude: longitude,
          from: _yearsBefore(start, back),
          to: _yearsBefore(end, back),
          latest: latest,
        ),
    ]);
    final rows = [for (final year in years) ...year];
    if (rows.isEmpty) {
      throw Exception('Could not read the weather. Try again.');
    }
    return typicalDays(rows, start: start, end: end);
  }

  /// The archive's days [from] to [to], up to [latest]; empty when it
  /// cannot be read, as the other years still give a typical day.
  Future<List<DailyRow>> _archiveRows({
    required double latitude,
    required double longitude,
    required DateTime from,
    required DateTime to,
    required DateTime latest,
  }) async {
    if (to.isAfter(latest)) to = latest;
    if (from.isAfter(to)) return [];
    final uri = Uri.https('archive-api.open-meteo.com', '/v1/archive', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'daily': _dailyFields,
      'timezone': 'auto',
      'start_date': _isoDate(from),
      'end_date': _isoDate(to),
    });
    try {
      return await _dailyRows(uri);
    } catch (_) {
      return [];
    }
  }

  Future<List<DailyRow>> _dailyRows(Uri uri) async {
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Could not read the weather. Try again.');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;
    final dates = (daily['time'] as List<dynamic>).cast<String>();
    final highs = daily['temperature_2m_max'] as List<dynamic>;
    final lows = daily['temperature_2m_min'] as List<dynamic>?;
    final codes = daily['weather_code'] as List<dynamic>;
    final winds = daily['wind_speed_10m_max'] as List<dynamic>;
    return [
      for (var i = 0; i < dates.length; i++)
        // The archive has gaps (null) for days it has not filled in yet.
        if (highs[i] != null && codes[i] != null)
          DailyRow(
            date: DateTime.parse(dates[i]),
            high: (highs[i] as num).toDouble(),
            low: (lows?[i] as num?)?.toDouble(),
            code: (codes[i] as num).toInt(),
            wind: (winds[i] as num?)?.toDouble() ?? 0,
          ),
    ];
  }

  Future<List<CityMatch>> searchCities(String name) async {
    final query = name.trim();
    if (query.isEmpty) return [];
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': query,
      'count': '5',
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Could not read the weather. Try again.');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final results = json['results'] as List<dynamic>? ?? [];
    return [
      for (final raw in results)
        if (raw is Map<String, dynamic>)
          CityMatch(
            name: raw['name'] as String? ?? query,
            country: raw['country'] as String? ?? '',
            latitude: (raw['latitude'] as num).toDouble(),
            longitude: (raw['longitude'] as num).toDouble(),
          ),
    ];
  }
}

class DayForecast {
  final DateTime date;
  final String weather;
  final String season;

  /// Day's highest and lowest temperature, in °C.
  final double? high;
  final double? low;

  /// The usual weather for the date rather than a forecast, as it is too
  /// far ahead.
  final bool typical;

  const DayForecast({
    required this.date,
    required this.weather,
    required this.season,
    this.high,
    this.low,
    this.typical = false,
  });
}

class CityMatch {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  const CityMatch({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  String get label => country.isEmpty ? name : '$name, $country';
}
