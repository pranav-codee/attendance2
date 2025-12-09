import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import '../models/exam.dart';
import '../utils/app_theme.dart';
import 'add_exam_screen.dart';

class ExamsScreen extends StatelessWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<ExamProvider>(
          builder: (context, examProvider, child) {
            final upcomingExams = examProvider.upcomingExams;
            final pastExams = examProvider.pastExams;

            return CustomScrollView(
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
                                  "Exams",
                                  style:
                                      Theme.of(context).textTheme.headlineLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${upcomingExams.length} upcoming",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                ),
                              ],
                            ),
                            _buildAddButton(context),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                if (upcomingExams.isEmpty && pastExams.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(context),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (upcomingExams.isNotEmpty) ...[
                            _buildSectionHeader(context, "Upcoming Exams",
                                AppTheme.primaryColor),
                            const SizedBox(height: 16),
                            ...upcomingExams.map((exam) => _buildExamCard(
                                context, exam, examProvider, false)),
                            const SizedBox(height: 32),
                          ],
                          if (pastExams.isNotEmpty) ...[
                            _buildSectionHeader(context, "Past Exams",
                                AppTheme.textSecondaryColor),
                            const SizedBox(height: 16),
                            ...pastExams.map((exam) => _buildExamCard(
                                context, exam, examProvider, true)),
                          ],
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
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddExamScreen(),
              ),
            );
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
                Icons.event_note_rounded,
                size: 48,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No exams scheduled",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "Add your first exam to start tracking your schedule.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamCard(
      BuildContext context, Exam exam, ExamProvider provider, bool isPast) {
    final daysUntil = exam.daysUntilExam;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isPast) {
      statusColor = AppTheme.textSecondaryColor;
      statusText = "Completed";
      statusIcon = Icons.check_circle_outline_rounded;
    } else if (exam.isToday) {
      statusColor = AppTheme.orangeColor;
      statusText = "Today";
      statusIcon = Icons.event_available_rounded;
    } else if (daysUntil <= 7) {
      statusColor = AppTheme.redColor;
      statusText = "$daysUntil day${daysUntil != 1 ? 's' : ''} left";
      statusIcon = Icons.warning_rounded;
    } else {
      statusColor = AppTheme.primaryColor;
      statusText = "$daysUntil days left";
      statusIcon = Icons.event_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: AppTheme.extraLargeRadius,
        border: exam.isToday
            ? Border.all(color: AppTheme.orangeColor, width: 2)
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
                          exam.courseName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exam.courseCode,
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
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddExamScreen(examToEdit: exam),
                          ),
                        );
                      } else if (value == 'delete') {
                        _showDeleteDialog(context, exam, provider);
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
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_rounded,
                                color: AppTheme.primaryColor, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Edit Exam',
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
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline_rounded,
                                color: AppTheme.redColor, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Delete Exam',
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
              const SizedBox(height: 16),

              // Date and Time Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColorElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${exam.examDate.day}/${exam.examDate.month}/${exam.examDate.year}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 18,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          exam.timeRange,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Status Badge
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
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, Exam exam, ExamProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColorElevated,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Delete Exam",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            "Are you sure you want to delete the exam for '${exam.courseName}'?",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
                  await provider.deleteExam(exam.id);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${exam.courseName} exam deleted!'),
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
