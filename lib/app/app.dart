import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_strings.dart';
import '../navigation/route_names.dart';
import 'app_router.dart';

class AIOutfitStylistApp extends StatelessWidget {
  const AIOutfitStylistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute:
          RouteNames.welcome, // Start with welcome, will add auth logic later
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
