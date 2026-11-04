import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/weather_service.dart';
import '../../../l10n/app_localizations.dart';
import '../plan_day.dart';
import 'trip_weather_preview.dart';

/// The days picked for a stop and, when it was read in time, their
/// weather.
typedef TripDates = ({DateTimeRange range, List<DayForecast>? forecast});

DateTime _day(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime _plus(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);

/// Whether [day] belongs to one of the [taken] stops.
bool isTakenDay(DateTime day, List<DateTimeRange> taken) {
  return taken.any(
    (range) =>
        daysBetween(range.start, day) >= 0 && daysBetween(day, range.end) >= 0,
  );
}

/// How many days in a row a stay starting on [start] can last: up to
/// [maxDays], stopping before a [taken] day or past [lastDay]. 0 when
/// [start] itself cannot be picked.
int longestStay(
  DateTime start, {
  required List<DateTimeRange> taken,
  required DateTime lastDay,
  required int maxDays,
}) {
  var length = 0;
  while (length < maxDays) {
    final day = _plus(start, length);
    if (daysBetween(day, lastDay) < 0 || isTakenDay(day, taken)) break;
    length++;
  }
  return length;
}

/// The first Thursday after [today], when the Egyptian weekend starts.
DateTime nextThursday(DateTime today) {
  var day = _plus(today, 1);
  while (day.weekday != DateTime.thursday) {
    day = _plus(day, 1);
  }
  return day;
}

/// Asks when the trip is in [city]: the day of arrival and how many days,
/// with a one-month calendar for any other day. Days in [taken] (the
/// trip's other stops) cannot be picked, and the stay is at most
/// [maxDays] long. Resolves to null when dismissed.
Future<TripDates?> showTripDatesSheet(
  BuildContext context, {
  required String city,
  required DateTimeRange initial,
  required List<DateTimeRange> taken,
  required DateTime lastDay,
  required int maxDays,
  required bool editing,
  required Future<List<DayForecast>> Function(DateTime start, DateTime end)
  loadWeather,
}) {
  return showModalBottomSheet<TripDates>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.large),
      ),
    ),
    builder: (_) => _TripDatesSheet(
      city: city,
      initial: initial,
      taken: taken,
      lastDay: lastDay,
      maxDays: maxDays,
      editing: editing,
      loadWeather: loadWeather,
    ),
  );
}

class _TripDatesSheet extends StatefulWidget {
  const _TripDatesSheet({
    required this.city,
    required this.initial,
    required this.taken,
    required this.lastDay,
    required this.maxDays,
    required this.editing,
    required this.loadWeather,
  });

  final String city;
  final DateTimeRange initial;
  final List<DateTimeRange> taken;
  final DateTime lastDay;
  final int maxDays;
  final bool editing;
  final Future<List<DayForecast>> Function(DateTime start, DateTime end)
  loadWeather;

  @override
  State<_TripDatesSheet> createState() => _TripDatesSheetState();
}

class _TripDatesSheetState extends State<_TripDatesSheet> {
  late final DateTime _today = _day(DateTime.now());
  late DateTime _start = _day(widget.initial.start);
  late int _days = daysBetween(widget.initial.start, widget.initial.end) + 1;
  late DateTime _month = DateTime(_start.year, _start.month);

  bool _calendarOpen = false;

  /// In the calendar, the arrival was tapped and the last day comes next.
  bool _pickingEnd = false;

  /// The weather for [_forecastFor]; null while it is read.
  List<DayForecast>? _forecast;
  String? _forecastFor;
  Timer? _debounce;

  DateTime get _end => _plus(_start, _days - 1);

  String get _rangeKey => '${isoDate(_start)}/${isoDate(_end)}';

  int _longest(DateTime start) => longestStay(
    start,
    taken: widget.taken,
    lastDay: widget.lastDay,
    maxDays: widget.maxDays,
  );

  bool _canStart(DateTime day) =>
      daysBetween(_today, day) >= 0 && _longest(day) > 0;

