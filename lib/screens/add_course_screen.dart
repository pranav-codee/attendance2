import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../utils/app_theme.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseNameController = TextEditingController();
  final _courseIdController = TextEditingController();

  final _courseNameFocusNode = FocusNode();
  final _courseIdFocusNode = FocusNode();

  double _requiredAttendance = 75.0;
  int? _selectedDay; // Single day selection
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final List<WeeklyClass> _weeklyClasses = [];

  final List<String> _dayNames = ['M', 'T', 'W', 'Th', 'F', 'Sa', 'Su'];
  final List<String> _fullDayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseIdController.dispose();
    _courseNameFocusNode.dispose();
    _courseIdFocusNode.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    _courseNameFocusNode.unfocus();
    _courseIdFocusNode.unfocus();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add Course"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
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
                  "Course Details",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  "Course Name:",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _courseNameController,
                  focusNode: _courseNameFocusNode,
                  decoration: const InputDecoration(
                    hintText: "Enter Course Name (e.g., DSA)",
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a course name';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_courseIdFocusNode);
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  "Course ID:",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _courseIdController,
                  focusNode: _courseIdFocusNode,
                  decoration: const InputDecoration(
                    hintText: "Enter Course ID (e.g., CSL2010)",
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a course ID';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    _dismissKeyboard();
                  },
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: _dismissKeyboard,
                  child: Text(
                    "Required Attendance: ${_requiredAttendance.round()}%",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _dismissKeyboard,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 12),
                    ),
                    child: Slider(
                      value: _requiredAttendance,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      onChanged: (value) {
                        _dismissKeyboard();
                        setState(() {
                          _requiredAttendance = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: _dismissKeyboard,
                  child: Text(
                    "Weekly Schedule",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _dismissKeyboard,
                  child: Text(
                    "Select Day:",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (index) {
                    final isSelected = _selectedDay == index;
                    return GestureDetector(
                      onTap: () {
                        _dismissKeyboard();
                        setState(() {
                          if (isSelected) {
                            _selectedDay = null;
                          } else {
                            _selectedDay = index;
                          }
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.surfaceColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _dayNames[index],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textSecondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _dismissKeyboard();
                          _selectStartTime();
                        },
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
                        onTap: () {
                          _dismissKeyboard();
                          _selectEndTime();
                        },
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
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _canAddWeeklyClass()
                        ? () {
                            _dismissKeyboard();
                            _addWeeklyClass();
                          }
                        : null,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      "Add Weekly Class",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                    ),
                  ),
                ),
                if (_weeklyClasses.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _dismissKeyboard,
                    child: Text(
                      "Added Classes:",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._weeklyClasses.asMap().entries.map((entry) {
                    final index = entry.key;
                    final weeklyClass = entry.value;
                    return GestureDetector(
                      onTap: _dismissKeyboard,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _fullDayNames[weeklyClass.dayOfWeek],
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    "${weeklyClass.startTime.format(context)} - ${weeklyClass.endTime.format(context)}",
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _dismissKeyboard();
                                _removeWeeklyClass(index);
                              },
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppTheme.redColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canSaveCourse()
                        ? () {
                            _dismissKeyboard();
                            _saveCourse();
                          }
                        : null,
                    child: Text(
                      "Save Course",
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
      ),
    );
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
      initialTime: _endTime ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  bool _canAddWeeklyClass() {
    return _selectedDay != null && _startTime != null && _endTime != null;
  }

  void _addWeeklyClass() {
    if (_canAddWeeklyClass()) {
      final weeklyClass = WeeklyClass(
        dayOfWeek: _selectedDay!,
        startTime: _startTime!,
        endTime: _endTime!,
      );

      setState(() {
        _weeklyClasses.add(weeklyClass);
        _selectedDay = null;
        _startTime = null;
        _endTime = null;
      });
    }
  }

  void _removeWeeklyClass(int index) {
    setState(() {
      _weeklyClasses.removeAt(index);
    });
  }

  bool _canSaveCourse() {
    return _formKey.currentState?.validate() == true &&
        _weeklyClasses.isNotEmpty;
  }

  void _saveCourse() async {
    if (_canSaveCourse()) {
      final course = Course(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _courseNameController.text.trim(),
        courseId: _courseIdController.text.trim(),
        requiredAttendance: _requiredAttendance,
        weeklyClasses: _weeklyClasses,
        createdAt: DateTime.now(),
      );

      final courseProvider =
          Provider.of<CourseProvider>(context, listen: false);
      await courseProvider.addCourse(course);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course added successfully!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }
}
