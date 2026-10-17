import 'package:device_calendar/device_calendar.dart';

class CalendarService {
  final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin();

  Future<List<({DateTime start, String title})>> eventsBetween(
    DateTime from,
    DateTime to,
  ) async {
    try {
      var allowed = await _plugin.hasPermissions();
      if (allowed.isSuccess != true || allowed.data != true) {
        allowed = await _plugin.requestPermissions();
      }
      if (allowed.isSuccess != true || allowed.data != true) return [];

      final calendars = await _plugin.retrieveCalendars();
      if (calendars.isSuccess != true || calendars.data == null) return [];

      final found = <({DateTime start, String title})>[];
      for (final calendar in calendars.data!) {
        final id = calendar.id;
        if (id == null) continue;
        final result = await _plugin.retrieveEvents(
          id,
          RetrieveEventsParams(startDate: from, endDate: to),
        );
        if (result.isSuccess != true || result.data == null) continue;
        for (final event in result.data!) {
          final title = event.title;
          final start = event.start;
          if (title == null || title.isEmpty || start == null) continue;
          found.add((start: start, title: title));
        }
      }
      return found;
    } catch (_) {
      return [];
    }
  }
}
