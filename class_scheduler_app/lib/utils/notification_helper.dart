import 'package:flutter/material.dart';
import '../models/class_instance.dart';
import '../models/course.dart';

class NotificationHelper {
  /// Generate a unique notification ID from class instance ID
  static int generateNotificationId(String classInstanceId, String type) {
    final combined = '${classInstanceId}_$type';
    return combined.hashCode.abs() % 2147483647;
  }

  /// Filter today's remaining classes that need notifications
  static List<ClassInstance> getTodaysRemainingClasses(
    List<ClassInstance> allClasses,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return allClasses.where((classInstance) {
      // Check if class is today
      if (classInstance.date.year != today.year ||
          classInstance.date.month != today.month ||
          classInstance.date.day != today.day) {
        return false;
      }
      
      // Check if class start time is in the future
      final classStartTime = DateTime(
        today.year,
        today.month,
        today.day,
        classInstance.startTime.hour,
        classInstance.startTime.minute,
      );
      
      return classStartTime.isAfter(now);
    }).toList();
  }

  /// Get classes for the next day
  static List<ClassInstance> getTomorrowsClasses(
    List<ClassInstance> allClasses,
  ) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    
    return allClasses.where((classInstance) {
      return classInstance.date.year == tomorrow.year &&
          classInstance.date.month == tomorrow.month &&
          classInstance.date.day == tomorrow.day;
    }).toList();
  }

  /// Check if a class needs a pre-class reminder
  static bool needsPreClassReminder(ClassInstance classInstance, int minutesBefore) {
    final now = DateTime.now();
    final classStartTime = DateTime(
      classInstance.date.year,
      classInstance.date.month,
      classInstance.date.day,
      classInstance.startTime.hour,
      classInstance.startTime.minute,
    );
    
    final reminderTime = classStartTime.subtract(Duration(minutes: minutesBefore));
    return reminderTime.isAfter(now);
  }

  /// Check if a class needs a post-class prompt
  static bool needsPostClassPrompt(ClassInstance classInstance) {
    final now = DateTime.now();
    final classEndTime = DateTime(
      classInstance.date.year,
      classInstance.date.month,
      classInstance.date.day,
      classInstance.endTime.hour,
      classInstance.endTime.minute,
    );
    
    final promptTime = classEndTime.add(const Duration(minutes: 5));
    return promptTime.isAfter(now) && classInstance.attendanceStatus == AttendanceStatus.pending;
  }

  /// Format time for notification display
  static String formatTimeForNotification(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Get the course for a class instance
  static Course? getCourseForClass(ClassInstance classInstance, List<Course> courses) {
    try {
      return courses.firstWhere((course) => course.id == classInstance.courseId);
    } catch (e) {
      return null;
    }
  }

  /// Calculate minutes until class starts
  static int minutesUntilClass(ClassInstance classInstance) {
    final now = DateTime.now();
    final classStartTime = DateTime(
      classInstance.date.year,
      classInstance.date.month,
      classInstance.date.day,
      classInstance.startTime.hour,
      classInstance.startTime.minute,
    );
    
    return classStartTime.difference(now).inMinutes;
  }

  /// Check if notification permissions should be requested
  static bool shouldRequestPermissions(bool notificationsEnabled, bool permissionsGranted) {
    return notificationsEnabled && !permissionsGranted;
  }

  /// Build notification title for pre-class reminder
  static String buildPreClassTitle(String courseName, int minutesBefore) {
    return '📚 $courseName starts in $minutesBefore minutes!';
  }

  /// Build notification body for pre-class reminder
  static String buildPreClassBody(String courseId, TimeOfDay startTime) {
    return 'Course ID: $courseId at ${formatTimeForNotification(startTime)}';
  }

  /// Build notification title for post-class prompt
  static String buildPostClassTitle(String courseName) {
    return 'Did you attend $courseName?';
  }

  /// Build notification body for post-class prompt
  static String buildPostClassBody() {
    return 'Mark your attendance now!';
  }

  /// Build daily summary title
  static String buildDailySummaryTitle(int classCount) {
    return 'You have $classCount ${classCount == 1 ? 'class' : 'classes'} today';
  }

  /// Build daily summary body
  static String buildDailySummaryBody(List<ClassInstance> classes, List<Course> courses) {
    return classes.map((classInstance) {
      final course = getCourseForClass(classInstance, courses);
      final courseName = course?.name ?? 'Unknown';
      return '$courseName at ${formatTimeForNotification(classInstance.startTime)}';
    }).join(', ');
  }
}
