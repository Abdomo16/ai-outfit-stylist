import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';
import '../datasources/weather_service.dart';
import '../../features/plans/egypt.dart';
import '../../features/plans/week_routine.dart';

/// The user's usual week and home governorate. Kept on the account (auth user metadata, so it
/// follows them to a new phone without a table) and copied on the device
/// so it still loads offline.
class RoutineRepository {
  RoutineRepository({SupabaseClient? client})
    : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  static const String _key = 'week_routine';
  static const String _cityKey = WeatherService.homeCityKey;

  Future<WeekRoutine> load() async {
    final remote = _client.auth.currentUser?.userMetadata?[_key];
    if (remote != null) return WeekRoutine.fromJson(remote);
    try {
      final prefs = await SharedPreferences.getInstance();
      final local = prefs.getString(_key);
      if (local != null) return WeekRoutine.fromJson(jsonDecode(local));
    } catch (_) {}
    return WeekRoutine.empty;
  }

  Future<void> save(WeekRoutine routine) async {
    final json = routine.toJson();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(json));
    if (_client.auth.currentUser != null) {
      await _client.auth.updateUser(UserAttributes(data: {_key: json}));
    }
  }

  /// The governorate the forecast is read for, or null to use the phone's
  /// location.
  Future<Governorate?> loadHomeCity() async {
    final metadata = _client.auth.currentUser?.userMetadata;
    if (metadata != null && metadata.containsKey(_cityKey)) {
      final city = Governorate.byId(metadata[_cityKey] as String?);
      // Today's outfit reads the device copy, so keep it in step.
      try {
        final prefs = await SharedPreferences.getInstance();
        city == null
            ? await prefs.remove(_cityKey)
            : await prefs.setString(_cityKey, city.id);
      } catch (_) {}
      return city;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      return Governorate.byId(prefs.getString(_cityKey));
    } catch (_) {
      return null;
    }
  }

  /// Saves [city] as home; null goes back to the phone's location.
  Future<void> saveHomeCity(Governorate? city) async {
    final prefs = await SharedPreferences.getInstance();
    if (city == null) {
      await prefs.remove(_cityKey);
    } else {
      await prefs.setString(_cityKey, city.id);
    }
    if (_client.auth.currentUser != null) {
      await _client.auth.updateUser(UserAttributes(data: {_cityKey: city?.id}));
    }
  }
}
