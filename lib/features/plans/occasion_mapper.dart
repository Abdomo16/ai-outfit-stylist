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
  ];
  for (final rule in rules) {
    if (text.contains(rule.$1)) return rule.$2;
  }
  return null;
}

String occasionForDay(DateTime day, List<({DateTime start, String title})> events) {
  final matches = events.where((event) {
    final start = event.start.toLocal();
    return start.year == day.year && start.month == day.month && start.day == day.day;
  }).toList()
    ..sort((a, b) => a.start.compareTo(b.start));
  for (final event in matches) {
    final occasion = occasionFromTitle(event.title);
    if (occasion != null) return occasion;
  }
  return 'everyday';
}
