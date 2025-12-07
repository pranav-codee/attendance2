import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/class_instance.dart';
import '../models/course.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  Future<String> exportAttendanceToCSV(
    List<ClassInstance> classInstances,
    List<Course> courses,
  ) async {
    final List<List<dynamic>> rows = [];

    // ===== SUMMARY SECTION =====
    rows.add(['ATTENDANCE SUMMARY']);
    rows.add([]);
    rows.add([
      'Course Name',
      'Course ID',
      'Total Classes',
      'Attended',
      'Attendance %',
      'Required %',
      'Status'
    ]);

    for (final course in courses.where((c) => !c.isArchived)) {
      final percentage = course.totalClasses > 0
          ? (course.attendedClasses / course.totalClasses) * 100
          : 0.0;
      final status =
          percentage >= course.requiredAttendance ? 'On Track' : 'At Risk';

      rows.add([
        course.name,
        course.courseId,
        course.totalClasses,
        course.attendedClasses,
        '${percentage.toStringAsFixed(1)}%',
        '${course.requiredAttendance.round()}%',
        status,
      ]);
    }

    rows.add([]);
    rows.add(['ATTENDED CLASSES RECORD']);
    rows.add([]);

    // Header row for attendance records
    rows.add([
      'Course Name',
      'Course ID',
      'Date',
      'Start Time',
      'End Time',
    ]);

    // Filter to only include ATTENDED classes
    final attendedInstances = classInstances.where((classInstance) {
      return classInstance.attendanceStatus == AttendanceStatus.attended;
    }).toList();

    // Sort class instances by date
    attendedInstances.sort((a, b) => a.date.compareTo(b.date));

    for (final classInstance in attendedInstances) {
      final course = courses.firstWhere(
        (c) => c.id == classInstance.courseId,
        orElse: () => Course(
          id: '',
          name: 'Unknown',
          courseId: 'Unknown',
          requiredAttendance: 0,
          weeklyClasses: [],
          createdAt: DateTime.now(),
        ),
      );

      rows.add([
        course.name,
        course.courseId,
        DateFormat('yyyy-MM-dd').format(classInstance.date),
        '${classInstance.startTime.hour.toString().padLeft(2, '0')}:${classInstance.startTime.minute.toString().padLeft(2, '0')}',
        '${classInstance.endTime.hour.toString().padLeft(2, '0')}:${classInstance.endTime.minute.toString().padLeft(2, '0')}',
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/attendance_export_$timestamp.csv';
    final file = File(filePath);
    await file.writeAsString(csvData);

    return filePath;
  }

  Future<void> shareAttendanceReport(
    List<ClassInstance> classInstances,
    List<Course> courses,
  ) async {
    final filePath = await exportAttendanceToCSV(classInstances, courses);
    await Share.shareXFiles([XFile(filePath)], text: 'Attendance Report');
  }

  Future<String> exportCoursesSummary(List<Course> courses) async {
    final List<List<dynamic>> rows = [];

    // Header row
    rows.add([
      'Course Name',
      'Course ID',
      'Total Classes',
      'Attended Classes',
      'Attendance %',
      'Required %',
      'Status'
    ]);

    for (final course in courses) {
      final attendancePercentage = course.totalClasses > 0
          ? (course.attendedClasses / course.totalClasses) * 100
          : 0.0;

      final status = attendancePercentage >= course.requiredAttendance
          ? 'On Track'
          : 'At Risk';

      rows.add([
        course.name,
        course.courseId,
        course.totalClasses,
        course.attendedClasses,
        '${attendancePercentage.toStringAsFixed(1)}%',
        '${course.requiredAttendance.round()}%',
        status,
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/courses_summary_$timestamp.csv';
    final file = File(filePath);
    await file.writeAsString(csvData);

    return filePath;
  }

  Future<void> shareCoursesSummary(List<Course> courses) async {
    final filePath = await exportCoursesSummary(courses);
    await Share.shareXFiles([XFile(filePath)], text: 'Courses Summary');
  }
}
