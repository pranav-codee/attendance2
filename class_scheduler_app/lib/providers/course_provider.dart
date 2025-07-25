import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course.dart';
import '../models/class_instance.dart';

class CourseProvider with ChangeNotifier {
  List<Course> _courses = [];
  List<ClassInstance> _classInstances = [];
  bool _notificationsEnabled = false;

  List<Course> get courses =>
      _courses.where((course) => !course.isArchived).toList();
  List<Course> get archivedCourses =>
      _courses.where((course) => course.isArchived).toList();
  List<Course> get allCourses => _courses;
  List<ClassInstance> get classInstances => _classInstances;
  bool get notificationsEnabled => _notificationsEnabled;

  List<ClassInstance> get todaysClasses {
    final now = DateTime.now();
    return _classInstances.where((classInstance) {
      return classInstance.date.year == now.year &&
          classInstance.date.month == now.month &&
          classInstance.date.day == now.day;
    }).toList();
  }

  List<ClassInstance> get upcomingClasses {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _classInstances.where((classInstance) {
      if (classInstance.date.year == today.year &&
          classInstance.date.month == today.month &&
          classInstance.date.day == today.day) {
        final classStartTime = DateTime(
          today.year,
          today.month,
          today.day,
          classInstance.startTime.hour,
          classInstance.startTime.minute,
        );

        return classStartTime
            .isAfter(now.subtract(const Duration(minutes: 15)));
      }
      return false;
    }).toList()
      ..sort((a, b) => a.startTime.hour.compareTo(b.startTime.hour));
  }

  List<ClassInstance> getTodaysClasses() {
    final now = DateTime.now();
    return _classInstances.where((classInstance) {
      return classInstance.date.year == now.year &&
          classInstance.date.month == now.month &&
          classInstance.date.day == now.day;
    }).toList();
  }

  Future<void> archiveCourse(String courseId, bool isArchived) async {
    final index = _courses.indexWhere((course) => course.id == courseId);
    if (index != -1) {
      _courses[index] = _courses[index].copyWith(isArchived: isArchived);
      await saveData();
      notifyListeners();
    }
  }

  Future<void> editAttendance(
      String courseId, int totalClasses, int attendedClasses) async {
    final index = _courses.indexWhere((course) => course.id == courseId);
    if (index != -1) {
      _courses[index] = _courses[index].copyWith(
        totalClasses: totalClasses,
        attendedClasses: attendedClasses,
      );
      await saveData();
      notifyListeners();
    }
  }

  Course? getCourseById(String courseId) {
    try {
      return _courses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      return null;
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);
    notifyListeners();
  }

  List<Course> getArchivedCourses() {
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    return _courses
        .where((course) => course.createdAt.isBefore(sixMonthsAgo))
        .toList();
  }

  Future<void> restoreCourse(String courseId) async {
    notifyListeners();
  }

  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final coursesJson = prefs.getString('courses');
      if (coursesJson != null) {
        final coursesList = json.decode(coursesJson) as List;
        _courses = coursesList
            .map((courseJson) => Course.fromJson(courseJson))
            .toList();
      }

