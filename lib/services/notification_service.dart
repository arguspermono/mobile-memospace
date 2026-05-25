import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'memospace_reminders',
          'Reminders',
          channelDescription: 'Notification channel for MemoSpace reminders',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleClassroomReminders({
    required int baseId,
    required String title,
    required String body,
    required DateTime deadline,
  }) async {
    final now = DateTime.now();

    // 1 week before
    final oneWeekBefore = deadline.subtract(const Duration(days: 7));
    if (oneWeekBefore.isAfter(now)) {
      await scheduleNotification(
        id: baseId * 10 + 3,
        title: 'ONE WEEK BEFORE DEADLINE : $title',
        body: body,
        scheduledDate: oneWeekBefore,
      );
    }

    // 1 day before
    final oneDayBefore = deadline.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(now)) {
      await scheduleNotification(
        id: baseId * 10 + 2,
        title: 'TOMORROW IS DEADLINE : $title',
        body: body,
        scheduledDate: oneDayBefore,
      );
    }

    // 2 hours before
    final twoHoursBefore = deadline.subtract(const Duration(hours: 2));
    if (twoHoursBefore.isAfter(now)) {
      await scheduleNotification(
        id: baseId * 10 + 1,
        title: 'DEADLINE IN TWO HOURS : $title',
        body: body,
        scheduledDate: twoHoursBefore,
      );
    }

    // 1 hour before
    final oneHourBefore = deadline.subtract(const Duration(hours: 1));
    if (oneHourBefore.isAfter(now)) {
      await scheduleNotification(
        id: baseId * 10 + 4,
        title: 'DEADLINE IN ONE HOUR : $title',
        body: body,
        scheduledDate: oneHourBefore,
      );
    }

    // Exact time
    if (deadline.isAfter(now)) {
      await scheduleNotification(
        id: baseId * 10 + 0,
        title: 'DEADLINE NOW : $title',
        body: body,
        scheduledDate: deadline,
      );
    }
  }

  Future<void> cancelClassroomReminders(int baseId) async {
    await _notificationsPlugin.cancel(baseId * 10 + 0);
    await _notificationsPlugin.cancel(baseId * 10 + 1);
    await _notificationsPlugin.cancel(baseId * 10 + 2);
    await _notificationsPlugin.cancel(baseId * 10 + 3);
    await _notificationsPlugin.cancel(baseId * 10 + 4);
    await _notificationsPlugin.cancel(baseId); // legacy
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
