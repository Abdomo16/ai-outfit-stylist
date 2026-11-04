import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outfit_selctor/data/datasources/weather_service.dart';
import 'package:outfit_selctor/features/plans/plan_day.dart';
import 'package:outfit_selctor/features/plans/widgets/trip_dates_sheet.dart';
import 'package:outfit_selctor/l10n/app_localizations.dart';

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime _inDays(int days) {
  final today = _today();
  return DateTime(today.year, today.month, today.day + days);
}

void main() {
  group('date helpers', () {
    final taken = [DateTimeRange(start: _inDays(5), end: _inDays(7))];

    test('a stay stops before a taken day, the limit or the last day', () {
      expect(
        longestStay(
          _inDays(1),
          taken: taken,
          lastDay: _inDays(100),
          maxDays: 21,
        ),
        4,
      );
      expect(
        longestStay(
          _inDays(6),
          taken: taken,
          lastDay: _inDays(100),
          maxDays: 21,
        ),
        0,
      );
      expect(
        longestStay(
          _inDays(8),
          taken: taken,
          lastDay: _inDays(100),
          maxDays: 3,
        ),
        3,
      );
      expect(
        longestStay(_inDays(8), taken: taken, lastDay: _inDays(9), maxDays: 21),
        2,
      );
    });

    test('the weekend starts on the next Thursday', () {
      final wednesday = DateTime(2026, 11, 4);
      expect(nextThursday(wednesday), DateTime(2026, 11, 5));
      final thursday = DateTime(2026, 11, 5);
      expect(nextThursday(thursday), DateTime(2026, 11, 12));
    });

    test('days are counted across the daylight saving change', () {
      // Egypt's clocks went back on 29 October 2026.
      expect(daysBetween(DateTime(2026, 10, 28), DateTime(2026, 10, 31)), 3);
      expect(
        TripStop(
          label: 'Cairo',
          latitude: 30,
          longitude: 31,
          start: DateTime(2026, 10, 28),
          end: DateTime(2026, 10, 31),
        ).days,
        4,
      );
    });
  });

  group('sheet', () {
    Future<TripDates?> open(
      WidgetTester tester, {
      List<DateTimeRange> taken = const [],
      bool editing = false,
    }) async {
      TripDates? result;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showTripDatesSheet(
                  context,
                  city: 'Dahab',
                  initial: DateTimeRange(start: _inDays(1), end: _inDays(3)),
                  taken: taken,
                  lastDay: _inDays(300),
                  maxDays: 21,
                  editing: editing,
                  loadWeather: (start, end) async => [
                    DayForecast(
                      date: start,
                      weather: 'hot',
                      season: 'autumn',
                      high: 31,
                      low: 19,
                    ),
                  ],
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('says what to do and adds the picked days', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.reset);

      await open(tester);
      expect(find.text('When are you in Dahab?'), findsOneWidget);
      expect(find.text('Tomorrow'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Add 3 days in Dahab'), findsOneWidget);
      // The weather for the picked days shows once read.
      expect(find.text('Hot'), findsOneWidget);

      await tester.tap(find.byTooltip('More days'));
      await tester.pumpAndSettle();
      expect(find.text('Add 4 days in Dahab'), findsOneWidget);

      await tester.tap(find.text('A week'));
      await tester.pumpAndSettle();
      expect(find.text('Add 7 days in Dahab'), findsOneWidget);
    });

    testWidgets('cannot run into another stop', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.reset);

      await open(
        tester,
        taken: [DateTimeRange(start: _inDays(4), end: _inDays(6))],
      );
      // Tomorrow to the day before the other stop: 3 days at most.
      final more = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.add_rounded).first,
          matching: find.byType(IconButton),
        ),
      );
      expect(more.onPressed, isNull);
      final week = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('A week'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(week.onSelected, isNull);
    });

    testWidgets('the calendar picks arrival then the last day', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.reset);

      await open(tester);
      await tester.tap(find.text('Other day'));
      await tester.pumpAndSettle();
      expect(find.text('Tap the day you arrive'), findsOneWidget);

      Future<void> tapDay(DateTime day) async {
        await tester.tap(
          find.descendant(
            of: find.byType(GridView),
            matching: find.text('${day.day}'),
          ),
        );
        await tester.pumpAndSettle();
      }

      final arrive = _inDays(2);
      final leave = _inDays(6);
      await tapDay(arrive);
      expect(find.text('Now tap your last day there'), findsOneWidget);
      expect(find.text('Add 1 day in Dahab'), findsOneWidget);
      if (leave.month != arrive.month) {
        await tester.tap(find.byTooltip('Next month'));
        await tester.pumpAndSettle();
      }
      await tapDay(leave);
      expect(find.text('Tap the day you arrive'), findsOneWidget);
      expect(find.text('Add 5 days in Dahab'), findsOneWidget);
    });
  });
}
