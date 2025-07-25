import 'package:flutter/material.dart';

enum AttendanceStatus {
  pending,
  attended,
  missed,
  cancelled,
}

class ClassInstance {
  final String id;
  final String courseId;
  final String courseName;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final AttendanceStatus attendanceStatus;
  final DateTime createdAt;

  ClassInstance({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.attendanceStatus = AttendanceStatus.pending,
    required this.createdAt,
  });

  bool get isAttended => attendanceStatus == AttendanceStatus.attended;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'courseName': courseName,
      'date': date.toIso8601String(),
      'startTime': {
        'hour': startTime.hour,
        'minute': startTime.minute,
      },
      'endTime': {
        'hour': endTime.hour,
        'minute': endTime.minute,
      },
      'attendanceStatus': attendanceStatus.index,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClassInstance.fromJson(Map<String, dynamic> json) {
    AttendanceStatus status = AttendanceStatus.pending;
    if (json.containsKey('attendanceStatus')) {
      status = AttendanceStatus.values[json['attendanceStatus']];
    } else if (json.containsKey('isAttended')) {
      status = json['isAttended'] == true
          ? AttendanceStatus.attended
          : AttendanceStatus.pending;
    }

    return ClassInstance(
      id: json['id'],
      courseId: json['courseId'],
      courseName: json['courseName'],
      date: DateTime.parse(json['date']),
      startTime: TimeOfDay(
        hour: json['startTime']['hour'],
        minute: json['startTime']['minute'],
      ),
      endTime: TimeOfDay(
        hour: json['endTime']['hour'],
        minute: json['endTime']['minute'],
      ),
      attendanceStatus: status,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  ClassInstance copyWith({
    String? id,
    String? courseId,
    String? courseName,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    AttendanceStatus? attendanceStatus,
    bool? isAttended,
    DateTime? createdAt,
  }) {
    AttendanceStatus newStatus = attendanceStatus ?? this.attendanceStatus;

    if (isAttended != null && attendanceStatus == null) {
      newStatus =
          isAttended ? AttendanceStatus.attended : AttendanceStatus.missed;
    }

    return ClassInstance(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      attendanceStatus: newStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String get timeRange {
    final startHour = startTime.hour.toString().padLeft(2, '0');
    final startMinute = startTime.minute.toString().padLeft(2, '0');
    final endHour = endTime.hour.toString().padLeft(2, '0');
    final endMinute = endTime.minute.toString().padLeft(2, '0');
    return '$startHour:$startMinute - $endHour:$endMinute';
  }

  String get statusText {
    switch (attendanceStatus) {
      case AttendanceStatus.pending:
        return 'Pending';
      case AttendanceStatus.attended:
        return 'Attended';
      case AttendanceStatus.missed:
        return 'Missed';
      case AttendanceStatus.cancelled:
        return 'Cancelled';
    }
  }
}
