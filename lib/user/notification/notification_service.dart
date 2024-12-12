import 'dart:developer';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService() {
    _initialize();
  }

  void _initialize() async {
    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      log("NotificationService initialized successfully.");
    } catch (e) {
      log("Error initializing NotificationService: $e");
    }
  }

  Future<void> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      // Extract the major Android version (API level)
      final int androidVersion =
          int.tryParse(Platform.version.split(' ')[0]) ?? 0;

      if (androidVersion >= 31) {
        // Android 12 or higher
        if (await Permission.scheduleExactAlarm.isDenied) {
          final status = await Permission.scheduleExactAlarm.request();
          if (status.isGranted) {
            log("Exact alarm permission granted.");
          } else {
            log("Exact alarm permission denied.");
            throw Exception("Exact alarm permission denied.");
          }
        }
      }
    }
  }

  Future<void> scheduleAlarm(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    try {
      log("Requesting exact alarm permission...");
      await requestExactAlarmPermission();

      final now = DateTime.now();
      log("Current time: $now");
      log("Scheduled time: $scheduledTime");

      if (scheduledTime.isBefore(now)) {
        throw ArgumentError("Scheduled time must be in the future.");
      }

      // Cancel any existing alarm with the same ID
      await flutterLocalNotificationsPlugin.cancel(id);
      log("Previous alarm with ID $id canceled (if existed).");

      log("Scheduling alarm...");

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'alarm_channel_id',
            'Alarm Notifications',
            channelDescription: 'Default alarm notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('alarm'),
            enableVibration: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      log("Alarm with ID $id scheduled successfully!");
    } catch (e) {
      log("Error scheduling alarm: $e");
    }
  }
}
