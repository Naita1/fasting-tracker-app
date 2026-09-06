import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fasting_tracker_app/features/meals/providers/meals_provider.dart';
import 'package:fasting_tracker_app/features/meals/repositories/meals_repository.dart';
import 'package:fasting_tracker_app/services/local_storage_service.dart';

// ─── Fake ─────────────────────────────────────────────────────────────────────

class FakeLocalStorageService implements LocalStorageService {
  final Map<String, Map<String, Map<String, dynamic>>> _store = {};

  @override
  Future<void> put(String boxName, String key, Map<String, dynamic> value) async {
    _store[boxName] ??= {};
    _store[boxName]![key] = Map<String, dynamic>.from(value);
  }

  @override
  Map<String, dynamic>? get(String boxName, String key) =>
      _store[boxName]?[key];

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

// ─── Helpers ──────────────────────────────────────────────────────────────────

ProviderContainer makeContainer({FakeLocalStorageService? storage}) {
  final fakeStorage = storage ?? FakeLocalStorageService();
  final fakeRepo = MealRepository(fakeStorage);

  return ProviderContainer(
    overrides: [
      mealRepositoryProvider.overrideWithValue(fakeRepo),
    ],
  );
}

void main() {
  group('MealsNotifier', () {
    // ─── Estado inicial ────────────────────────────────────────────────────────

    test('estado inicial é lista vazia quando não há refeições salvas', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final meals = container.read(mealsProvider);
      expect(meals, isEmpty);
    });

    // ─── addMeal ──────────────────────────────────────────────────────────────

    group('addMeal', () {
      test('adiciona refeição ao estado', () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(mealsProvider.notifier);

        await notifier.addMeal('Almoço', 600);

        final meals = container.read(mealsProvider);
        expect(meals.length, 1);
        expect(meals.first.name, 'Almoço');
        expect(meals.first.calories, 600);
      });

      test('adiciona múltiplas refeições em sequência', () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(mealsProvider.notifier);

        await notifier.addMeal('Café', 200);
        await notifier.addMeal('Almoço', 700);
        await notifier.addMeal('Jantar', 500);

        expect(container.read(mealsProvider).length, 3);
      });

      test('lança exceção para nome vazio', () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(mealsProvider.notifier);

        expect(
          () => notifier.addMeal('', 500),
          throwsA(isA<Exception>()),
        );
      });

      test('lança exceção para nome apenas com espaços', () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(mealsProvider.notifier);

        expect(
          () => notifier.addMeal('   ', 500),
          throwsA(isA<Exception>()),
        );
      });

      test('lança exceção para calorias zero', () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(mealsProvider.notifier);

        expect(
          () => notifier.addMeal('Café', 0),
          throwsA(isA<Exception>()),
        );
      });

      test('lança exceção para calorias negativas', () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(mealsProvider.notifier);

        expect(
          () => notifier.addMeal('Café', -100),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ─── editMeal ─────────────────────────────────────────────────────────────

    group('editMeal', () {
      test('atualiza nome e calorias da refeição correta', () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(mealsProvider.notifier);

        await notifier.addMeal('Café', 200);
        final id = container.read(mealsProvider).first.id;

        await notifier.editMeal(id, 'Lanche', 350);

        final updated = container.read(mealsProvider).first;
        expect(updated.name, 'Lanche');
        expect(updated.calories, 350);
        expect(updated.id, id); // id não muda
      });

      test('não altera outras refeições', () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(mealsProvider.notifier);

        await notifier.addMeal('Café', 200);
        await notifier.addMeal('Almoço', 600);

        final firstId = container.read(mealsProvider).first.id;
        await notifier.editMeal(firstId, 'Café Editado', 250);

        final meals = container.read(mealsProvider);
        expect(meals.length, 2);
        expect(meals.any((m) => m.name == 'Almoço'), isTrue);
      });

      test('lança exceção para nome vazio ao editar', () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(mealsProvider.notifier);

        await notifier.addMeal('Café', 200);
        final id = container.read(mealsProvider).first.id;

        expect(
          () => notifier.editMeal(id, '', 200),
          throwsA(isA<Exception>()),
        );
      });

      test('lança exceção para calorias inválidas ao editar', () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(mealsProvider.notifier);

        await notifier.addMeal('Café', 200);
        final id = container.read(mealsProvider).first.id;

        expect(
          () => notifier.editMeal(id, 'Café', 0),
          throwsA(isA<Exception>()),
        );
      });

      test('lança exceção para id inexistente', () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(mealsProvider.notifier);

        expect(
          () => notifier.editMeal('id-nao-existe', 'Teste', 100),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ─── deleteMeal ───────────────────────────────────────────────────────────

    group('deleteMeal', () {
      test('remove refeição pelo id', () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(mealsProvider.notifier);

        await notifier.addMeal('Café', 200);
        final id = container.read(mealsProvider).first.id;

        await notifier.deleteMeal(id);

        expect(container.read(mealsProvider), isEmpty);
      });

      test('remove apenas a refeição especificada', () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(mealsProvider.notifier);

        await notifier.addMeal('Café', 200);
        await notifier.addMeal('Almoço', 600);

        final firstId = container.read(mealsProvider).first.id;
        await notifier.deleteMeal(firstId);

        final remaining = container.read(mealsProvider);
        expect(remaining.length, 1);
        expect(remaining.first.name, 'Almoço');
      });
    });

    // ─── todayTotalCalories ───────────────────────────────────────────────────

    group('todayTotalCalories', () {
      test('soma apenas calorias das refeições de hoje', () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(mealsProvider.notifier);

        await notifier.addMeal('Café', 200);
        await notifier.addMeal('Almoço', 500);

        expect(notifier.todayTotalCalories, 700);
      });

      test('retorna 0 quando não há refeições', () {
        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(mealsProvider.notifier);

        expect(notifier.todayTotalCalories, 0);
      });
    });
  });
}
