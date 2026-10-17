import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

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

class WeatherService {
  Future<WeatherConditions> current() async {
    final position = await requirePosition();
    final days = await forecastAt(
      latitude: position.latitude,
      longitude: position.longitude,
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
      'daily': 'weather_code,temperature_2m_max,wind_speed_10m_max',
      'timezone': 'auto',
    };
    if (start != null && end != null) {
      params['start_date'] = _isoDate(start);
      params['end_date'] = _isoDate(end);
    } else {
      params['forecast_days'] = days.toString();
    }
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', params);
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Could not read the weather. Try again.');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;
    final dates = (daily['time'] as List<dynamic>).cast<String>();
    final temps = (daily['temperature_2m_max'] as List<dynamic>);
    final codes = (daily['weather_code'] as List<dynamic>);
    final winds = (daily['wind_speed_10m_max'] as List<dynamic>);
    return [
      for (var i = 0; i < dates.length; i++)
        DayForecast(
          date: DateTime.parse(dates[i]),
          weather: mapWeather(
            temperature: (temps[i] as num).toDouble(),
            weatherCode: (codes[i] as num).toInt(),
            windSpeed: (winds[i] as num).toDouble(),
          ),
          season: seasonForMonth(DateTime.parse(dates[i]).month),
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

  const DayForecast({
    required this.date,
    required this.weather,
    required this.season,
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
