import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/meal.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onDelete;

  const MealCard({super.key, required this.meal, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(meal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${AppDateUtils.formatDate(meal.dateTime)} às ${AppDateUtils.formatTime(meal.dateTime)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${meal.calories} kcal', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent)),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}