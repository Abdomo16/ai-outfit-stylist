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

class WeatherService {
  Future<WeatherConditions> current() async {
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

    final position = await Geolocator.getCurrentPosition();
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': position.latitude.toString(),
      'longitude': position.longitude.toString(),
      'current': 'temperature_2m,weather_code,wind_speed_10m',
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Could not read the weather. Try again.');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>;
    return WeatherConditions(
      weather: mapWeather(
        temperature: (current['temperature_2m'] as num).toDouble(),
        weatherCode: (current['weather_code'] as num).toInt(),
        windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      ),
      season: seasonForMonth(DateTime.now().month),
    );
  }
}
