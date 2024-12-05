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
    // Initialize timezone data
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.scheduleExactAlarm.isDenied) {
        final status = await Permission.scheduleExactAlarm.request();
        if (status.isGranted) {
          log("Exact alarm permission granted.");
        } else {
          throw Exception("Exact alarm permission denied.");
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
    log("Requesting exact alarm permission...");
    await requestExactAlarmPermission();

    final now = DateTime.now();
    log("Current time: $now");
    log("Scheduled time: $scheduledTime");

    if (scheduledTime.isBefore(now)) {
      throw ArgumentError("Scheduled time must be in the future.");
    }

    log("Scheduling alarm...");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel_id', // Unique channel ID
          'Alarm Notifications', // Channel name
          channelDescription: 'Default alarm notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(
              'alarm'), // Default alarm sound
          enableVibration: true, // Vibrates the device
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    log("Alarm scheduled successfully!");
  }
}
