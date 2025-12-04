import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class StreakWidget extends StatelessWidget {
  final int streakDays;
  final bool compact;

  const StreakWidget({
    super.key,
    required this.streakDays,
    this.compact = false,
  });

  String get _streakEmoji {
    if (streakDays >= 30) return '🔥';
    if (streakDays >= 14) return '⭐';
    if (streakDays >= 7) return '✨';
    return '🎯';
  }

  String get _streakMessage {
    if (streakDays >= 30) return 'Amazing streak!';
    if (streakDays >= 14) return 'Great progress!';
    if (streakDays >= 7) return 'Keep it up!';
    if (streakDays > 0) return 'Good start!';
    return 'Start your streak!';
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactStreak(context);
    }
    return _buildFullStreak(context);
  }

  Widget _buildCompactStreak(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: streakDays > 0
            ? LinearGradient(
                colors: [
                  AppTheme.orangeColor.withOpacity(0.2),
                  AppTheme.yellowColor.withOpacity(0.2),
                ],
              )
            : null,
        color: streakDays == 0 ? AppTheme.surfaceColor : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: streakDays > 0
              ? AppTheme.orangeColor.withOpacity(0.3)
              : AppTheme.surfaceColorHighlight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _streakEmoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 6),
          Text(
            '$streakDays day${streakDays != 1 ? 's' : ''}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: streakDays > 0
                      ? AppTheme.orangeColor
                      : AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullStreak(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: streakDays > 0
            ? LinearGradient(
                colors: [
                  AppTheme.orangeColor.withOpacity(0.15),
                  AppTheme.yellowColor.withOpacity(0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: streakDays == 0 ? AppTheme.surfaceColor : null,
        borderRadius: AppTheme.extraLargeRadius,
        border: streakDays > 0
            ? Border.all(color: AppTheme.orangeColor.withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: streakDays > 0
                  ? AppTheme.orangeColor.withOpacity(0.2)
                  : AppTheme.surfaceColorElevated,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                _streakEmoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _streakMessage,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: streakDays > 0
                            ? AppTheme.orangeColor
                            : AppTheme.textSecondaryColor,
                      ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$streakDays',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: streakDays > 0
                                  ? AppTheme.textPrimaryColor
                                  : AppTheme.textSecondaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextSpan(
                        text: ' day${streakDays != 1 ? 's' : ''} streak',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (streakDays >= 7) _buildMilestone(context),
        ],
      ),
    );
  }

  Widget _buildMilestone(BuildContext context) {
    int milestone = 0;
    String milestoneText = '';

    if (streakDays >= 30) {
      milestone = 30;
      milestoneText = '30 days!';
    } else if (streakDays >= 14) {
      milestone = 14;
      milestoneText = '2 weeks!';
    } else if (streakDays >= 7) {
      milestone = 7;
      milestoneText = '1 week!';
    }

    if (milestone == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.greenColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: AppTheme.greenColor,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            milestoneText,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.greenColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class StreakCard extends StatelessWidget {
  final int streakDays;
  final int bestStreak;
  final VoidCallback? onTap;

  const StreakCard({
    super.key,
    required this.streakDays,
    required this.bestStreak,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: AppTheme.extraLargeRadius,
        ),
        child: Column(
          children: [
            StreakWidget(streakDays: streakDays),
            const SizedBox(height: 16),
            const Divider(color: AppTheme.surfaceColorHighlight),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, 'Current', streakDays,
                    Icons.local_fire_department_rounded),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.surfaceColorHighlight,
                ),
                _buildStatItem(
                    context, 'Best', bestStreak, Icons.emoji_events_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, int value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$value day${value != 1 ? 's' : ''}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
