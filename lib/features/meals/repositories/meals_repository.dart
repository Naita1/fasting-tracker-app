import '../../../core/constants/app_constants.dart';
import '../../../models/meal.dart';
import '../../../services/local_storage_service.dart';

class MealRepository {
  final LocalStorageService _storage;

  MealRepository(this._storage);

  Future<void> saveMeal(Meal meal) async {
    await _storage.put(AppConstants.mealsBox, meal.id, meal.toMap());
  }

  List<Meal> getMeals() {
    final rawList = _storage.getAll(AppConstants.mealsBox);
    return rawList.map((map) => Meal.fromMap(map)).toList();
  }

  Future<void> deleteMeal(String id) async {
    await _storage.delete(AppConstants.mealsBox, id);
  }
}