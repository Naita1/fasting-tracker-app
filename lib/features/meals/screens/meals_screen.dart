import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/meals_provider.dart';
import '../widgets/add_edit_meal_dialog.dart';

class MealsScreen extends ConsumerWidget {
  const MealsScreen({super.key});

  Future<void> _addMeal(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const AddMealBottomSheet(),
    );

    if (result != null) {
      await ref.read(mealsProvider.notifier).addMeal(
            result['name'] as String,
            result['calories'] as int,
          );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(mealsProvider);
    final totalCalories = ref.read(mealsProvider.notifier).todayTotalCalories;

    return Scaffold(
      appBar: AppBar(title: const Text('Refeições')),
      body: meals.isEmpty
          ? const Center(child: Text('Nenhuma refeição registrada hoje.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: meals.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Total de hoje: $totalCalories kcal',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }

                final meal = meals[index - 1];
                return ListTile(
                  title: Text(meal.name),
                  subtitle: Text('${meal.calories} kcal'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => ref.read(mealsProvider.notifier).deleteMeal(meal.id),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addMeal(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}