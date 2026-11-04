import 'package:flutter_test/flutter_test.dart';
import 'package:outfit_selctor/features/plans/occasion_mapper.dart';
import 'package:outfit_selctor/features/plans/week_routine.dart';

void main() {
  // 1 November 2026 is a Sunday.
  final sunday = DateTime(2026, 11, 1);
  final tuesday = DateTime(2026, 11, 3);
  final friday = DateTime(2026, 11, 6);

  final routine = WeekRoutine.empty
      .toggled(DateTime.sunday, 'university')
      .toggled(DateTime.sunday, 'gym')
      .toggled(DateTime.tuesday, 'gym');

  test('a day holds at most two occasions and toggles off', () {
    final full = routine.toggled(DateTime.sunday, 'party');
    expect(full.occasionsOn(DateTime.sunday), ['university', 'gym']);
    final off = routine.toggled(DateTime.sunday, 'university');
    expect(off.occasionsOn(DateTime.sunday), ['gym']);
  });

  test('round-trips through json and drops unknown values', () {
    final back = WeekRoutine.fromJson(routine.toJson());
    expect(back.occasionsOn(DateTime.sunday), ['university', 'gym']);
    expect(back.occasionsOn(DateTime.tuesday), ['gym']);
    expect(
      WeekRoutine.fromJson({
        '9': ['gym'],
        '1': ['juggling', 'work'],
      }).days,
      {
        1: ['work'],
      },
    );
    expect(WeekRoutine.fromJson(null).isEmpty, isTrue);
  });

  test('the routine dresses the day, the second activity comes later', () {
    final day = occasionsForDay(sunday, const [], routine);
    expect(day.main, 'university');
    expect(day.later, ['gym']);
  });

  test('an evening event comes after the daytime routine', () {
    final events = [
      (start: DateTime(2026, 11, 1, 19), title: 'Birthday dinner'),
    ];
    final day = occasionsForDay(sunday, events, routine);
    expect(day.main, 'university');
    expect(day.later, ['gym', 'party']);
  });

  test('a morning event comes before the routine', () {
    final events = [(start: DateTime(2026, 11, 3, 9), title: 'Team meeting')];
    final day = occasionsForDay(tuesday, events, routine);
    expect(day.main, 'work');
    expect(day.later, ['gym']);
  });

  test('a free day is everyday', () {
    final day = occasionsForDay(friday, const [], routine);
    expect(day.main, 'everyday');
    expect(day.later, isEmpty);
  });
}
