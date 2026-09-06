import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../provider/dashboard_provider.dart';
import '../widgets/weekly_bar_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Métricas & Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hoje',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Calorias Hoje',
                    value: '${metrics.todayTotalCalories} kcal',
                    icon: Icons.local_fire_department,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Jejum Hoje',
                    value: AppDateUtils.formatDuration(metrics.todayFastingDuration),
                    icon: Icons.timer,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _GoalStatusCard(
              current: metrics.todayFastingDuration,
              goal: metrics.todayFastingGoal,
              isWithinGoal: metrics.isWithinFastingGoal,
            ),
            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Sequência',
                    value: metrics.fastingStreak,
                    icon: Icons.bolt,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Média de Jejum',
                    value: metrics.averageFastingHours,
                    icon: Icons.timer,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'Consumo Calórico Semanal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 240,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: WeeklyBarChart(
                barGroups: metrics.weeklyCalorieBars,
                weekDays: metrics.weekDays,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalStatusCard extends StatelessWidget {
  final Duration current;
  final Duration goal;
  final bool isWithinGoal;

  const _GoalStatusCard({
    required this.current,
    required this.goal,
    required this.isWithinGoal,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWithinGoal ? AppColors.primary : Colors.orange;
    final label = isWithinGoal ? 'Dentro da meta' : 'Fora da meta';
    final goalHours = goal.inHours;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(isWithinGoal ? Icons.check_circle : Icons.info_outline, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label · Meta: ${goalHours}h de jejum',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}