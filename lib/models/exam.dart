import 'package:flutter/material.dart';

class Exam {
  final String id;
  final String courseName;
  final String courseCode;
  final DateTime examDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final DateTime createdAt;

  Exam({
    required this.id,
    required this.courseName,
    required this.courseCode,
    required this.examDate,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseName': courseName,
      'courseCode': courseCode,
      'examDate': examDate.toIso8601String(),
      'startTime': {
        'hour': startTime.hour,
        'minute': startTime.minute,
      },
      'endTime': {
        'hour': endTime.hour,
        'minute': endTime.minute,
      },
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      courseName: json['courseName'],
      courseCode: json['courseCode'],
      examDate: DateTime.parse(json['examDate']),
      startTime: TimeOfDay(
        hour: json['startTime']['hour'],
        minute: json['startTime']['minute'],
      ),
      endTime: TimeOfDay(
        hour: json['endTime']['hour'],
        minute: json['endTime']['minute'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Exam copyWith({
    String? id,
    String? courseName,
    String? courseCode,
    DateTime? examDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    DateTime? createdAt,
  }) {
    return Exam(
      id: id ?? this.id,
      courseName: courseName ?? this.courseName,
      courseCode: courseCode ?? this.courseCode,
      examDate: examDate ?? this.examDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if exam is today
  bool get isToday {
    final now = DateTime.now();
    return examDate.year == now.year &&
        examDate.month == now.month &&
        examDate.day == now.day;
  }

  /// Check if exam is upcoming (in the future)
  bool get isUpcoming {
    final now = DateTime.now();
    final examDateTime = DateTime(
      examDate.year,
      examDate.month,
      examDate.day,
      startTime.hour,
      startTime.minute,
    );
    return examDateTime.isAfter(now);
  }

  /// Check if exam is in the past
  bool get isPast {
    final now = DateTime.now();
    final examDateTime = DateTime(
      examDate.year,
      examDate.month,
      examDate.day,
      endTime.hour,
      endTime.minute,
    );
    return examDateTime.isBefore(now);
  }

  /// Get formatted time range
  String get timeRange {
    final startHour = startTime.hour.toString().padLeft(2, '0');
    final startMinute = startTime.minute.toString().padLeft(2, '0');
    final endHour = endTime.hour.toString().padLeft(2, '0');
    final endMinute = endTime.minute.toString().padLeft(2, '0');
    return '$startHour:$startMinute - $endHour:$endMinute';
  }

  /// Get days until exam
  int get daysUntilExam {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final examDay = DateTime(examDate.year, examDate.month, examDate.day);
    return examDay.difference(today).inDays;
  }

  /// Generate a unique notification ID for exam reminder
  int get reminderNotificationId {
    return '${id}_reminder'.hashCode.abs() % 2147483647;
  }

  /// Generate a unique notification ID for exam day
  int get examDayNotificationId {
    return '${id}_examday'.hashCode.abs() % 2147483647;
  }
}