  @override
  void initState() {
    super.initState();
    final longest = _longest(_start);
    if (longest == 0) {
      _days = 1;
    } else if (_days > longest) {
      _days = longest;
    }
    _forecastFor = _rangeKey;
    _debounce = Timer(Duration.zero, () => _fetchWeather(_rangeKey));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Reads the weather for the picked days, once the user stops changing
  /// them.
  void _readWeather() {
    _debounce?.cancel();
    final key = _rangeKey;
    if (key == _forecastFor && _forecast != null) return;
    setState(() {
      _forecast = null;
      _forecastFor = key;
    });
    _debounce = Timer(
      const Duration(milliseconds: 450),
      () => _fetchWeather(key),
    );
  }

  Future<void> _fetchWeather(String key) async {
    final start = _start;
    final end = _end;
    List<DayForecast> days;
    try {
      days = await widget.loadWeather(start, end);
    } catch (_) {
      days = const [];
    }
    if (!mounted || _forecastFor != key) return;
    setState(() => _forecast = days);
  }

  void _setStart(DateTime day, {int? days}) {
    final longest = _longest(day);
    if (longest == 0) return;
    setState(() {
      _start = day;
      _days = (days ?? _days).clamp(1, longest);
      _month = DateTime(day.year, day.month);
    });
    _readWeather();
  }

  void _setDays(int days) {
    setState(() => _days = days.clamp(1, _longest(_start)));
    _readWeather();
  }

  void _tapCalendarDay(DateTime day) {
    if (!_pickingEnd || daysBetween(_start, day) < 0) {
      _setStart(day, days: 1);
      setState(() => _pickingEnd = true);
      return;
    }
    final length = daysBetween(_start, day) + 1;
    if (length <= _longest(_start)) {
      _setDays(length);
      setState(() => _pickingEnd = false);
    } else {
      // Past a taken day or the trip's length: start again from here.
      _setStart(day, days: 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final longest = _longest(_start);
    final thursday = nextThursday(_today);
    final tomorrow = _plus(_today, 1);
    final dayCount = l10n.tripDayCount(_days);

    final starts = <(String, DateTime)>[
      if (daysBetween(_day(widget.initial.start), _today) != 0 &&
          daysBetween(_day(widget.initial.start), tomorrow) != 0 &&
          daysBetween(_day(widget.initial.start), thursday) != 0)
        (
          DateFormat.MMMEd(locale).format(widget.initial.start),
          _day(widget.initial.start),
        ),
      (l10n.today, _today),
      (l10n.tomorrow, tomorrow),
      if (daysBetween(thursday, tomorrow) != 0)
        (DateFormat.EEEE(locale).format(thursday), thursday),
    ];
    final weekend = _start.weekday == DateTime.thursday && _days == 3;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.tripDatesTitle(widget.city),
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.tripDatesHint,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Label(l10n.arriving),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (label, day) in starts)
                        ChoiceChip(
                          label: Text(label),
                          selected:
                              !_calendarOpen && daysBetween(day, _start) == 0,
                          onSelected: _canStart(day)
                              ? (_) {
                                  setState(() {
                                    _calendarOpen = false;
                                    _pickingEnd = false;
                                  });
                                  _setStart(day);
                                }
                              : null,
                        ),
                      ChoiceChip(
                        avatar: const Icon(
                          Icons.calendar_month_outlined,
                          size: 18,
                        ),
                        label: Text(l10n.otherDay),
                        selected: _calendarOpen,
                        onSelected: (_) => setState(() {
                          _calendarOpen = !_calendarOpen;
                          _pickingEnd = false;
                          _month = DateTime(_start.year, _start.month);
                        }),
                      ),
                    ],
                  ),
                  if (_calendarOpen) ...[
                    const SizedBox(height: 12),
                    _MonthCalendar(
                      month: _month,
                      today: _today,
                      lastDay: widget.lastDay,
                      start: _start,
                      end: _end,
                      hint: _pickingEnd
                          ? l10n.calendarPickEnd
                          : l10n.calendarPickStart,
                      // Picking the last day, the days the stay can run to
                      // are open too.
                      isOpen: (day) =>
                          (_pickingEnd &&
                              daysBetween(_start, day) >= 0 &&
                              daysBetween(_start, day) < longest) ||
                          _canStart(day),
                      onMonth: (month) => setState(() => _month = month),
                      onTap: _tapCalendarDay,
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _Label(l10n.howManyDays)),
                      IconButton.filledTonal(
                        tooltip: l10n.fewerDays,
                        onPressed: _days > 1 ? () => _setDays(_days - 1) : null,
                        icon: const Icon(Icons.remove_rounded),
                      ),
                      SizedBox(
                        width: 48,
                        child: Text(
                          '$_days',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall,
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: l10n.moreDays,
                        onPressed: _days < longest
                            ? () => _setDays(_days + 1)
                            : null,
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        avatar: const Icon(Icons.weekend_outlined, size: 18),
                        label: Text(l10n.presetWeekend),
                        selected: weekend,
                        onSelected: _longest(thursday) >= 3
                            ? (_) => _setStart(thursday, days: 3)
                            : null,
                      ),
                      ChoiceChip(
                        label: Text(l10n.tripDayCount(3)),
                        selected: _days == 3 && !weekend,
                        onSelected: longest >= 3 ? (_) => _setDays(3) : null,
                      ),
                      ChoiceChip(
                        label: Text(l10n.presetWeek),
                        selected: _days == 7,
                        onSelected: longest >= 7 ? (_) => _setDays(7) : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _Summary(
                    start: _start,
                    end: _end,
                    dayCount: dayCount,
                    forecast: _forecast,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: longest == 0
                    ? null
                    : () => Navigator.pop<TripDates>(context, (
                        range: DateTimeRange(start: _start, end: _end),
                        forecast: _forecastFor == _rangeKey ? _forecast : null,
                      )),
                icon: Icon(
                  widget.editing ? Icons.check_rounded : Icons.add_rounded,
                  size: 20,
                ),
                label: Text(
                  widget.editing
                      ? l10n.saveTripDates(dayCount)
                      : l10n.addTripDays(dayCount, widget.city),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleSmall);
  }
}

/// The picked days in words, with their weather.
class _Summary extends StatelessWidget {
  const _Summary({
    required this.start,
    required this.end,
    required this.dayCount,
    required this.forecast,
  });

  final DateTime start;
  final DateTime end;
  final String dayCount;
  final List<DayForecast>? forecast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final format = DateFormat.MMMEd(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final sameDay = daysBetween(start, end) == 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_rounded, size: 20, color: colors.primary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  format.format(start),
                  style: theme.textTheme.titleSmall,
                ),
              ),
              if (!sameDay) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Flexible(
                  child: Text(
                    format.format(end),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
              const Spacer(),
              Text(
                dayCount,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TripWeatherPreview(forecast: forecast),
        ],
      ),
    );
  }
}

/// One month of days. Days [isOpen] rejects are greyed out and cannot be
/// tapped; [start] to [end] is highlighted.
class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.month,
    required this.today,
    required this.lastDay,
    required this.start,
    required this.end,
    required this.hint,
    required this.isOpen,
    required this.onMonth,
    required this.onTap,
  });

  final DateTime month;
  final DateTime today;
  final DateTime lastDay;
  final DateTime start;
  final DateTime end;
  final String hint;
  final bool Function(DateTime day) isOpen;
  final ValueChanged<DateTime> onMonth;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final material = MaterialLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final firstWeekday = material.firstDayOfWeekIndex; // 0 = Sunday
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    // DateTime.weekday is 1 (Monday) to 7 (Sunday); make Sunday 0.
    final offset =
        (DateTime(month.year, month.month).weekday % 7 - firstWeekday + 7) % 7;
    final canGoBack =
        month.year > today.year ||
        (month.year == today.year && month.month > today.month);
    final canGoOn =
        month.year < lastDay.year ||
        (month.year == lastDay.year && month.month < lastDay.month);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: material.previousMonthTooltip,
                onPressed: canGoBack
                    ? () => onMonth(DateTime(month.year, month.month - 1))
                    : null,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  DateFormat.yMMMM(locale).format(month),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              IconButton(
                tooltip: material.nextMonthTooltip,
                onPressed: canGoOn
                    ? () => onMonth(DateTime(month.year, month.month + 1))
                    : null,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  size: 17,
                  color: colors.onPrimaryContainer,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Text(
                    material.narrowWeekdays[(firstWeekday + i) % 7],
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var i = 0; i < offset; i++) const SizedBox.shrink(),
              for (var d = 1; d <= daysInMonth; d++)
                _DayCell(
                  day: DateTime(month.year, month.month, d),
                  today: today,
                  start: start,
                  end: end,
                  open: isOpen(DateTime(month.year, month.month, d)),
                  onTap: onTap,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.today,
    required this.start,
    required this.end,
    required this.open,
    required this.onTap,
  });

  final DateTime day;
  final DateTime today;
  final DateTime start;
  final DateTime end;
  final bool open;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final fromStart = daysBetween(start, day);
    final toEnd = daysBetween(day, end);
    final inRange = fromStart >= 0 && toEnd >= 0;
    final isEdge = fromStart == 0 || toEnd == 0;
    final isToday = daysBetween(today, day) == 0;

    final Color textColor;
    if (isEdge) {
      textColor = colors.onPrimary;
    } else if (!open) {
      textColor = colors.onSurface.withValues(alpha: 0.28);
    } else if (inRange) {
      textColor = colors.primary;
    } else {
      textColor = colors.onSurface;
    }

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: isEdge
            ? colors.primary
            : inRange
            ? colors.primary.withValues(alpha: 0.14)
            : Colors.transparent,
        shape: CircleBorder(
          side: isToday && !isEdge
              ? BorderSide(color: colors.primary)
              : BorderSide.none,
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: open ? () => onTap(day) : null,
          child: Center(
            child: Text(
              '${day.day}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: isEdge || inRange ? FontWeight.w600 : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
