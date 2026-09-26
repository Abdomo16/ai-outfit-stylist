import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the app-wide [ThemeMode] and persists it to SharedPreferences.
class ThemeCubit extends Cubit<ThemeMode> {
  static const _prefKey = 'theme_mode';

  ThemeCubit() : super(ThemeMode.system);

  /// Loads the saved theme mode. Call once at app startup.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    switch (saved) {
      case 'light':
        emit(ThemeMode.light);
      case 'dark':
        emit(ThemeMode.dark);
      default:
        emit(ThemeMode.system);
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, mode.name);
  }

  Future<void> toggle() async {
    await setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
