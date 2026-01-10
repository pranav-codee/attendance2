import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/course_provider.dart';
import '../models/class_instance.dart';
import '../models/course.dart';
import '../utils/app_theme.dart';

class TodaysClassesScreen extends StatefulWidget {
  const TodaysClassesScreen({super.key});

  @override
  State<TodaysClassesScreen> createState() => _TodaysClassesScreenState();
}

class _TodaysClassesScreenState extends State<TodaysClassesScreen> {
  Timer? _refreshTimer;
  bool _isHoliday = false;

  @override
  void initState() {
    super.initState();
    _loadHolidayState();
    // Auto-refresh every minute to update class status
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadHolidayState() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final savedDate = prefs.getString('holidayDate');
    final todayString = '${today.year}-${today.month}-${today.day}';

    if (savedDate == todayString) {
      setState(() {
        _isHoliday = prefs.getBool('isHoliday') ?? false;
      });
    } else {
      // Reset holiday status for new day
      await prefs.setBool('isHoliday', false);
      await prefs.setString('holidayDate', todayString);
      setState(() {
        _isHoliday = false;
      });
    }
  }

  Future<void> _toggleHoliday(bool value, CourseProvider courseProvider) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';

    await prefs.setBool('isHoliday', value);
    await prefs.setString('holidayDate', todayString);

    setState(() {
      _isHoliday = value;
    });

