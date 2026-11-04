/// What the user usually does on each weekday, e.g. university on Sunday
/// and Monday, gym on Tuesday.
///
/// Each day holds up to [maxPerDay] occasions. The first one sets the day's
/// outfit; the others are shown as "later" so the user can pack for them.
class WeekRoutine {
  /// Keyed by [DateTime.weekday] (1 = Monday ... 7 = Sunday).
  final Map<int, List<String>> days;

  const WeekRoutine(this.days);

  static const WeekRoutine empty = WeekRoutine({});

  static const int maxPerDay = 2;

  /// Occasions a day can hold, in the order they are offered. A day with
  /// none is a free day and gets an everyday outfit.
  static const List<String> occasions = [
    'university',
    'work',
    'gym',
    'date night',
    'party',
    'formal',
    // Friday prayer, family visits and Eid.
    'family',
  ];

  /// Saturday first, as the week is counted in Egypt.
  static const List<int> weekOrder = [
    DateTime.saturday,
    DateTime.sunday,
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
  ];

  /// A first suggestion for a user who has not set their week: Friday
  /// with the family, as most Egyptians spend it.
  static const WeekRoutine suggested = WeekRoutine({
    DateTime.friday: ['family'],
  });

  bool get isEmpty => days.values.every((list) => list.isEmpty);

  List<String> occasionsOn(int weekday) => days[weekday] ?? const [];

  List<String> occasionsFor(DateTime date) => occasionsOn(date.weekday);

  /// [occasion] added to or removed from [weekday]. Adding past
  /// [maxPerDay] leaves the day as it is.
  WeekRoutine toggled(int weekday, String occasion) {
    final current = [...occasionsOn(weekday)];
    if (!current.remove(occasion)) {
      if (current.length >= maxPerDay) return this;
      current.add(occasion);
    }
    return WeekRoutine({...days, weekday: current});
  }

  /// This routine with every day [other] names replaced by [other]'s.
  WeekRoutine merged(WeekRoutine other) {
    return WeekRoutine({
      ...days,
      for (final entry in other.days.entries)
        if (entry.value.isNotEmpty) entry.key: entry.value,
    });
  }

  Map<String, dynamic> toJson() => {
    for (final entry in days.entries)
      if (entry.value.isNotEmpty) '${entry.key}': entry.value,
  };

  factory WeekRoutine.fromJson(Object? json) {
    if (json is! Map) return empty;
    final days = <int, List<String>>{};
    for (final entry in json.entries) {
      final weekday = int.tryParse(entry.key.toString());
      final value = entry.value;
      if (weekday == null || weekday < 1 || weekday > 7 || value is! List) {
        continue;
      }
      days[weekday] = [
        for (final occasion in value)
          if (occasion is String && occasions.contains(occasion)) occasion,
      ].take(maxPerDay).toList();
    }
    return WeekRoutine(days);
  }
}
