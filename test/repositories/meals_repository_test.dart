import 'package:flutter_test/flutter_test.dart';
import 'package:fasting_tracker_app/models/meal.dart';
import 'package:fasting_tracker_app/features/meals/repositories/meals_repository.dart';
import 'package:fasting_tracker_app/services/local_storage_service.dart';
import 'package:fasting_tracker_app/core/constants/app_constants.dart';

/// Implementação in-memory de [LocalStorageService] para testes.
class FakeLocalStorageService implements LocalStorageService {
  final Map<String, Map<String, Map<String, dynamic>>> _store = {};

  @override
  Future<void> put(
    String boxName,
    String key,
    Map<String, dynamic> value,
  ) async {
    _store[boxName] ??= {};
    _store[boxName]![key] = Map<String, dynamic>.from(value);
  }

  @override
  Map<String, dynamic>? get(String boxName, String key) {
    return _store[boxName]?[key];
  }

  @override
  List<Map<String, dynamic>> getAll(String boxName) {
    final box = _store[boxName];
    if (box == null) return [];
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  Future<void> delete(String boxName, String key) async {
    _store[boxName]?.remove(key);
  }
}

void main() {
  late FakeLocalStorageService fakeStorage;
  late MealRepository repository;

  Meal makeMeal({
    String id = 'meal-1',
    String name = 'Almoço',
    int calories = 500,
    DateTime? dateTime,
  }) {
    return Meal(
      id: id,
      name: name,
      calories: calories,
      dateTime: dateTime ?? DateTime(2024, 6, 15, 12, 0),
    );
  }

  setUp(() {
    fakeStorage = FakeLocalStorageService();
    repository = MealRepository(fakeStorage);
  });

  group('MealRepository', () {
    // ─── saveMeal ─────────────────────────────────────────────────────────────

    group('saveMeal', () {
      test('salva refeição usando o id como chave no box correto', () async {
        final meal = makeMeal();
        await repository.saveMeal(meal);

        final raw = fakeStorage.get(AppConstants.mealsBox, meal.id);
        expect(raw, isNotNull);
        expect(raw!['id'], meal.id);
        expect(raw['name'], meal.name);
        expect(raw['calories'], meal.calories);
      });

      test('sobrescreve refeição com mesmo id', () async {
        final original = makeMeal(name: 'Original', calories: 300);
        final updated = makeMeal(name: 'Atualizado', calories: 600);

        await repository.saveMeal(original);
        await repository.saveMeal(updated);

        final raw = fakeStorage.get(AppConstants.mealsBox, 'meal-1');
        expect(raw!['name'], 'Atualizado');
        expect(raw['calories'], 600);
      });

      test('salva múltiplas refeições independentemente', () async {
        await repository.saveMeal(makeMeal(id: 'm1', name: 'Café'));
        await repository.saveMeal(makeMeal(id: 'm2', name: 'Almoço'));
        await repository.saveMeal(makeMeal(id: 'm3', name: 'Jantar'));

        expect(fakeStorage.get(AppConstants.mealsBox, 'm1'), isNotNull);
        expect(fakeStorage.get(AppConstants.mealsBox, 'm2'), isNotNull);
        expect(fakeStorage.get(AppConstants.mealsBox, 'm3'), isNotNull);
      });
    });

    // ─── getMeals ─────────────────────────────────────────────────────────────

    group('getMeals', () {
      test('retorna lista vazia quando não há refeições', () {
        expect(repository.getMeals(), isEmpty);
      });

      test('retorna refeição salva', () async {
        final meal = makeMeal();
        await repository.saveMeal(meal);

        final meals = repository.getMeals();
        expect(meals.length, 1);
        expect(meals.first.id, meal.id);
        expect(meals.first.name, meal.name);
      });

      test('retorna todas as refeições salvas', () async {
        for (var i = 1; i <= 5; i++) {
          await repository.saveMeal(makeMeal(id: 'm$i', name: 'Refeição $i'));
        }
        expect(repository.getMeals().length, 5);
      });

      test('refeições retornadas são instâncias válidas de Meal', () async {
        await repository.saveMeal(makeMeal());
        final meals = repository.getMeals();
        expect(meals.first, isA<Meal>());
      });

      test('getMeals reconstrói corretamente via fromMap', () async {
        final meal = makeMeal(
          id: 'abc',
          name: 'Lanche',
          calories: 250,
          dateTime: DateTime(2024, 7, 20, 15, 30),
        );
        await repository.saveMeal(meal);

        final loaded = repository.getMeals().first;
        expect(loaded.id, meal.id);
        expect(loaded.name, meal.name);
        expect(loaded.calories, meal.calories);
      });
    });

    // ─── deleteMeal ───────────────────────────────────────────────────────────

    group('deleteMeal', () {
      test('remove refeição pelo id', () async {
        final meal = makeMeal();
        await repository.saveMeal(meal);
        expect(repository.getMeals().length, 1);

        await repository.deleteMeal(meal.id);
        expect(repository.getMeals(), isEmpty);
      });

      test('remove apenas a refeição especificada', () async {
        await repository.saveMeal(makeMeal(id: 'a'));
        await repository.saveMeal(makeMeal(id: 'b'));
        await repository.saveMeal(makeMeal(id: 'c'));

        await repository.deleteMeal('b');

        final remaining = repository.getMeals().map((m) => m.id).toList();
        expect(remaining, containsAll(['a', 'c']));
        expect(remaining, isNot(contains('b')));
      });

      test('não lança exceção ao deletar id inexistente', () async {
        expect(
          () => repository.deleteMeal('inexistente'),
          returnsNormally,
        );
      });
    });
  });
}
