import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Settings",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 40),
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
              Text(
                "Project",
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
                      Icons.code,
                      color: AppTheme.textSecondaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "GitHub Repository",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Notifications",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Enable Notifications",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Consumer<CourseProvider>(
                    builder: (context, courseProvider, child) {
                      return Switch(
                        value: courseProvider.notificationsEnabled,
                        onChanged: (value) {
                          courseProvider.setNotificationsEnabled(value);
                        },
                        activeColor: AppTheme.primaryColor,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
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
            ],
          ),
        ),
      ),
    );
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