      final classInstancesJson = prefs.getString('classInstances');
      if (classInstancesJson != null) {
        final classInstancesList = json.decode(classInstancesJson) as List;
        _classInstances = classInstancesList
            .map((classJson) => ClassInstance.fromJson(classJson))
            .toList();
      }

      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading data: $e');
      }
    }
  }

  Future<void> saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final coursesJson =
          json.encode(_courses.map((course) => course.toJson()).toList());
      await prefs.setString('courses', coursesJson);

      final classInstancesJson = json.encode(_classInstances
          .map((classInstance) => classInstance.toJson())
          .toList());
      await prefs.setString('classInstances', classInstancesJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving data: $e');
      }
    }
  }

  Future<void> addCourse(Course course) async {
    _courses.add(course);

    await _generateClassInstances(course);

    await saveData();
    notifyListeners();
  }

  Future<void> removeCourse(String courseId) async {
    _courses.removeWhere((course) => course.id == courseId);
    _classInstances
        .removeWhere((classInstance) => classInstance.courseId == courseId);

    await saveData();
    notifyListeners();
  }

  Future<void> updateCourse(Course updatedCourse) async {
    final index =
        _courses.indexWhere((course) => course.id == updatedCourse.id);
    if (index != -1) {
      _courses[index] = updatedCourse;

      _classInstances.removeWhere(
          (classInstance) => classInstance.courseId == updatedCourse.id);
      await _generateClassInstances(updatedCourse);

      await saveData();
      notifyListeners();
    }
  }

  Future<void> markAttendance(
      String classInstanceId, AttendanceStatus status) async {
    final index = _classInstances
        .indexWhere((classInstance) => classInstance.id == classInstanceId);
    if (index != -1) {
      final classInstance = _classInstances[index];
      _classInstances[index] = classInstance.copyWith(attendanceStatus: status);

      await _updateCourseAttendance(classInstance.courseId);

      await saveData();
      notifyListeners();
    }
  }

  Future<void> markAttendanceOld(
      String classInstanceId, bool isAttended) async {
    await markAttendance(classInstanceId,
        isAttended ? AttendanceStatus.attended : AttendanceStatus.missed);
  }

  Future<void> generateTodaysClasses() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final course in _courses) {
      for (final weeklyClass in course.weeklyClasses) {
        final todayWeekday = (now.weekday - 1) % 7;

        if (weeklyClass.selectedDays.contains(todayWeekday)) {
          final existingClass = _classInstances.any((classInstance) =>
              classInstance.courseId == course.id &&
              classInstance.date.year == today.year &&
              classInstance.date.month == today.month &&
              classInstance.date.day == today.day);

          if (!existingClass) {
            final classInstance = ClassInstance(
              id: '${course.id}_${today.millisecondsSinceEpoch}',
              courseId: course.id,
              courseName: course.name,
              date: today,
              startTime: weeklyClass.startTime,
              endTime: weeklyClass.endTime,
              createdAt: DateTime.now(),
            );

            _classInstances.add(classInstance);

            await _incrementTotalClasses(course.id);
          }
        }
      }
    }

    await saveData();
    notifyListeners();
  }

  Future<void> _updateCourseAttendance(String courseId) async {
    final courseIndex = _courses.indexWhere((course) => course.id == courseId);
    if (courseIndex != -1) {
      final course = _courses[courseIndex];
      final courseClasses = _classInstances
          .where((classInstance) =>
              classInstance.courseId == courseId &&
              classInstance.date
                  .isBefore(DateTime.now().add(const Duration(days: 1))) &&
              classInstance.attendanceStatus != AttendanceStatus.pending)
          .toList();

      final attendedClasses = courseClasses
          .where((classInstance) =>
              classInstance.attendanceStatus == AttendanceStatus.attended)
          .length;

      final totalClassesForAttendance = courseClasses
          .where((classInstance) =>
              classInstance.attendanceStatus != AttendanceStatus.cancelled)
          .length;

      _courses[courseIndex] = course.copyWith(
        totalClasses: totalClassesForAttendance,
        attendedClasses: attendedClasses,
      );
    }
  }

  Future<void> _incrementTotalClasses(String courseId) async {
    final courseIndex = _courses.indexWhere((course) => course.id == courseId);
    if (courseIndex != -1) {
      final course = _courses[courseIndex];
      _courses[courseIndex] = course.copyWith(
        totalClasses: course.totalClasses + 1,
      );
    }
  }

  Future<void> clearAllData() async {
    _courses.clear();
    _classInstances.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('courses');
    await prefs.remove('classInstances');
    await prefs.remove('notificationsEnabled');

    _notificationsEnabled = false;

    notifyListeners();
  }

  Future<void> _generateClassInstances(Course course) async {
    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 365));

    for (final weeklyClass in course.weeklyClasses) {
      for (final dayOfWeek in weeklyClass.selectedDays) {
        DateTime currentDate = _getNextWeekday(now, dayOfWeek);

        if (currentDate.isBefore(now.subtract(const Duration(days: 1)))) {
          currentDate = currentDate.add(const Duration(days: 7));
        }

        while (currentDate.isBefore(endDate)) {
          final classInstance = ClassInstance(
            id: '${course.id}_${currentDate.millisecondsSinceEpoch}',
            courseId: course.id,
            courseName: course.name,
            date: currentDate,
            startTime: weeklyClass.startTime,
            endTime: weeklyClass.endTime,
            createdAt: DateTime.now(),
          );

          if (!_classInstances
              .any((element) => element.id == classInstance.id)) {
            _classInstances.add(classInstance);
          }
          currentDate = currentDate.add(const Duration(days: 7));
        }
      }
    }
  }

  DateTime _getNextWeekday(DateTime date, int weekday) {
    final targetWeekday = weekday + 1;
    final daysUntilTarget = (targetWeekday - date.weekday) % 7;

    if (daysUntilTarget == 0 && date.hour >= 23) {
      return date.add(const Duration(days: 7));
    }

    return date.add(Duration(days: daysUntilTarget == 0 ? 0 : daysUntilTarget));
  }

  double getAttendancePercentage(String courseId) {
    final courseClasses = _classInstances
        .where((classInstance) =>
            classInstance.courseId == courseId &&
            classInstance.date.isBefore(DateTime.now()))
        .toList();

    if (courseClasses.isEmpty) return 0.0;

    final attendedClasses =
        courseClasses.where((classInstance) => classInstance.isAttended).length;
    return (attendedClasses / courseClasses.length) * 100;
  }

  List<ClassInstance> getClassesForCourse(String courseId) {
    return _classInstances
        .where((classInstance) => classInstance.courseId == courseId)
        .toList();
  }
}
