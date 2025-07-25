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
    return Course(
      id: json['id'],
      name: json['name'],
      courseId: json['courseId'],
      requiredAttendance: json["requiredAttendance"],
      totalClasses: json["totalClasses"] ?? 0,
      attendedClasses: json["attendedClasses"] ?? 0,
      weeklyClasses: (json['weeklyClasses'] as List)
          .map((wc) => WeeklyClass.fromJson(wc))
          .toList(),
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
  final List<int> selectedDays;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  WeeklyClass({
    required this.selectedDays,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'selectedDays': selectedDays,
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
    return WeeklyClass(
      selectedDays: List<int>.from(json['selectedDays']),
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
}
