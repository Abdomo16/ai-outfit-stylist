import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_strings.dart';
import '../features/auth/screens/auth_wrapper.dart';
import 'app_router.dart';

class AIOutfitStylistApp extends StatelessWidget {
  const AIOutfitStylistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
