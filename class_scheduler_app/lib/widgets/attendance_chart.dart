import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/app_theme.dart';

class AttendanceChart extends StatelessWidget {
  final List<double> weeklyData;
  final List<String> labels;
  final String title;

  const AttendanceChart({
    super.key,
    required this.weeklyData,
    required this.labels,
    this.title = 'Weekly Attendance',
  });

  @override
  Widget build(BuildContext context) {
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
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppTheme.surfaceColorElevated,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toStringAsFixed(1)}%',
                        const TextStyle(
                          color: AppTheme.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[index],
                              style: const TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 35,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.surfaceColorHighlight,
                      strokeWidth: 1,
                    );
                  },
                ),
                barGroups: weeklyData.asMap().entries.map((entry) {
                  final color = entry.value >= 75
                      ? AppTheme.greenColor
                      : entry.value >= 50
                          ? AppTheme.orangeColor
                          : AppTheme.redColor;
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: color,
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AttendancePieChart extends StatelessWidget {
  final int attended;
  final int missed;
  final int cancelled;
  final int pending;

  const AttendancePieChart({
    super.key,
    required this.attended,
    required this.missed,
    required this.cancelled,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    final total = attended + missed + cancelled + pending;
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: AppTheme.extraLargeRadius,
        ),
        child: Center(
          child: Text(
            'No attendance data yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
        ),
      );
    }

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
            'Attendance Breakdown',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 150,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        if (attended > 0)
                          PieChartSectionData(
                            color: AppTheme.greenColor,
                            value: attended.toDouble(),
                            title: '',
                            radius: 30,
                          ),
                        if (missed > 0)
                          PieChartSectionData(
                            color: AppTheme.redColor,
                            value: missed.toDouble(),
                            title: '',
                            radius: 30,
                          ),
                        if (cancelled > 0)
                          PieChartSectionData(
                            color: AppTheme.yellowColor,
                            value: cancelled.toDouble(),
                            title: '',
                            radius: 30,
                          ),
                        if (pending > 0)
                          PieChartSectionData(
                            color: AppTheme.textSecondaryColor,
                            value: pending.toDouble(),
                            title: '',
                            radius: 30,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(
                      context, 'Attended', attended, AppTheme.greenColor),
                  const SizedBox(height: 8),
                  _buildLegendItem(
                      context, 'Missed', missed, AppTheme.redColor),
                  const SizedBox(height: 8),
                  _buildLegendItem(
                      context, 'Cancelled', cancelled, AppTheme.yellowColor),
                  const SizedBox(height: 8),
                  _buildLegendItem(context, 'Pending', pending,
                      AppTheme.textSecondaryColor),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
      BuildContext context, String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: $count',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
        ),
      ],
    );
  }
}

class MonthlyTrendChart extends StatelessWidget {
  final List<double> monthlyData;
  final List<String> months;

  const MonthlyTrendChart({
    super.key,
    required this.monthlyData,
    required this.months,
  });

  @override
  Widget build(BuildContext context) {
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
            'Monthly Trend',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.surfaceColorHighlight,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              months[index],
                              style: const TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 35,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (monthlyData.length - 1).toDouble(),
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: monthlyData.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value);
                    }).toList(),
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.primaryColor,
                          strokeWidth: 2,
                          strokeColor: AppTheme.surfaceColor,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryColor.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
