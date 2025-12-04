import 'package:flutter/material.dart';

class Course {
  final String id;
  final String name;
  final String courseId;
  final double requiredAttendance;
  final int totalClasses;
  final int attendedClasses;
  final List<WeeklyClass> weeklyClasses;
  final DateTime createdAt;
  final bool isArchived;

  Course({
    required this.id,
    required this.name,
    required this.courseId,
    required this.requiredAttendance,
    this.totalClasses = 0,
    this.attendedClasses = 0,
    required this.weeklyClasses,
    required this.createdAt,
    this.isArchived = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'courseId': courseId,
      'requiredAttendance': requiredAttendance,
      'totalClasses': totalClasses,
      'attendedClasses': attendedClasses,
      'weeklyClasses': weeklyClasses.map((wc) => wc.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isArchived': isArchived,
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    // Handle migration from old format
    List<WeeklyClass> classes = [];
    if (json['weeklyClasses'] != null) {
      for (var wc in json['weeklyClasses'] as List) {
        classes.addAll(WeeklyClass.fromJsonWithMigration(wc));
      }
    }

    return Course(
      id: json['id'],
      name: json['name'],
      courseId: json['courseId'],
      requiredAttendance: json["requiredAttendance"],
      totalClasses: json["totalClasses"] ?? 0,
      attendedClasses: json["attendedClasses"] ?? 0,
      weeklyClasses: classes,
      createdAt: DateTime.parse(json['createdAt']),
      isArchived: json['isArchived'] ?? false,
    );
  }

  Course copyWith({
    String? id,
    String? name,
    String? courseId,
    double? requiredAttendance,
    int? totalClasses,
    int? attendedClasses,
    List<WeeklyClass>? weeklyClasses,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      courseId: courseId ?? this.courseId,
      requiredAttendance: requiredAttendance ?? this.requiredAttendance,
      totalClasses: totalClasses ?? this.totalClasses,
      attendedClasses: attendedClasses ?? this.attendedClasses,
      weeklyClasses: weeklyClasses ?? this.weeklyClasses,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

class WeeklyClass {
  final int dayOfWeek; // Single day (0 = Monday, 6 = Sunday)
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  WeeklyClass({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  // For backward compatibility with old data format
  List<int> get selectedDays => [dayOfWeek];

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'selectedDays': [dayOfWeek], // Keep for backward compatibility
      'startTime': {
        'hour': startTime.hour,
        'minute': startTime.minute,
      },
      'endTime': {
        'hour': endTime.hour,
        'minute': endTime.minute,
      },
    };
  }

  factory WeeklyClass.fromJson(Map<String, dynamic> json) {
    // Handle both old and new format
    int day;
    if (json.containsKey('dayOfWeek')) {
      day = json['dayOfWeek'];
    } else if (json.containsKey('selectedDays')) {
      // Old format - take first day (will need migration for multiple days)
      final days = List<int>.from(json['selectedDays']);
      day = days.isNotEmpty ? days.first : 0;
    } else {
      day = 0;
    }

    return WeeklyClass(
      dayOfWeek: day,
      startTime: TimeOfDay(
        hour: json['startTime']['hour'],
        minute: json['startTime']['minute'],
      ),
      endTime: TimeOfDay(
        hour: json['endTime']['hour'],
        minute: json['endTime']['minute'],
      ),
    );
  }

  // Helper to migrate old format with multiple days to new format
  static List<WeeklyClass> fromJsonWithMigration(Map<String, dynamic> json) {
    if (json.containsKey('dayOfWeek')) {
      // New format - single entry
      return [WeeklyClass.fromJson(json)];
    } else if (json.containsKey('selectedDays')) {
      // Old format - create one WeeklyClass per day
      final days = List<int>.from(json['selectedDays']);
      final startTime = TimeOfDay(
        hour: json['startTime']['hour'],
        minute: json['startTime']['minute'],
      );
      final endTime = TimeOfDay(
        hour: json['endTime']['hour'],
        minute: json['endTime']['minute'],
      );
      return days
          .map((day) => WeeklyClass(
                dayOfWeek: day,
                startTime: startTime,
                endTime: endTime,
              ))
          .toList();
    }
    return [];
  }
}
