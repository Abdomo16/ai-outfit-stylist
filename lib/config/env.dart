import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  // Values are loaded at runtime from a local `.env` file (gitignored) that
  // is bundled as an asset. `--dart-define` values are used as a fallback.
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ??
      const String.fromEnvironment('SUPABASE_URL');

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ??
      const String.fromEnvironment('SUPABASE_ANON_KEY');

  static const bool isDevelopment = true;

  // Handles correct localhost IP depending on the running platform (Emulator vs Simulator)
  static String get aiBackendUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }
}
