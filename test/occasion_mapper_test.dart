import 'package:flutter_test/flutter_test.dart';
import 'package:outfit_selctor/features/plans/occasion_mapper.dart';

void main() {
  test('english and arabic titles map to existing occasions', () {
    expect(occasionFromTitle('Gym session'), 'gym');
    expect(occasionFromTitle('Team meeting'), 'work');
    expect(occasionFromTitle('تمرين الصباح'), 'gym');
    expect(occasionFromTitle('اجتماع الشغل'), 'work');
    expect(occasionFromTitle('Lunch with Sam'), isNull);
  });

  test('a dated event changes that day and other days stay everyday', () {
    final monday = DateTime(2026, 10, 12);
    final events = [
      (start: DateTime(2026, 10, 13, 9), title: 'Gym'),
    ];
    expect(occasionForDay(monday, events), 'everyday');
    expect(occasionForDay(DateTime(2026, 10, 13), events), 'gym');
  });
}
