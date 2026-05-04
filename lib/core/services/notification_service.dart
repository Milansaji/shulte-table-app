import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import '../../core/constants/game_constants.dart';

/// Singleton service for local push notifications.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Call once at app start.
  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

    const androidSettings =
        AndroidInitializationSettings('ic_stat_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
    _initialized = true;
  }

  /// Request notification permission (Android 13+).
  /// Returns true if granted.
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> _ensurePermission() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    final result = await Permission.notification.request();
    return result.isGranted;
  }

  /// Schedule daily reminder at specified time.
  Future<void> scheduleDailyReminder(int hour, int minute) async {
    await _plugin.zonedSchedule(
      0,
      MessageConstants.dailyReminderTitle,
      MessageConstants.dailyReminderBody,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          channelDescription: 'Daily brain training reminder',
          importance: Importance.high,
          priority: Priority.defaultPriority,
          largeIcon: const DrawableResourceAndroidBitmap('ic_logo'),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel the daily reminder.
  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(0);
  }

  Future<void> showAchievementNotification(String title, String body) async {
    final hasPermission = await _ensurePermission();
    if (!hasPermission) return;

    await _plugin.show(
      1,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'achievements',
          'Achievements',
          channelDescription: 'Notifications for unlocked achievements',
          importance: Importance.high,
          priority: Priority.high,
          largeIcon: const DrawableResourceAndroidBitmap('ic_logo'),
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showStreakNotification(String title, String body) async {
    final hasPermission = await _ensurePermission();
    if (!hasPermission) return;

    await _plugin.show(
      2,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streaks',
          'Streaks',
          channelDescription: 'Notifications for daily streaks',
          importance: Importance.high,
          priority: Priority.high,
          largeIcon: const DrawableResourceAndroidBitmap('ic_logo'),
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
