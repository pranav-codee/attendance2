import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'providers/course_provider.dart';
import 'screens/todays_classes_screen.dart';
import 'screens/my_courses_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/add_course_screen.dart';
import 'screens/archived_courses_screen.dart';
import 'screens/analytics_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final provider = CourseProvider();
        provider.loadData().then((_) {
          provider.generateTodaysClasses();
          // Schedule notifications for today's classes
          _scheduleNotifications(provider);
        });
        return provider;
      },
      child: MaterialApp(
        title: 'Class Scheduler',
        theme: AppTheme.darkTheme,
        home: const MainScreen(),
        routes: {
          '/add-course': (context) => const AddCourseScreen(),
          '/archived-courses': (context) => const ArchivedCoursesScreen(),
          '/analytics': (context) => const AnalyticsScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  void _scheduleNotifications(CourseProvider provider) async {
    if (!provider.notificationsEnabled) return;

    final notificationService = NotificationService();
    final todaysClasses = provider.getTodaysClasses();
    final courses = provider.allCourses;

    await notificationService.scheduleNotificationsForTodaysClasses(
      todaysClasses,
      courses,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TodaysClassesScreen(),
    const MyCoursesScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: AppTheme.fastAnimation,
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          border: Border(
            top: BorderSide(
              color: AppTheme.surfaceColorHighlight,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.calendar_today_rounded, "Today"),
                _buildNavItem(1, Icons.school_rounded, "Courses"),
                _buildNavItem(2, Icons.analytics_rounded, "Analytics"),
                _buildNavItem(3, Icons.settings_rounded, "Settings"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: AppTheme.fastAnimation,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: AppTheme.largeRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: AppTheme.fastAnimation,
              child: Icon(
                icon,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: AppTheme.fastAnimation,
              style: TextStyle(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondaryColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.1,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
