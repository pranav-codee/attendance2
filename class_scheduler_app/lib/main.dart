import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'providers/course_provider.dart';
import 'screens/todays_classes_screen.dart';
import 'screens/my_courses_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/add_course_screen.dart';
import 'screens/archived_courses_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CourseProvider()
        ..loadData().then((_) =>
            Provider.of<CourseProvider>(context, listen: false)
                .generateTodaysClasses()),
      child: MaterialApp(
        title: 'Class Scheduler',
        theme: AppTheme.darkTheme,
        home: const MainScreen(),
        routes: {
          '/add-course': (context) => const AddCourseScreen(),
          '/archived-courses': (context) => const ArchivedCoursesScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
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
                _buildNavItem(2, Icons.settings_rounded, "Settings"),
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
