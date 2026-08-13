import 'package:supabase_flutter/supabase_flutter.dart';
import 'env.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    if (Env.supabaseUrl.isEmpty || Env.supabaseAnonKey.isEmpty) {
      throw StateError(
        'Supabase credentials are missing. '
        'Create a .env file with SUPABASE_URL and SUPABASE_ANON_KEY, '
        'then run with: flutter run --dart-define-from-file=.env',
      );
    }
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
