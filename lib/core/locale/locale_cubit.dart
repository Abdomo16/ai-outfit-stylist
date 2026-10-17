import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  static const _prefKey = 'app_locale';

  LocaleCubit() : super(const Locale('en'));

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    emit(Locale(saved == 'ar' ? 'ar' : 'en'));
  }

  Future<void> setLocale(Locale locale) async {
    emit(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
  }
}
