import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app.dart';
import 'app/app_providers.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env is optional when credentials are provided via --dart-define
  }

  await SupabaseConfig.initialize();

  runApp(const AppProviders(child: AIOutfitStylistApp()));
}
