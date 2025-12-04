import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/class_instance.dart';
import '../models/course.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  
  // Settings keys
  static const String _preClassRemindersKey = 'preClassReminders';
  static const String _postClassPromptsKey = 'postClassPrompts';
  static const String _dailySummaryKey = 'dailySummary';
  static const String _dailySummaryTimeKey = 'dailySummaryTime';
  static const String _lowAttendanceWarningsKey = 'lowAttendanceWarnings';
  static const String _reminderMinutesKey = 'reminderMinutes';

  // Default settings
  bool _preClassRemindersEnabled = true;
  bool _postClassPromptsEnabled = true;
  bool _dailySummaryEnabled = false;
  TimeOfDay _dailySummaryTime = const TimeOfDay(hour: 7, minute: 0);
  bool _lowAttendanceWarningsEnabled = true;
  int _reminderMinutesBefore = 5;

  // Getters for settings
  bool get preClassRemindersEnabled => _preClassRemindersEnabled;
  bool get postClassPromptsEnabled => _postClassPromptsEnabled;
  bool get dailySummaryEnabled => _dailySummaryEnabled;
  TimeOfDay get dailySummaryTime => _dailySummaryTime;
  bool get lowAttendanceWarningsEnabled => _lowAttendanceWarningsEnabled;
  int get reminderMinutesBefore => _reminderMinutesBefore;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      if (kDebugMode) {
        print('Error setting timezone: $e');
      }
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _loadSettings();
    _isInitialized = true;
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _preClassRemindersEnabled = prefs.getBool(_preClassRemindersKey) ?? true;
    _postClassPromptsEnabled = prefs.getBool(_postClassPromptsKey) ?? true;
    _dailySummaryEnabled = prefs.getBool(_dailySummaryKey) ?? false;
    _lowAttendanceWarningsEnabled = prefs.getBool(_lowAttendanceWarningsKey) ?? true;
    _reminderMinutesBefore = prefs.getInt(_reminderMinutesKey) ?? 5;
    
    final summaryTimeHour = prefs.getInt('${_dailySummaryTimeKey}_hour') ?? 7;
    final summaryTimeMinute = prefs.getInt('${_dailySummaryTimeKey}_minute') ?? 0;
    _dailySummaryTime = TimeOfDay(hour: summaryTimeHour, minute: summaryTimeMinute);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_preClassRemindersKey, _preClassRemindersEnabled);
    await prefs.setBool(_postClassPromptsKey, _postClassPromptsEnabled);
    await prefs.setBool(_dailySummaryKey, _dailySummaryEnabled);
    await prefs.setBool(_lowAttendanceWarningsKey, _lowAttendanceWarningsEnabled);
    await prefs.setInt(_reminderMinutesKey, _reminderMinutesBefore);
    await prefs.setInt('${_dailySummaryTimeKey}_hour', _dailySummaryTime.hour);
    await prefs.setInt('${_dailySummaryTimeKey}_minute', _dailySummaryTime.minute);
  }

  // Settings setters
  Future<void> setPreClassReminders(bool enabled) async {
    _preClassRemindersEnabled = enabled;
    await _saveSettings();
  }

  Future<void> setPostClassPrompts(bool enabled) async {
    _postClassPromptsEnabled = enabled;
    await _saveSettings();
  }

  Future<void> setDailySummary(bool enabled) async {
    _dailySummaryEnabled = enabled;
    await _saveSettings();
  }

  Future<void> setDailySummaryTime(TimeOfDay time) async {
    _dailySummaryTime = time;
    await _saveSettings();
  }

  Future<void> setLowAttendanceWarnings(bool enabled) async {
    _lowAttendanceWarningsEnabled = enabled;
    await _saveSettings();
  }

  Future<void> setReminderMinutes(int minutes) async {
    _reminderMinutesBefore = minutes;
    await _saveSettings();
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigation is handled by the app
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        final bool? granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
    } else if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iosPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      
      if (iosPlugin != null) {
        final bool? granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }
    return false;
  }

  int _generateNotificationId(String classInstanceId, String type) {
    final combined = '${classInstanceId}_$type';
    return combined.hashCode.abs() % 2147483647;
  }

  Future<void> schedulePreClassReminder(ClassInstance classInstance, Course course) async {
    if (!_preClassRemindersEnabled) return;

    final now = DateTime.now();
    final classDateTime = DateTime(
      classInstance.date.year,
      classInstance.date.month,
      classInstance.date.day,
      classInstance.startTime.hour,
      classInstance.startTime.minute,
    );

    final reminderTime = classDateTime.subtract(Duration(minutes: _reminderMinutesBefore));
    
    if (reminderTime.isBefore(now)) return;

    final notificationId = _generateNotificationId(classInstance.id, 'pre');

    await _notifications.zonedSchedule(
      notificationId,
      '📚 ${course.name} starts in $_reminderMinutesBefore minutes!',
      'Course ID: ${course.courseId} at ${classInstance.startTime.hour.toString().padLeft(2, '0')}:${classInstance.startTime.minute.toString().padLeft(2, '0')}',
      tz.TZDateTime.from(reminderTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'pre_class_reminders',
          'Pre-Class Reminders',
          channelDescription: 'Reminders before your classes start',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'class:${classInstance.id}',
    );
  }

  Future<void> schedulePostClassPrompt(ClassInstance classInstance, Course course) async {
    if (!_postClassPromptsEnabled) return;

    final now = DateTime.now();
    final classEndDateTime = DateTime(
      classInstance.date.year,
      classInstance.date.month,
      classInstance.date.day,
      classInstance.endTime.hour,
      classInstance.endTime.minute,
    );

    final promptTime = classEndDateTime.add(const Duration(minutes: 5));
    
    if (promptTime.isBefore(now)) return;

    final notificationId = _generateNotificationId(classInstance.id, 'post');

    await _notifications.zonedSchedule(
      notificationId,
      'Did you attend ${course.name}?',
      'Mark your attendance now!',
      tz.TZDateTime.from(promptTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'post_class_prompts',
          'Post-Class Prompts',
          channelDescription: 'Reminders to mark your attendance after class',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          actions: <AndroidNotificationAction>[
            const AndroidNotificationAction(
              'attended',
              'Attended',
              showsUserInterface: true,
            ),
            const AndroidNotificationAction(
              'missed',
              'Missed',
              showsUserInterface: true,
            ),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'attendance:${classInstance.id}',
    );
  }

  Future<void> scheduleDailySummary(List<ClassInstance> todaysClasses, List<Course> courses) async {
    if (!_dailySummaryEnabled || todaysClasses.isEmpty) return;

    final now = DateTime.now();
    var summaryDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _dailySummaryTime.hour,
      _dailySummaryTime.minute,
    );

    // If the time has passed today, schedule for tomorrow
    if (summaryDateTime.isBefore(now)) {
      summaryDateTime = summaryDateTime.add(const Duration(days: 1));
    }

    final classCount = todaysClasses.length;
    final classDetails = todaysClasses.map((c) {
      final course = courses.firstWhere(
        (course) => course.id == c.courseId,
        orElse: () => courses.first,
      );
      return '${course.name} at ${c.startTime.hour.toString().padLeft(2, '0')}:${c.startTime.minute.toString().padLeft(2, '0')}';
    }).join(', ');

    await _notifications.zonedSchedule(
      999999, // Fixed ID for daily summary
      'You have $classCount ${classCount == 1 ? 'class' : 'classes'} today',
      classDetails,
      tz.TZDateTime.from(summaryDateTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_summary',
          'Daily Summary',
          channelDescription: 'Daily summary of your classes',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'daily_summary',
    );
  }

  Future<void> showLowAttendanceWarning(Course course, double currentPercentage) async {
    if (!_lowAttendanceWarningsEnabled) return;

    final classesNeeded = _calculateClassesToRecover(
      course.totalClasses,
      course.attendedClasses,
      course.requiredAttendance,
    );

    await _notifications.show(
      course.id.hashCode.abs() % 2147483647,
      '⚠️ Low Attendance Warning: ${course.name}',
      'Current: ${currentPercentage.toStringAsFixed(1)}%. Need to attend $classesNeeded more classes to reach ${course.requiredAttendance.round()}%.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'low_attendance',
          'Low Attendance Warnings',
          channelDescription: 'Warnings when your attendance drops below required',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'course:${course.id}',
    );
  }

  int _calculateClassesToRecover(int totalClasses, int attendedClasses, double requiredPercentage) {
    // Calculate minimum classes needed to attend to reach required percentage
    // Formula: (attended + x) / (total + x) >= required/100
    // Solving for x: x >= (required * total - 100 * attended) / (100 - required)
    
    final required = requiredPercentage / 100;
    if (required >= 1.0) return totalClasses - attendedClasses + 1;
    
    final numerator = (required * totalClasses) - attendedClasses;
    final denominator = 1 - required;
    
    if (denominator <= 0) return 0;
    
    final classesNeeded = (numerator / denominator).ceil();
    return classesNeeded > 0 ? classesNeeded : 0;
  }

  Future<void> scheduleNotificationsForClass(ClassInstance classInstance, Course course) async {
    await schedulePreClassReminder(classInstance, course);
    await schedulePostClassPrompt(classInstance, course);
  }

  Future<void> cancelNotificationsForClass(String classInstanceId) async {
    final preId = _generateNotificationId(classInstanceId, 'pre');
    final postId = _generateNotificationId(classInstanceId, 'post');
    
    await _notifications.cancel(preId);
    await _notifications.cancel(postId);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> scheduleNotificationsForTodaysClasses(
    List<ClassInstance> classes,
    List<Course> courses,
  ) async {
    for (final classInstance in classes) {
      final course = courses.firstWhere(
        (c) => c.id == classInstance.courseId,
        orElse: () => courses.first,
      );
      await scheduleNotificationsForClass(classInstance, course);
    }
    await scheduleDailySummary(classes, courses);
  }
}
