import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/fitness_activity.dart';

class WeeklyChart extends StatelessWidget {
  final List<FitnessActivity> activities;

  const WeeklyChart({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    final dailyMinutes = List<int>.generate(7, (index) {
      final day = DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: (6 - index).toInt()));

      return activities
          .where(
            (activity) =>
                activity.date.year == day.year &&
                activity.date.month == day.month &&
                activity.date.day == day.day,
          )
          .fold<int>(0, (sum, activity) => sum + activity.duration);
    });

    final maxMinutes = dailyMinutes.fold<int>(
      60,
      (maxValue, value) => value > maxValue ? value : maxValue,
    );

    return Container(
      height: 260,
      padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: BarChart(
        BarChartData(
          maxY: (maxMinutes + 20).toDouble(),
          gridData: FlGridData(drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  if (index < 0 || index >= 7) {
                    return const SizedBox.shrink();
                  }

                  final day = DateTime(
                    today.year,
                    today.month,
                    today.day,
                  ).subtract(Duration(days: 6 - index));

                  const weekdays = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ];

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      weekdays[day.weekday - 1],
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(7, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: dailyMinutes[index].toDouble(),
                  width: 18,
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xFF6558F5),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
