import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/meal.dart';
import '../../auth/providers/auth_provider.dart';
import '../repositories/meals_repository.dart';

final mealRepositoryProvider = Provider((ref) {
  return MealRepository(ref.watch(localStorageServiceProvider));
});

final mealsProvider = StateNotifierProvider<MealsNotifier, List<Meal>>((ref) {
  return MealsNotifier(ref.watch(mealRepositoryProvider));
});

final allMealsForDashboardProvider = Provider<List<Meal>>((ref) {
  return ref.watch(mealsProvider);
});

class MealsNotifier extends StateNotifier<List<Meal>> {
  final MealRepository _repository;

  MealsNotifier(this._repository) : super([]) {
    loadMeals();
  }

  void loadMeals() {
    try {
      state = _repository.getMeals();
    } catch (e) {
      state = [];
    }
  }

  int get todayTotalCalories {
    return state
        .where((meal) => AppDateUtils.isToday(meal.dateTime))
        .fold(0, (sum, meal) => sum + meal.calories);
  }

  Future<void> addMeal(String name, int calories) async {
    try {
      if (name.trim().isEmpty || calories <= 0) {
        throw Exception('Nome e calorias devem ser válidos.');
      }

      final meal = Meal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        calories: calories,
        dateTime: DateTime.now(),
      );

      await _repository.saveMeal(meal);
      state = [...state, meal];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editMeal(String id, String newName, int newCalories) async {
    try {
      if (newName.trim().isEmpty || newCalories <= 0) {
        throw Exception('Nome e calorias devem ser válidos.');
      }

      final index = state.indexWhere((m) => m.id == id);
      if (index == -1) throw Exception('Refeição não encontrada.');

      final oldMeal = state[index];
      final updatedMeal = Meal(
        id: oldMeal.id,
        name: newName,
        calories: newCalories,
        dateTime: oldMeal.dateTime,
      );

      await _repository.saveMeal(updatedMeal);
      
      final newState = [...state];
      newState[index] = updatedMeal;
      state = newState;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMeal(String id) async {
    try {
      await _repository.deleteMeal(id);
      state = state.where((m) => m.id != id).toList();
    } catch (e) {
      rethrow;
    }
  }
}