import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outfit_selctor/data/models/outfit_model.dart';
import 'package:outfit_selctor/features/plans/day_tips.dart';
import 'package:outfit_selctor/features/plans/egypt.dart';
import 'package:outfit_selctor/features/plans/plan_day.dart';
import 'package:outfit_selctor/features/plans/screens/week_routine_screen.dart';
import 'package:outfit_selctor/features/plans/week_routine.dart';
import 'package:outfit_selctor/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

PlanDay _day(
  DateTime date, {
  String weather = 'mild',
  int? high,
  int? low,
}) {
  return PlanDay(
    date: date,
    occasion: 'everyday',
    weather: weather,
    season: 'autumn',
    high: high,
    low: low,
    outfit: OutfitModel(id: 'o', name: '', occasion: 'everyday', items: const []),
  );
}

void main() {
  test('all 27 governorates, with unique ids', () {
    expect(egyptGovernorates, hasLength(27));
    expect(egyptGovernorates.map((g) => g.id).toSet(), hasLength(27));
    expect(Governorate.byId('alexandria')?.nameAr, 'الإسكندرية');
    expect(Governorate.byId('nowhere'), isNull);
  });

  test('governorate search ignores Arabic spelling and the article', () {
    final alex = Governorate.byId('alexandria')!;
    expect(alex.matches('اسكندريه'), isTrue);
    expect(alex.matches('alex'), isTrue);
    expect(alex.matches('cairo'), isFalse);
  });

  test('Ramadan and both Eids are recognised', () {
    expect(egyptSeasonOn(DateTime(2027, 2, 20)), EgyptSeason.ramadan);
    expect(egyptSeasonOn(DateTime(2027, 3, 11)), EgyptSeason.eidFitr);
    expect(egyptSeasonOn(DateTime(2027, 5, 19)), EgyptSeason.eidAdha);
    expect(egyptSeasonOn(DateTime(2027, 5, 20)), isNull);
    expect(egyptSeasonOn(DateTime(2026, 11, 3)), isNull);
  });

  test('tips follow the forecast and the calendar', () {
    final normal = DateTime(2026, 11, 3);
    expect(tipsFor(_day(normal, weather: 'rain')), [DayTip.rain]);
    expect(tipsFor(_day(normal, weather: 'hot', high: 38, low: 27)), [
      DayTip.veryHot,
      DayTip.coolEvening,
    ]);
    expect(tipsFor(_day(normal, high: 24, low: 18)), isEmpty);
    expect(tipsFor(_day(DateTime(2027, 3, 10))), [DayTip.eid]);
  });

  test('a described week replaces only the days it names', () {
    final routine = WeekRoutine.suggested.toggled(DateTime.monday, 'gym');
    final heard = WeekRoutine.fromJson({
      '1': ['university'],
      '7': ['university'],
    });
    final merged = routine.merged(heard);
    expect(merged.occasionsOn(DateTime.monday), ['university']);
    expect(merged.occasionsOn(DateTime.sunday), ['university']);
    expect(merged.occasionsOn(DateTime.friday), ['family']);
  });

  testWidgets('describing the week fills the day chips', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    String? sent;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: WeekRoutineScreen(
          initial: WeekRoutine.empty,
          parse: (message, locale) async {
            sent = message;
            return (
              days: <String, dynamic>{
                '7': ['university'],
              },
              reply: 'University on Sunday.',
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // A new user starts with Friday as a family day.
    expect(find.text('Family'), findsWidgets);

    await tester.enterText(find.byType(TextField), 'uni on sunday');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();

    expect(sent, 'uni on sunday');
    expect(find.text('University on Sunday.'), findsOneWidget);
    final sundayChip = tester.widget<FilterChip>(
      find.ancestor(
        of: find.text('University'),
        matching: find.byType(FilterChip),
      ).at(1),
    );
    expect(sundayChip.selected, isTrue);
    expect(tester.takeException(), isNull);
  });
}
