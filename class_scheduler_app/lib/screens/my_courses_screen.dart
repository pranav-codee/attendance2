import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import '../models/course.dart';
import '../utils/app_theme.dart';

class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "My Courses",
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 4),
                            Consumer<CourseProvider>(
                              builder: (context, courseProvider, child) {
                                final courseCount =
                                    courseProvider.courses.length;
                                return Text(
                                  "$courseCount ${courseCount == 1 ? 'course' : 'courses'} enrolled",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                );
                              },
                            ),
                          ],
                        ),
                        _buildAddButton(context),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Consumer<CourseProvider>(
                builder: (context, courseProvider, child) {
                  if (courseProvider.courses.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        ...courseProvider.courses.asMap().entries.map((entry) {
                          final index = entry.key;
                          final course = entry.value;
                          return AnimatedContainer(
                            duration:
                                Duration(milliseconds: 200 + (index * 100)),
                            child: _buildCourseCard(
                                context, course, courseProvider),
                          );
                        }),
                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await Navigator.pushNamed(context, '/add-course');
            if (context.mounted) {
              Provider.of<CourseProvider>(context, listen: false).loadData();
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.school_rounded,
                size: 48,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No courses yet!",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "Add your first course to start tracking attendance.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(
      BuildContext context, Course course, CourseProvider courseProvider) {
    final totalClasses = course.totalClasses;
    final attendedClasses = course.attendedClasses;
    final attendancePercentage =
        totalClasses > 0 ? (attendedClasses / totalClasses) * 100 : 0.0;

    final meetsAttendanceCriteria =
        totalClasses > 0 && attendancePercentage >= course.requiredAttendance;
    final hasLowAttendance =
        totalClasses > 0 && attendancePercentage < course.requiredAttendance;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: AppTheme.extraLargeRadius,
        border: meetsAttendanceCriteria
            ? Border.all(
                color: AppTheme.greenColor,
                width: 2,
              )
            : hasLowAttendance
                ? Border.all(
                    color: AppTheme.redColor,
                    width: 2,
                  )
                : null,
        boxShadow: meetsAttendanceCriteria
            ? [
                BoxShadow(
                  color: AppTheme.greenColor.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : hasLowAttendance
                ? [
                    BoxShadow(
                      color: AppTheme.redColor.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                course.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            if (meetsAttendanceCriteria) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.greenColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 14,
                                      color: AppTheme.greenColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'On Track',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: AppTheme.greenColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else if (hasLowAttendance) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.redColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.warning_rounded,
                                      size: 14,
                                      color: AppTheme.redColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'At Risk',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: AppTheme.redColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          course.courseId,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteDialog(context, course, courseProvider);
                      } else if (value == 'archive') {
                        _showArchiveDialog(context, course, courseProvider);
                      } else if (value == 'edit_attendance') {
                        _showEditAttendanceDialog(
                            context, course, courseProvider);
                      }
                    },
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: AppTheme.textSecondaryColor,
                    ),
                    color: AppTheme.surfaceColorElevated,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit_attendance',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_rounded,
                                color: AppTheme.primaryColor, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Edit Attendance',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.primaryColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'archive',
                        child: Row(
                          children: [
                            const Icon(Icons.archive_rounded,
                                color: AppTheme.textSecondaryColor, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Archive Course',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline_rounded,
                                color: AppTheme.redColor, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Delete Course',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.redColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (totalClasses > 0) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColorElevated,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Attendance",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                ),
                          ),
                          Row(
                            children: [
                              Text(
                                "${attendancePercentage.toStringAsFixed(1)}%",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: meetsAttendanceCriteria
                                          ? AppTheme.greenColor
                                          : AppTheme.redColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "($attendedClasses/$totalClasses)",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.textTertiaryColor,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColorHighlight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor:
                              (attendancePercentage / 100).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: meetsAttendanceCriteria
                                  ? AppTheme.successGradient
                                  : LinearGradient(
                                      colors: [
                                        AppTheme.redColor,
                                        AppTheme.redColor.withOpacity(0.8)
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Required: ${course.requiredAttendance.round()}%",
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textTertiaryColor,
                                    ),
                          ),
                          Text(
                            meetsAttendanceCriteria
                                ? "✓ Meeting requirement"
                                : "⚠ Below requirement",
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: meetsAttendanceCriteria
                                          ? AppTheme.greenColor
                                          : AppTheme.redColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColorElevated,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppTheme.textSecondaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "No classes have taken place yet",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (course.weeklyClasses.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColorElevated,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 18,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Schedule",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...course.weeklyClasses.map((weeklyClass) {
                        final days = weeklyClass.selectedDays.map((day) {
                          const dayNames = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun'
                          ];
                          return dayNames[day];
                        }).join(', ');

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.primaryColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  days,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "${weeklyClass.startTime.format(context)} - ${weeklyClass.endTime.format(context)}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showEditAttendanceDialog(
      BuildContext context, Course course, CourseProvider courseProvider) {
    final totalController =
        TextEditingController(text: course.totalClasses.toString());
    final attendedController =
        TextEditingController(text: course.attendedClasses.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColorElevated,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Edit Attendance",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Manually edit the attendance record for ${course.name}",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: totalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Total Classes",
                  hintText: "Enter total number of classes",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.class_rounded,
                      color: AppTheme.primaryColor),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: attendedController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Attended Classes",
                  hintText: "Enter number of attended classes",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.check_circle_rounded,
                      color: AppTheme.greenColor),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: AppTheme.textSecondaryColor),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () async {
                  final totalClasses = int.tryParse(totalController.text) ?? 0;
                  final attendedClasses =
                      int.tryParse(attendedController.text) ?? 0;

                  if (attendedClasses <= totalClasses) {
                    await courseProvider.editAttendance(
                        course.id, totalClasses, attendedClasses);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              const Text('Attendance updated successfully!'),
                          backgroundColor: AppTheme.greenColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            'Attended classes cannot exceed total classes!'),
                        backgroundColor: AppTheme.redColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                },
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showArchiveDialog(
      BuildContext context, Course course, CourseProvider courseProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColorElevated,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Archive Course",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            "Are you sure you want to archive '${course.name}'? You can restore it later from the archived courses section.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: AppTheme.textSecondaryColor),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.textSecondaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () async {
                  await courseProvider.archiveCourse(course.id, true);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${course.name} archived successfully!'),
                        backgroundColor: AppTheme.textSecondaryColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                },
                child: const Text(
                  "Archive",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(
      BuildContext context, Course course, CourseProvider courseProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColorElevated,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Delete Course",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            "Are you sure you want to delete '${course.name}'? This action cannot be undone and will remove all attendance records.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: AppTheme.textSecondaryColor),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.redColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () async {
                  await courseProvider.removeCourse(course.id);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${course.name} deleted successfully!'),
                        backgroundColor: AppTheme.redColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
