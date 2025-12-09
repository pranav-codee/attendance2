import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exam.dart';

class ExamProvider with ChangeNotifier {
  List<Exam> _exams = [];

  List<Exam> get exams => _exams;

  /// Get upcoming exams (sorted by date)
  List<Exam> get upcomingExams {
    final upcoming = _exams.where((exam) => exam.isUpcoming).toList();
    upcoming.sort((a, b) => a.examDate.compareTo(b.examDate));
    return upcoming;
  }

  /// Get past exams (sorted by date, most recent first)
  List<Exam> get pastExams {
    final past = _exams.where((exam) => exam.isPast).toList();
    past.sort((a, b) => b.examDate.compareTo(a.examDate));
    return past;
  }

  /// Get today's exams
  List<Exam> get todaysExams {
    return _exams.where((exam) => exam.isToday).toList();
  }

  /// Get exams within next 7 days
  List<Exam> get examsThisWeek {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    return _exams.where((exam) {
      return exam.examDate.isAfter(now) && exam.examDate.isBefore(weekFromNow);
    }).toList()
      ..sort((a, b) => a.examDate.compareTo(b.examDate));
  }

  /// Get exams for a specific course
  List<Exam> getExamsForCourse(String courseCode) {
    return _exams.where((exam) => exam.courseCode == courseCode).toList()
      ..sort((a, b) => a.examDate.compareTo(b.examDate));
  }

  /// Load exams from storage
  Future<void> loadExams() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final examsJson = prefs.getString('exams');

      if (examsJson != null) {
        final examsList = json.decode(examsJson) as List;
        _exams = examsList.map((examJson) => Exam.fromJson(examJson)).toList();
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading exams: $e');
      }
    }
  }

  /// Save exams to storage
  Future<void> saveExams() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final examsJson =
          json.encode(_exams.map((exam) => exam.toJson()).toList());
      await prefs.setString('exams', examsJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving exams: $e');
      }
    }
  }

  /// Add a new exam
  Future<void> addExam(Exam exam) async {
    _exams.add(exam);
    await saveExams();
    notifyListeners();
  }

  /// Update an existing exam
  Future<void> updateExam(Exam updatedExam) async {
    final index = _exams.indexWhere((exam) => exam.id == updatedExam.id);
    if (index != -1) {
      _exams[index] = updatedExam;
      await saveExams();
      notifyListeners();
    }
  }

  /// Delete an exam
  Future<void> deleteExam(String examId) async {
    _exams.removeWhere((exam) => exam.id == examId);
    await saveExams();
    notifyListeners();
  }

  /// Get exam by ID
  Exam? getExamById(String examId) {
    try {
      return _exams.firstWhere((exam) => exam.id == examId);
    } catch (e) {
      return null;
    }
  }

  /// Clear all exams
  Future<void> clearAllExams() async {
    _exams.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('exams');
    notifyListeners();
  }

  /// Get count of exams
  int get examCount => _exams.length;

  /// Check if there are any upcoming exams
  bool get hasUpcomingExams => upcomingExams.isNotEmpty;

  /// Get next upcoming exam
  Exam? get nextExam {
    if (upcomingExams.isEmpty) return null;
    return upcomingExams.first;
  }
}
