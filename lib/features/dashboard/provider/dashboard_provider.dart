import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../fasting/providers/fasting_provider.dart';
import '../../history/providers/history_provider.dart';
import '../../meals/providers/meals_provider.dart';

class DashboardMetrics {
  final String fastingStreak;
  final String averageFastingHours;
  final List<BarChartGroupData> weeklyCalorieBars;
  final List<String> weekDays;
  final int todayTotalCalories;
  final Duration todayFastingDuration;
  final Duration todayFastingGoal;
  final bool isWithinFastingGoal;

  const DashboardMetrics({
    required this.fastingStreak,
    required this.averageFastingHours,
    required this.weeklyCalorieBars,
    required this.weekDays,
    required this.todayTotalCalories,
    required this.todayFastingDuration,
    required this.todayFastingGoal,
    required this.isWithinFastingGoal,
  });
}

final dashboardProvider = Provider<DashboardMetrics>((ref) {
  final allMeals = ref.watch(mealsProvider);
  final historyState = ref.watch(historyProvider);
  final fastingState = ref.watch(fastingNotifierProvider);

  final allSessions = historyState.sessions;
  final currentSession = fastingState.session;

  final today = DateTime.now();
  final normalizedToday = DateTime(today.year, today.month, today.day);

  bool isToday(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d == normalizedToday;
  }

  final todayTotalCalories = allMeals
      .where((meal) => AppDateUtils.isToday(meal.dateTime))
      .fold<int>(0, (sum, meal) => sum + meal.calories);

  Duration todayFastingDuration = allSessions
      .where((s) => isToday(s.startedAt))
      .fold<Duration>(Duration.zero, (sum, s) => sum + s.elapsedTime);

  if (currentSession != null && isToday(currentSession.startedAt)) {
    todayFastingDuration += currentSession.elapsedTime;
  }

  int goalHours = 16;
  if (currentSession != null && isToday(currentSession.startedAt)) {
    goalHours = currentSession.protocol.fastingHours;
  } else {
    final todaysSessions = allSessions.where((s) => isToday(s.startedAt)).toList();
    if (todaysSessions.isNotEmpty) {
      goalHours = todaysSessions.last.protocol.fastingHours;
    }
  }
  final todayFastingGoal = Duration(hours: goalHours);
  final isWithinFastingGoal = todayFastingDuration >= todayFastingGoal;

  final Map<int, double> dailyCalories = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
  final List<String> weekDays = [];

  for (int i = 6; i >= 0; i--) {
    final date = normalizedToday.subtract(Duration(days: i));
    final dayLabel = AppDateUtils.formatDate(date, format: 'E').toUpperCase().substring(0, 1);
    weekDays.add(dayLabel);
  }

  for (final meal in allMeals) {
    final mealDate = DateTime(meal.dateTime.year, meal.dateTime.month, meal.dateTime.day);
    final differenceInDays = normalizedToday.difference(mealDate).inDays;

    if (differenceInDays >= 0 && differenceInDays < 7) {
      final barIndex = 6 - differenceInDays;
      dailyCalories[barIndex] = (dailyCalories[barIndex] ?? 0) + meal.calories;
    }
  }

  final weeklyCalorieBars = dailyCalories.entries.map((entry) {
    return BarChartGroupData(
      x: entry.key,
      barRods: [
        BarChartRodData(
          toY: entry.value,
          gradient: const LinearGradient(
            colors: [AppColors.accent, Colors.orangeAccent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 18,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }).toList();

  final completedSessions = allSessions.where((s) => s.status == 'completed').toList();
  String averageFastingHours = '0.0h';

  if (completedSessions.isNotEmpty) {
    final totalHours = completedSessions
        .map((s) => s.elapsedTime.inMinutes / 60.0)
        .fold(0.0, (prev, curr) => prev + curr);

    final avg = totalHours / completedSessions.length;
    averageFastingHours = '${avg.toStringAsFixed(1)}h';
  }

  int streak = 0;
  if (completedSessions.isNotEmpty) {
    final uniqueFastingDays = completedSessions
        .map((s) => DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    DateTime currentCheckDate = normalizedToday;

    if (uniqueFastingDays.isNotEmpty && !uniqueFastingDays.contains(currentCheckDate)) {
      currentCheckDate = normalizedToday.subtract(const Duration(days: 1));
    }

    while (uniqueFastingDays.contains(currentCheckDate)) {
      streak++;
      currentCheckDate = currentCheckDate.subtract(const Duration(days: 1));
    }
  }

  return DashboardMetrics(
    fastingStreak: '$streak ${streak == 1 ? "Dia" : "Dias"}',
    averageFastingHours: averageFastingHours,
    weeklyCalorieBars: weeklyCalorieBars,
    weekDays: weekDays,
    todayTotalCalories: todayTotalCalories,
    todayFastingDuration: todayFastingDuration,
    todayFastingGoal: todayFastingGoal,
    isWithinFastingGoal: isWithinFastingGoal,
  );
});