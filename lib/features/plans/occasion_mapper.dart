import 'week_routine.dart';

/// Maps a calendar title to an occasion the recommender already knows.
/// Returns null when the title does not name one.
String? occasionFromTitle(String title) {
  final text = title.toLowerCase();
  const rules = <(String, String)>[
    ('date night', 'date night'),
    ('birthday', 'party'),
    ('university', 'university'),
    ('lecture', 'university'),
    ('college', 'university'),
    ('workout', 'gym'),
    ('meeting', 'work'),
    ('office', 'work'),
    ('dinner', 'date night'),
    ('party', 'party'),
    ('class', 'university'),
    ('gym', 'gym'),
    ('work', 'work'),
    ('family', 'family'),
    ('friday prayer', 'family'),
    ('eid', 'family'),
    ('عيد ميلاد', 'party'),
    ('محاضرة', 'university'),
    ('جامعة', 'university'),
    ('كلية', 'university'),
    ('تمرين', 'gym'),
    ('اجتماع', 'work'),
    ('مكتب', 'work'),
    ('حفلة', 'party'),
    ('عشاء', 'date night'),
    ('موعد', 'date night'),
    ('حصة', 'university'),
    ('جيم', 'gym'),
    ('شغل', 'work'),
    ('عيلة', 'family'),
    ('عائلة', 'family'),
    ('صلاة الجمعة', 'family'),
    ('العيد', 'family'),
  ];
  for (final rule in rules) {
    if (text.contains(rule.$1)) return rule.$2;
  }
  return null;
}

String occasionForDay(
  DateTime day,
  List<({DateTime start, String title})> events,
) {
  final matches = events.where((event) {
    final start = event.start.toLocal();
    return start.year == day.year &&
        start.month == day.month &&
        start.day == day.day;
  }).toList()..sort((a, b) => a.start.compareTo(b.start));
  for (final event in matches) {
    final occasion = occasionFromTitle(event.title);
    if (occasion != null) return occasion;
  }
  return 'everyday';
}

/// Calendar events from this hour on count as the evening, after the
/// day's routine.
const int eveningHour = 16;

/// The day's occasions in time order: calendar events before
/// [eveningHour], then the user's usual routine for that weekday (a
/// daytime thing such as university or work), then evening events. The
/// first one sets the outfit; the rest come later in the day.
({String main, List<String> later}) occasionsForDay(
  DateTime day,
  List<({DateTime start, String title})> events,
  WeekRoutine routine,
) {
  final matches = events.where((event) {
    final start = event.start.toLocal();
    return start.year == day.year &&
        start.month == day.month &&
        start.day == day.day;
  }).toList()..sort((a, b) => a.start.compareTo(b.start));
  bool evening(({DateTime start, String title}) event) =>
      event.start.toLocal().hour >= eveningHour;
  final all = <String>[
    for (final event in matches)
      if (!evening(event)) ?occasionFromTitle(event.title),
    ...routine.occasionsFor(day),
    for (final event in matches)
      if (evening(event)) ?occasionFromTitle(event.title),
  ];
  final unique = all.toSet().toList();
  if (unique.isEmpty) return (main: 'everyday', later: const []);
  return (main: unique.first, later: unique.skip(1).take(2).toList());
}
