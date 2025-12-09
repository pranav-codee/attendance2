import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exam.dart';
import '../providers/exam_provider.dart';
import '../utils/app_theme.dart';

class AddExamScreen extends StatefulWidget {
  final Exam? examToEdit;

  const AddExamScreen({super.key, this.examToEdit});

  @override
  State<AddExamScreen> createState() => _AddExamScreenState();
}

class _AddExamScreenState extends State<AddExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseNameController = TextEditingController();
  final _courseCodeController = TextEditingController();

  DateTime? _examDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  bool get _isEditing => widget.examToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final exam = widget.examToEdit!;
      _courseNameController.text = exam.courseName;
      _courseCodeController.text = exam.courseCode;
      _examDate = exam.examDate;
      _startTime = exam.startTime;
      _endTime = exam.endTime;
    }
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Exam" : "Add Exam"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Exam Details",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Course Name
              Text(
                "Course Name:",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _courseNameController,
                decoration: const InputDecoration(
                  hintText: "Enter Course Name (e.g., Data Structures)",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a course name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Course Code
              Text(
                "Course Code:",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _courseCodeController,
                decoration: const InputDecoration(
                  hintText: "Enter Course Code (e.g., CSL2010)",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a course code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              Text(
                "Exam Schedule",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Exam Date
              GestureDetector(
                onTap: _selectExamDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _examDate != null
                            ? "${_examDate!.day}/${_examDate!.month}/${_examDate!.year}"
                            : "Select Exam Date",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Start and End Time
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectStartTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _startTime != null
                                ? "Start: ${_startTime!.format(context)}"
                                : "Select Start Time",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectEndTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _endTime != null
                                ? "End: ${_endTime!.format(context)}"
                                : "Select End Time",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSave() ? _saveExam : null,
                  child: Text(
                    _isEditing ? "Update Exam" : "Save Exam",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectExamDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _examDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _examDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  bool _canSave() {
    return _formKey.currentState?.validate() == true &&
        _examDate != null &&
        _startTime != null &&
        _endTime != null;
  }

  void _saveExam() async {
    if (_canSave()) {
      final exam = Exam(
        id: _isEditing
            ? widget.examToEdit!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        courseName: _courseNameController.text.trim(),
        courseCode: _courseCodeController.text.trim(),
        examDate: _examDate!,
        startTime: _startTime!,
        endTime: _endTime!,
        createdAt: _isEditing ? widget.examToEdit!.createdAt : DateTime.now(),
      );

      final examProvider = Provider.of<ExamProvider>(context, listen: false);

      if (_isEditing) {
        await examProvider.updateExam(exam);
      } else {
        await examProvider.addExam(exam);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Exam updated successfully!'
                  : 'Exam added successfully!',
            ),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }
}
