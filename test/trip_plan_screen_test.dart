import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outfit_selctor/data/datasources/ai_service.dart';
import 'package:outfit_selctor/data/datasources/calendar_service.dart';
import 'package:outfit_selctor/data/datasources/weather_service.dart';
import 'package:outfit_selctor/data/repositories/plan_repository.dart';
import 'package:outfit_selctor/data/repositories/wardrobe_repository.dart';
import 'package:outfit_selctor/data/repositories/wear_log_repository.dart';
import 'package:outfit_selctor/features/plans/cubit/plan_cubit.dart';
import 'package:outfit_selctor/features/plans/screens/trip_plan_screen.dart';
import 'package:outfit_selctor/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _client = SupabaseClient(
  'http://localhost',
  'test',
  authOptions: const AuthClientOptions(autoRefreshToken: false),
);

class _Plans extends PlanRepository {
  _Plans() : super(client: _client);

  @override
  Future<Map<String, dynamic>?> latest(String kind) async => null;
}

class _Unused implements WardrobeRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Locale locale) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: BlocProvider(
      create: (_) => PlanCubit(
        kind: 'trip',
        wardrobe: _Unused(),
        ai: AIService(),
        weather: WeatherService(),
        calendar: CalendarService(),
        wearLog: WearLogRepository(client: _client),
        plans: _Plans(),
      )..loadLatest(),
      child: const TripPlanView(),
    ),
  );
}

void main() {
  testWidgets('shows Egyptian destinations and filters them as you type', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Popular destinations'), findsOneWidget);
    expect(find.text('Sharm El Sheikh'), findsOneWidget);
    expect(find.text('Where are you going?'), findsOneWidget);
    final generate = tester.widget<ElevatedButton>(
      find.byWidgetPredicate((widget) => widget is ElevatedButton),
    );
    expect(generate.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'sahel');
    await tester.pump();
    expect(find.text('North Coast'), findsOneWidget);
    expect(find.text('Beach'), findsOneWidget);
    expect(find.text('Search outside Egypt'), findsOneWidget);
    expect(find.text('Popular destinations'), findsNothing);
  });

  testWidgets('speaks Arabic', (tester) async {
    await tester.pumpWidget(_app(const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.text('أماكن مشهورة'), findsOneWidget);
    expect(find.text('شرم الشيخ'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'اسوان');
    await tester.pump();
    expect(find.text('أسوان'), findsOneWidget);
    expect(find.text('فسح ومزارات'), findsOneWidget);
  });
}
