import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';
import '../core/locale/locale_cubit.dart';
import '../core/constants/app_strings.dart';
import '../features/auth/screens/auth_wrapper.dart';
import '../l10n/app_localizations.dart';
import 'app_router.dart';

class AIOutfitStylistApp extends StatelessWidget {
  const AIOutfitStylistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit()..load()),
        BlocProvider(create: (context) => LocaleCubit()..load()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp(
                title: AppStrings.appName,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                locale: locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                debugShowCheckedModeBanner: false,
                home: const AuthWrapper(),
                onGenerateRoute: AppRouter.generateRoute,
              );
            },
          );
        },
      ),
    );
  }
}
