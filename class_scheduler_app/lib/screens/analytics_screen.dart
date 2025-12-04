import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import '../models/class_instance.dart';
import '../utils/app_theme.dart';
import '../widgets/attendance_chart.dart';
import '../widgets/streak_widget.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<CourseProvider>(
          builder: (context, courseProvider, child) {
            final courses = courseProvider.courses;
            final classInstances = courseProvider.classInstances;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Analytics",
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Track your attendance progress",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Streak Card
                        StreakCard(
                          streakDays: courseProvider.currentStreak,
                          bestStreak: courseProvider.bestStreak,
                        ),
                        const SizedBox(height: 24),

                        // Overall Statistics
                        _buildOverallStats(context, classInstances),
                        const SizedBox(height: 24),

                        // Attendance Pie Chart
                        _buildAttendancePieChart(context, classInstances),
                        const SizedBox(height: 24),

                        // Weekly Attendance Chart
                        _buildWeeklyChart(context, classInstances),
                        const SizedBox(height: 24),

                        // Per-Course Breakdown
                        Text(
                          "Course Breakdown",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ...courses.map((course) =>
                            _buildCourseBreakdown(context, course, classInstances)),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverallStats(
      BuildContext context, List<ClassInstance> classInstances) {
    final now = DateTime.now();
    final pastClasses = classInstances.where((c) {
      final classEnd = DateTime(
        c.date.year,
        c.date.month,
        c.date.day,
        c.endTime.hour,
        c.endTime.minute,
      );
      return classEnd.isBefore(now);
    }).toList();

    final attended = pastClasses
        .where((c) => c.attendanceStatus == AttendanceStatus.attended)
        .length;
    final missed = pastClasses
        .where((c) => c.attendanceStatus == AttendanceStatus.missed)
        .length;
    final cancelled = pastClasses
        .where((c) => c.attendanceStatus == AttendanceStatus.cancelled)
        .length;
    final total = attended + missed;
    final overallPercentage = total > 0 ? (attended / total) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: AppTheme.extraLargeRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Statistics',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                'Attended',
                attended.toString(),
                AppTheme.greenColor,
                Icons.check_circle_rounded,
              ),
              _buildStatItem(
                context,
                'Missed',
                missed.toString(),
                AppTheme.redColor,
                Icons.cancel_rounded,
              ),
              _buildStatItem(
                context,
                'Cancelled',
                cancelled.toString(),
                AppTheme.yellowColor,
                Icons.event_busy_rounded,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColorElevated,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Overall Attendance: ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                ),
                Text(
                  '${overallPercentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: overallPercentage >= 75
                            ? AppTheme.greenColor
                            : overallPercentage >= 50
                                ? AppTheme.orangeColor
                                : AppTheme.redColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
        ),
      ],
    );
  }

  Widget _buildAttendancePieChart(
      BuildContext context, List<ClassInstance> classInstances) {
    final now = DateTime.now();
    final pastClasses = classInstances.where((c) {
      final classEnd = DateTime(
        c.date.year,
        c.date.month,
        c.date.day,
        c.endTime.hour,
        c.endTime.minute,
      );
      return classEnd.isBefore(now);
    }).toList();

    final attended = pastClasses
        .where((c) => c.attendanceStatus == AttendanceStatus.attended)
        .length;
    final missed = pastClasses
        .where((c) => c.attendanceStatus == AttendanceStatus.missed)
        .length;
    final cancelled = pastClasses
        .where((c) => c.attendanceStatus == AttendanceStatus.cancelled)
        .length;
    final pending = pastClasses
        .where((c) => c.attendanceStatus == AttendanceStatus.pending)
        .length;

    return AttendancePieChart(
      attended: attended,
      missed: missed,
      cancelled: cancelled,
      pending: pending,
    );
  }

  Widget _buildWeeklyChart(
      BuildContext context, List<ClassInstance> classInstances) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    final List<double> weeklyData = [];
    final List<String> labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final dayClasses = classInstances.where((c) {
        return c.date.year == day.year &&
            c.date.month == day.month &&
            c.date.day == day.day &&
            c.attendanceStatus != AttendanceStatus.pending;
      }).toList();

      if (dayClasses.isEmpty) {
        weeklyData.add(0);
      } else {
        final attended = dayClasses
            .where((c) => c.attendanceStatus == AttendanceStatus.attended)
            .length;
        final total = dayClasses
            .where((c) => c.attendanceStatus != AttendanceStatus.cancelled)
            .length;
        weeklyData.add(total > 0 ? (attended / total) * 100 : 0);
      }
    }

    return AttendanceChart(
      weeklyData: weeklyData,
      labels: labels,
      title: 'This Week\'s Attendance',
    );
  }

  Widget _buildCourseBreakdown(
    BuildContext context,
    course,
    List<ClassInstance> classInstances,
  ) {
    final courseClasses = classInstances
        .where((c) => c.courseId == course.id)
        .toList();

    final attended = courseClasses
        .where((c) => c.attendanceStatus == AttendanceStatus.attended)
        .length;
    final missed = courseClasses
        .where((c) => c.attendanceStatus == AttendanceStatus.missed)
        .length;
    final total = attended + missed;
    final percentage = total > 0 ? (attended / total) * 100 : 0.0;
    final isOnTrack = percentage >= course.requiredAttendance;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: AppTheme.largeRadius,
        border: Border.all(
          color: isOnTrack
              ? AppTheme.greenColor.withOpacity(0.3)
              : total > 0
                  ? AppTheme.redColor.withOpacity(0.3)
                  : AppTheme.surfaceColorHighlight,
        ),
      ),
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
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      course.courseId,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isOnTrack
                      ? AppTheme.greenColor.withOpacity(0.15)
                      : total > 0
                          ? AppTheme.redColor.withOpacity(0.15)
                          : AppTheme.surfaceColorElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isOnTrack
                            ? AppTheme.greenColor
                            : total > 0
                                ? AppTheme.redColor
                                : AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniStat(context, 'Attended', attended, AppTheme.greenColor),
              const SizedBox(width: 16),
              _buildMiniStat(context, 'Missed', missed, AppTheme.redColor),
              const SizedBox(width: 16),
              _buildMiniStat(context, 'Required', '${course.requiredAttendance.round()}%',
                  AppTheme.textSecondaryColor),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              backgroundColor: AppTheme.surfaceColorHighlight,
              valueColor: AlwaysStoppedAnimation(
                isOnTrack ? AppTheme.greenColor : AppTheme.redColor,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(BuildContext context, String label, dynamic value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $value',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
        ),
      ],
    );
  }
}
