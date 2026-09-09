import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../../events/domain/models.dart';
import 'alarm_scheduler.dart';

class FlutterLocalAlarmScheduler implements AlarmScheduler {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> init() async {
    tz_data.initializeTimeZones();
    final String timeZoneName = tz.local.timeZoneName;
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  @override
  Future<void> scheduleRungs(CalEvent event) async {
    final List<int> daysBefore = [30, 7, 1, 0]; // 30d, 7d, 1d, day-of
    final DateTime now = tz.TZDateTime.now(tz.local);

    for (int i = 0; i < daysBefore.length; i++) {
      final int days = daysBefore[i];
      final DateTime eventDate = DateTime.utc(
        event.dateMillis ~/ Duration.millisecondsPerDay,
      ).add(Duration(days: event.dateMillis % Duration.millisecondsPerDay));
      
      // Calculate the rung date (event date minus days before)
      final DateTime rungDate = eventDate.subtract(Duration(days: days));
      
      // Skip if this rung is already in the past
      final tz.TZDateTime rungDateTime = tz.TZDateTime.from(rungDate, tz.local);
      if (rungDateTime.isBefore(now)) {
        continue;
      }

      // Schedule at 09:00 local time
      final tz.TZDateTime scheduledTime = tz.TZDateTime(
        tz.local,
        rungDateTime.year,
        rungDateTime.month,
        rungDateTime.day,
        9,
        0,
        0,
      );

      final int notificationId = _hashNotificationId(event.id, i);
      final String title = event.title;
      final String body = days == 0 ? 'is today' : 'in $days days';

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'anticipate_channel',
        'Anticipate Reminders',
        channelDescription: 'Event anticipation reminders',
        importance: Importance.high,
        priority: Priority.high,
        scheduleMode: AndroidScheduleMode.inexact,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: false,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  @override
  Future<void> cancelAll(String eventId) async {
    final List<int> daysBefore = [30, 7, 1, 0];
    for (int i = 0; i < daysBefore.length; i++) {
      final int notificationId = _hashNotificationId(eventId, i);
      await _notifications.cancel(notificationId);
    }
  }

  int _hashNotificationId(String eventId, int rungIndex) {
    // Deterministic hash: combine eventId hashCode with rung index
    return (eventId.hashCode + rungIndex).abs() % 2147483647;
  }
}
