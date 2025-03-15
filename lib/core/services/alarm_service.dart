// lib/core/services/alarm_service.dart
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:super_alarmy/core/services/notification_service.dart';
import 'package:super_alarmy/data/models/alarm_model.dart';

class AlarmService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Save alarm to shared preferences
  static Future<void> saveAlarm(AlarmModel alarm) async {
    final prefs = await SharedPreferences.getInstance();
    final alarmList = await getAlarms();

    // Update if exists, otherwise add
    final existingIndex = alarmList.indexWhere((a) => a.id == alarm.id);
    if (existingIndex >= 0) {
      alarmList[existingIndex] = alarm;
    } else {
      alarmList.add(alarm);
    }

    // Save updated list
    final jsonList =
        alarmList.map((alarm) => jsonEncode(alarm.toJson())).toList();
    await prefs.setStringList('alarms', jsonList);

    // Schedule if enabled
    if (alarm.isEnabled) {
      await scheduleAlarm(alarm);
    } else {
      await cancelAlarm(alarm.id);
    }
  }

  // Get all alarms from shared preferences
  static Future<List<AlarmModel>> getAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('alarms') ?? [];

    return jsonList
        .map((jsonString) => AlarmModel.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  // Delete alarm
  static Future<void> deleteAlarm(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final alarmList = await getAlarms();

    // Remove alarm with matching id
    alarmList.removeWhere((alarm) => alarm.id == id);

    // Save updated list
    final jsonList =
        alarmList.map((alarm) => jsonEncode(alarm.toJson())).toList();
    await prefs.setStringList('alarms', jsonList);

    // Cancel scheduled alarm
    await cancelAlarm(id);
  }

  // Schedule alarm
  static Future<void> scheduleAlarm(AlarmModel alarm) async {
    // Cancel existing alarm with this ID if it exists
    await cancelAlarm(alarm.id);

    // Schedule notification
    await NotificationService.scheduleAlarmNotification(
      flutterLocalNotificationsPlugin: _notificationsPlugin,
      id: alarm.id,
      title: alarm.label.isNotEmpty ? alarm.label : 'Wake Up!',
      body: 'Time to wake up and complete your mission!',
      scheduledTime: _getNextAlarmTime(alarm),
    );

    // Schedule background task for Android
    await AndroidAlarmManager.oneShotAt(
      _getNextAlarmTime(alarm),
      alarm.id,
      _alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      alarmClock: true,
    );
  }

  // Cancel alarm
  static Future<void> cancelAlarm(int id) async {
    // Cancel notification
    await NotificationService.cancelNotification(
      flutterLocalNotificationsPlugin: _notificationsPlugin,
      id: id,
    );

    // Cancel background task
    await AndroidAlarmManager.cancel(id);
  }

  // Calculate next alarm time based on repeat pattern
  static DateTime _getNextAlarmTime(AlarmModel alarm) {
    final now = DateTime.now();
    final alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.hour,
      alarm.minute,
    );

    // If alarm time is in the past, add days based on repeat pattern
    if (alarmTime.isBefore(now)) {
      if (alarm.repeatDays.isEmpty) {
        // One-time alarm, schedule for tomorrow
        return alarmTime.add(Duration(days: 1));
      } else {
        // Repeating alarm, find next occurrence
        int daysToAdd = 1;
        while (daysToAdd < 8) {
          final nextDay = (now.weekday + daysToAdd) % 7;
          if (alarm.repeatDays.contains(nextDay == 0 ? 7 : nextDay)) {
            return alarmTime.add(Duration(days: daysToAdd));
          }
          daysToAdd++;
        }
        return alarmTime.add(Duration(days: 1)); // Fallback
      }
    }

    return alarmTime;
  }

  // Callback function for alarm trigger
  static Future<void> _alarmCallback() async {
    // This runs in a separate isolate
    // Implement any background logic needed when alarm triggers
    print('Alarm triggered!');
  }

  // Reschedule all enabled alarms (call on app start/device reboot)
  static Future<void> rescheduleEnabledAlarms() async {
    final alarms = await getAlarms();
    for (final alarm in alarms) {
      if (alarm.isEnabled) {
        await scheduleAlarm(alarm);
      }
    }
  }
}