    if (value) {
      // Mark all today's pending classes as cancelled
      final todaysClasses = courseProvider.getTodaysClasses();
      for (final classInstance in todaysClasses) {
        if (classInstance.attendanceStatus == AttendanceStatus.pending) {
          await courseProvider.markAttendance(
              classInstance.id, AttendanceStatus.cancelled);
        }
      }
      if (mounted) {
        _showSnackBar(context, 'All classes marked as cancelled for holiday!',
            AppTheme.orangeColor);
      }
    }
  }

  void _refreshScreen(CourseProvider courseProvider) {
    HapticFeedback.lightImpact();
    courseProvider.generateTodaysClasses();
    setState(() {});
    _showSnackBar(context, 'Refreshed!', AppTheme.primaryColor);
  }

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
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Today's Classes",
                                style:
                                    Theme.of(context).textTheme.headlineLarge,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getFormattedDate(),
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Consumer<CourseProvider>(
                              builder: (context, courseProvider, child) {
                                return _buildRefreshButton(
                                    context, courseProvider);
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildAddButton(context),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Holiday Toggle
                    Consumer<CourseProvider>(
                      builder: (context, courseProvider, child) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: _isHoliday
                                ? AppTheme.orangeColor.withOpacity(0.15)
                                : AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isHoliday
                                  ? AppTheme.orangeColor.withOpacity(0.3)
                                  : AppTheme.surfaceColorHighlight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isHoliday
                                    ? Icons.beach_access_rounded
                                    : Icons.calendar_today_rounded,
                                color: _isHoliday
                                    ? AppTheme.orangeColor
                                    : AppTheme.textSecondaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Holiday Mode',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: _isHoliday
                                            ? AppTheme.orangeColor
                                            : AppTheme.textPrimaryColor,
                                      ),
                                ),
                              ),
                              Switch(
                                value: _isHoliday,
                                onChanged: (value) =>
                                    _toggleHoliday(value, courseProvider),
                                activeColor: AppTheme.orangeColor,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Consumer<CourseProvider>(
                      builder: (context, courseProvider, child) {
                        if (courseProvider.currentStreak == 0) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.orangeColor.withOpacity(0.15),
                                AppTheme.yellowColor.withOpacity(0.1),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.orangeColor.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                courseProvider.currentStreak >= 30
                                    ? '🔥'
                                    : courseProvider.currentStreak >= 14
                                        ? '⭐'
                                        : courseProvider.currentStreak >= 7
                                            ? '✨'
                                            : '🎯',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${courseProvider.currentStreak} day streak!',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: AppTheme.orangeColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      courseProvider.currentStreak >= 30
                                          ? 'Amazing progress!'
                                          : courseProvider.currentStreak >= 14
                                              ? 'Keep the momentum!'
                                              : courseProvider.currentStreak >=
                                                      7
                                                  ? 'Great consistency!'
                                                  : 'Keep it up!',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppTheme.textSecondaryColor,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Consumer<CourseProvider>(
                builder: (context, courseProvider, child) {
                  final todaysClasses = courseProvider.getTodaysClasses();
                  final upcomingClasses = courseProvider.upcomingClasses;

                  if (todaysClasses.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  todaysClasses.sort((a, b) {
                    return a.startTime.hour * 60 +
                        a.startTime.minute -
                        (b.startTime.hour * 60 + b.startTime.minute);
                  });

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (upcomingClasses.isNotEmpty) ...[
                          _buildSectionHeader(context, "Upcoming Classes",
                              AppTheme.primaryColor),
                          const SizedBox(height: 16),
                          ...upcomingClasses.map((classInstance) {
                            final course = courseProvider
                                .getCourseById(classInstance.courseId);
                            if (course == null) return const SizedBox.shrink();
                            return _buildClassCard(
                                context, classInstance, course, courseProvider,
                                isUpcoming: true);
                          }),
                          const SizedBox(height: 32),
                        ],
                        _buildSectionHeader(context, "All Classes Today",
                            AppTheme.textPrimaryColor),
                        const SizedBox(height: 16),
                        ...todaysClasses.asMap().entries.map((entry) {
                          final index = entry.key;
                          final classInstance = entry.value;
                          final course = courseProvider
                              .getCourseById(classInstance.courseId);

                          if (course == null) return const SizedBox.shrink();

                          return AnimatedContainer(
                            duration:
                                Duration(milliseconds: 200 + (index * 100)),
                            child: _buildClassCard(
                                context, classInstance, course, courseProvider),
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
          onTap: () {
            Navigator.pushNamed(context, '/add-course');
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

  Widget _buildRefreshButton(
      BuildContext context, CourseProvider courseProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.surfaceColorHighlight,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _refreshScreen(courseProvider),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: AppTheme.textSecondaryColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
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
                Icons.calendar_today_rounded,
                size: 48,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No classes today!",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "Enjoy your free day or add a new course to get started.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return "${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}";
  }

  Widget _buildClassCard(BuildContext context, ClassInstance classInstance,
      Course course, CourseProvider courseProvider,
      {bool isUpcoming = false}) {
    final now = DateTime.now();
    final classDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      classInstance.startTime.hour,
      classInstance.startTime.minute,
    );
    final endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      classInstance.endTime.hour,
      classInstance.endTime.minute,
    );

    final isCurrentlyUpcoming = now.isBefore(classDateTime);
    final isOngoing = now.isAfter(classDateTime) && now.isBefore(endDateTime);
    final isPast = now.isAfter(endDateTime);

    Color statusColor = AppTheme.textSecondaryColor;
    String statusText = "Scheduled";
    IconData statusIcon = Icons.schedule_rounded;

    if (isOngoing) {
      statusColor = AppTheme.orangeColor;
      statusText = "Ongoing";
      statusIcon = Icons.play_circle_outline_rounded;
    } else if (isPast) {
      switch (classInstance.attendanceStatus) {
        case AttendanceStatus.attended:
          statusColor = AppTheme.primaryColor;
          statusText = "Attended";
          statusIcon = Icons.check_circle_outline_rounded;
          break;
        case AttendanceStatus.missed:
          statusColor = AppTheme.primaryColor;
          statusText = "Missed";
          statusIcon = Icons.cancel_outlined;
          break;
        case AttendanceStatus.cancelled:
          statusColor = AppTheme.primaryColor;
          statusText = "Cancelled";
          statusIcon = Icons.event_busy_rounded;
          break;
        case AttendanceStatus.pending:
          statusColor = AppTheme.textSecondaryColor;
          statusText = "Pending";
          statusIcon = Icons.help_outline_rounded;
          break;
      }
    } else if (isCurrentlyUpcoming) {
      statusColor = AppTheme.primaryColor;
      statusText = "Upcoming";
      statusIcon = Icons.upcoming_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: AppTheme.extraLargeRadius,
        border: isUpcoming
            ? Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 1.5,
              )
            : null,
        boxShadow: isUpcoming
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                        Text(
                          course.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          color: statusColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColorElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 18,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${classInstance.startTime.format(context)} - ${classInstance.endTime.format(context)}",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              if (isPast &&
                  classInstance.attendanceStatus ==
                      AttendanceStatus.pending) ...[
                const SizedBox(height: 16),
                _buildAttendanceButtons(context, classInstance, courseProvider),
              ],
              if (isPast &&
                  classInstance.attendanceStatus !=
                      AttendanceStatus.pending) ...[
                const SizedBox(height: 16),
                _buildChangeStatusButton(
                    context, classInstance, courseProvider),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceButtons(BuildContext context,
      ClassInstance classInstance, CourseProvider courseProvider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildAttendanceButton(
                context: context,
                label: 'Attended',
                icon: Icons.check_rounded,
                color: AppTheme.primaryColorDark,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  courseProvider.markAttendance(
                      classInstance.id, AttendanceStatus.attended);
                  _showSnackBar(context, 'Marked as attended!',
                      AppTheme.primaryColorDark);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAttendanceButton(
                context: context,
                label: 'Missed',
                icon: Icons.close_rounded,
                color: AppTheme.primaryColorDark,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  courseProvider.markAttendance(
                      classInstance.id, AttendanceStatus.missed);
                  _showSnackBar(
                      context, 'Marked as missed', AppTheme.primaryColorDark);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: _buildAttendanceButton(
            context: context,
            label: 'Cancelled',
            icon: Icons.event_busy_rounded,
            color: AppTheme.primaryColorDark,
            onPressed: () {
              HapticFeedback.lightImpact();
              courseProvider.markAttendance(
                  classInstance.id, AttendanceStatus.cancelled);
              _showSnackBar(
                  context, 'Marked as cancelled', AppTheme.primaryColorDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChangeStatusButton(BuildContext context,
      ClassInstance classInstance, CourseProvider courseProvider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceColorHighlight, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () =>
              _showChangeStatusDialog(context, classInstance, courseProvider),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit_rounded,
                    size: 18, color: AppTheme.textSecondaryColor),
                const SizedBox(width: 8),
                Text(
                  'Change Status',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChangeStatusDialog(BuildContext context,
      ClassInstance classInstance, CourseProvider courseProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColorElevated,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Change Attendance Status",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusOption(
                  context, 'Attended', Icons.check_rounded, AppTheme.greenColor,
                  () {
                courseProvider.markAttendance(
                    classInstance.id, AttendanceStatus.attended);
                Navigator.of(context).pop();
                _showSnackBar(
                    context, 'Changed to attended', AppTheme.greenColor);
              }),
              const SizedBox(height: 8),
              _buildStatusOption(
                  context, 'Missed', Icons.close_rounded, AppTheme.redColor,
                  () {
                courseProvider.markAttendance(
                    classInstance.id, AttendanceStatus.missed);
                Navigator.of(context).pop();
                _showSnackBar(context, 'Changed to missed', AppTheme.redColor);
              }),
              const SizedBox(height: 8),
              _buildStatusOption(context, 'Cancelled', Icons.event_busy_rounded,
                  AppTheme.yellowColor, () {
                courseProvider.markAttendance(
                    classInstance.id, AttendanceStatus.cancelled);
                Navigator.of(context).pop();
                _showSnackBar(
                    context, 'Changed to cancelled', AppTheme.yellowColor);
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusOption(BuildContext context, String label, IconData icon,
      Color color, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
