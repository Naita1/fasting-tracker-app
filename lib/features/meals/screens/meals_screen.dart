import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/meal.dart';
import '../providers/meals_provider.dart';
import '../widgets/add_meal_bottom_sheet.dart';
import '../widgets/meal_card.dart';

class MealsScreen extends ConsumerWidget {
  const MealsScreen({super.key});

  Future<void> _showMealForm(BuildContext context, WidgetRef ref, [Meal? mealToEdit]) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddMealBottomSheet(meal: mealToEdit),
    );

    if (result != null) {
      if (mealToEdit == null) {
        await ref.read(mealsProvider.notifier).addMeal(
              result['name'] as String,
              result['calories'] as int,
            );
      } else {
        await ref.read(mealsProvider.notifier).editMeal(
              mealToEdit.id,
              result['name'] as String,
              result['calories'] as int,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(mealsProvider);
    final totalCalories = ref.watch(mealsProvider.notifier).todayTotalCalories;
    return Scaffold(
      appBar: AppBar(title: const Text('Refeições')),
      body: meals.isEmpty
          ? const Center(child: Text('Nenhuma refeição registrada hoje.', style: TextStyle(color: AppColors.textSecondary)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: meals.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Total de hoje: $totalCalories kcal',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
                    ),
                  );
                }

                final meal = meals[index - 1];
                return MealCard(
                  meal: meal,
                  onEdit: () => _showMealForm(context, ref, meal),
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: const Text('Excluir refeição', style: TextStyle(color: AppColors.textPrimary)),
                        content: const Text('Deseja realmente remover esta refeição?', style: TextStyle(color: AppColors.textSecondary)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Excluir', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref.read(mealsProvider.notifier).deleteMeal(meal.id);
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showMealForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}