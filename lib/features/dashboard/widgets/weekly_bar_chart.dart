import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<BarChartGroupData> barGroups;
  final List<String> weekDays;

  const WeeklyBarChart({
    super.key,
    required this.barGroups,
    required this.weekDays,
  });

  @override
  Widget build(BuildContext context) {
    if (barGroups.isEmpty) {
      return const Center(
        child: Text(
          'Sem dados para exibir no gráfico.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: barGroups,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();

                if (index < 0 || index >= weekDays.length) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    weekDays[index],
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}