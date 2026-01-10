import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import '../utils/app_theme.dart';
import '../services/notification_service.dart';
import '../services/export_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  final ExportService _exportService = ExportService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Settings",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 32),

              // Notification Settings
              Text(
                "Notifications",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildNotificationSettings(context),
              const SizedBox(height: 32),

              // Export Settings
              Text(
                "Export Data",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildExportSettings(context),
              const SizedBox(height: 32),

              // Contact Us
              Text(
                "Contact Us",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      color: AppTheme.textSecondaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "infinitus125365@gmail.com",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Data Management
              Text(
                "Data Management",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/archived-courses');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.archive_outlined,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "View Archived Courses",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showClearDataDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.redColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.delete_outline,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Clear All Data",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Master notification toggle
          Consumer<CourseProvider>(
            builder: (context, courseProvider, child) {
              return _buildSwitchTile(
                context,
                "Enable Notifications",
                "Master toggle for all notifications",
                courseProvider.notificationsEnabled,
                (value) async {
                  await courseProvider.setNotificationsEnabled(value);
                  if (value) {
                    await _notificationService.requestPermissions();
                  }
                },
              );
            },
          ),
          const Divider(color: AppTheme.surfaceColorHighlight),

          // Pre-class reminders
          _buildSwitchTile(
            context,
            "Pre-Class Reminders",
            "Get notified before class starts",
            _notificationService.preClassRemindersEnabled,
            (value) async {
              await _notificationService.setPreClassReminders(value);
              setState(() {});
            },
          ),
          const Divider(color: AppTheme.surfaceColorHighlight),

          // Reminder time picker
          _buildDropdownTile(
            context,
            "Reminder Time",
            "Minutes before class",
            _notificationService.reminderMinutesBefore,
            [5, 10, 15, 30],
            (value) async {
              await _notificationService.setReminderMinutes(value);
              setState(() {});
            },
          ),
          const Divider(color: AppTheme.surfaceColorHighlight),

          // Post-class prompts
          _buildSwitchTile(
            context,
            "Post-Class Prompts",
            "Remind to mark attendance after class",
            _notificationService.postClassPromptsEnabled,
            (value) async {
              await _notificationService.setPostClassPrompts(value);
              setState(() {});
            },
          ),
          const Divider(color: AppTheme.surfaceColorHighlight),

          // Daily summary
          _buildSwitchTile(
            context,
            "Daily Summary",
            "Morning notification with today's schedule",
            _notificationService.dailySummaryEnabled,
            (value) async {
              await _notificationService.setDailySummary(value);
              setState(() {});
            },
          ),
          const Divider(color: AppTheme.surfaceColorHighlight),

          // Daily summary time
          _buildTimeTile(
            context,
            "Summary Time",
            "Time for daily summary notification",
            _notificationService.dailySummaryTime,
            (time) async {
              await _notificationService.setDailySummaryTime(time);
              setState(() {});
            },
          ),
          const Divider(color: AppTheme.surfaceColorHighlight),

          // Low attendance warnings
          _buildSwitchTile(
            context,
            "Low Attendance Warnings",
            "Alert when attendance drops below required",
            _notificationService.lowAttendanceWarningsEnabled,
            (value) async {
              await _notificationService.setLowAttendanceWarnings(value);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primaryColor,
            activeTrackColor: AppTheme.primaryColor,
            thumbColor: WidgetStateProperty.all(Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(
    BuildContext context,
    String title,
    String subtitle,
    int value,
    List<int> options,
    Function(int) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColorElevated,
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButton<int>(
              value: value,
              underline: const SizedBox(),
              dropdownColor: AppTheme.surfaceColorElevated,
              items: options.map((option) {
                return DropdownMenuItem<int>(
                  value: option,
                  child: Text(
                    '$option min',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile(
    BuildContext context,
    String title,
    String subtitle,
    TimeOfDay value,
    Function(TimeOfDay) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: value,
              );
              if (picked != null) {
                onChanged(picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColorElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value.format(context),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _exportAttendance(context),
              icon: const Icon(Icons.file_download_outlined),
              label: const Text("Export Attendance Records"),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _exportCoursesSummary(context),
              icon: const Icon(Icons.summarize_outlined),
              label: const Text("Export Courses Summary"),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportAttendance(BuildContext context) async {
    try {
      final courseProvider =
          Provider.of<CourseProvider>(context, listen: false);
      await _exportService.shareAttendanceReport(
        courseProvider.classInstances,
        courseProvider.allCourses,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppTheme.redColor,
          ),
        );
      }
    }
  }

  Future<void> _exportCoursesSummary(BuildContext context) async {
    try {
      final courseProvider =
          Provider.of<CourseProvider>(context, listen: false);
      await _exportService.shareCoursesSummary(courseProvider.allCourses);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppTheme.redColor,
          ),
        );
      }
    }
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: Text(
            "Clear All Data",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            "Are you sure you want to clear all data? This will permanently delete all courses, classes, and attendance records. This action cannot be undone.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final courseProvider =
                    Provider.of<CourseProvider>(context, listen: false);
                await courseProvider.clearAllData();

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data cleared successfully!'),
                      backgroundColor: AppTheme.redColor,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.redColor,
              ),
              child: const Text("Clear All Data"),
            ),
          ],
        );
      },
    );
  }
}
