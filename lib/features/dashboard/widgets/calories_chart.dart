import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CaloriesChart extends StatelessWidget {
  final int totalCalories;

  const CaloriesChart({super.key, required this.totalCalories});

  @override
  Widget build(BuildContext context) {
    if (totalCalories == 0) {
      return const Center(
        child: Text('Sem dados calóricos para exibir no gráfico.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: totalCalories.toDouble(),
                color: AppColors.accent,
                width: 32,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
        ],
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }
}