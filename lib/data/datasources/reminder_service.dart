import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// One evening reminder: what to wear on [day], shown the evening before.
typedef EveningReminder = ({DateTime day, String title, String body});

/// The evening reminder of tomorrow's planned outfit, shown at 9 pm.
class ReminderService {
  ReminderService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const String _enabledKey = 'evening_reminder';
  static const int eveningHour = 21;

  /// Reminders use ids from here up, one per planned day.
  static const int _firstId = 7100;
  static const int _maxDays = 14;

  static bool _ready = false;

  Future<bool> isEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_enabledKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Turns the reminder on or off. Turning it on asks for permission to
  /// notify; returns false when the user refuses.
  Future<bool> setEnabled(bool enabled) async {
    if (enabled && !await _requestPermission()) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
    if (!enabled) await cancelAll();
    return true;
  }

  /// Replaces the scheduled reminders with [reminders]. Days whose evening
  /// before has passed are skipped. Does nothing while the reminder is off.
  Future<void> schedule(
    List<EveningReminder> reminders, {
    required String channelName,
  }) async {
    if (!await isEnabled()) return;
    await _init();
    await cancelAll();
    final now = tz.TZDateTime.now(tz.local);
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'evening_outfit',
        channelName,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    for (var i = 0; i < reminders.length && i < _maxDays; i++) {
      final reminder = reminders[i];
      final eve = reminder.day.subtract(const Duration(days: 1));
      final at = tz.TZDateTime(
        tz.local,
        eve.year,
        eve.month,
        eve.day,
        eveningHour,
      );
      if (!at.isAfter(now)) continue;
      await _plugin.zonedSchedule(
        _firstId + i,
        reminder.title,
        reminder.body,
        at,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelAll() async {
    await _init();
    for (var i = 0; i < _maxDays; i++) {
      await _plugin.cancel(_firstId + i);
    }
  }

  Future<void> _init() async {
    if (_ready) return;
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (error) {
      // Most users are in Egypt; better than UTC if the zone is unknown.
      debugPrint('ReminderService: local time zone unknown ($error)');
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    }
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  Future<bool> _requestPermission() async {
    await _init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, sound: true) ?? false;
    }
    return false;
  }
}
