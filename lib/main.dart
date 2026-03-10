import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/app_providers.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig.initialize();

  runApp(const AppProviders(child: AIOutfitStylistApp()));
}
