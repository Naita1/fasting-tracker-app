import 'package:flutter_test/flutter_test.dart';
import 'package:fasting_tracker_app/models/meal.dart';

void main() {
  final fixedDate = DateTime(2024, 6, 15, 13, 30);

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
      dateTime: dateTime ?? fixedDate,
    );
  }

  group('Meal', () {
    // ─── Construção ──────────────────────────────────────────────────────────

    group('construção', () {
      test('cria instância com todos os campos', () {
        final m = makeMeal();
        expect(m.id, 'meal-1');
        expect(m.name, 'Almoço');
        expect(m.calories, 500);
        expect(m.dateTime, fixedDate);
      });
    });

    // ─── Serialização ─────────────────────────────────────────────────────────

    group('toMap / fromMap', () {
      test('toMap retorna mapa com todos os campos', () {
        final m = makeMeal();
        final map = m.toMap();
        expect(map['id'], 'meal-1');
        expect(map['name'], 'Almoço');
        expect(map['calories'], 500);
        expect(map['dateTime'], fixedDate.toIso8601String());
      });

      test('fromMap reconstrói objeto idêntico', () {
        final m = makeMeal();
        final restored = Meal.fromMap(m.toMap());
        expect(restored, equals(m));
      });

      test('round-trip toMap -> fromMap preserva todos os campos', () {
        final m = makeMeal(
          id: 'abc',
          name: 'Jantar',
          calories: 750,
          dateTime: DateTime(2024, 12, 31, 20, 0),
        );
        final restored = Meal.fromMap(m.toMap());
        expect(restored.id, m.id);
        expect(restored.name, m.name);
        expect(restored.calories, m.calories);
        expect(restored.dateTime.toIso8601String(), m.dateTime.toIso8601String());
      });

      test('fromMap com campos ausentes usa valores padrão', () {
        final m = Meal.fromMap({});
        expect(m.id, '');
        expect(m.name, '');
        expect(m.calories, 0);
      });

      test('fromMap com dateTime ausente não lança exceção', () {
        expect(
          () => Meal.fromMap({'id': '1', 'name': 'x', 'calories': 100}),
          returnsNormally,
        );
      });
    });

    // ─── copyWith ─────────────────────────────────────────────────────────────

    group('copyWith', () {
      test('sem argumentos retorna cópia idêntica', () {
        final m = makeMeal();
        expect(m.copyWith(), equals(m));
      });

      test('atualiza apenas o nome', () {
        final m = makeMeal();
        final updated = m.copyWith(name: 'Lanche');
        expect(updated.name, 'Lanche');
        expect(updated.id, m.id);
        expect(updated.calories, m.calories);
      });

      test('atualiza apenas as calorias', () {
        final m = makeMeal();
        final updated = m.copyWith(calories: 300);
        expect(updated.calories, 300);
        expect(updated.name, m.name);
      });

      test('atualiza data e hora', () {
        final m = makeMeal();
        final newDate = DateTime(2025, 1, 1, 8, 0);
        final updated = m.copyWith(dateTime: newDate);
        expect(updated.dateTime, newDate);
      });
    });

    // ─── Igualdade ────────────────────────────────────────────────────────────

    group('igualdade e hashCode', () {
      test('duas refeições com mesmos campos são iguais', () {
        final m1 = makeMeal();
        final m2 = makeMeal();
        expect(m1, equals(m2));
        expect(m1.hashCode, equals(m2.hashCode));
      });

      test('refeições com nomes diferentes não são iguais', () {
        final m1 = makeMeal(name: 'Café da manhã');
        final m2 = makeMeal(name: 'Jantar');
        expect(m1, isNot(equals(m2)));
      });

      test('refeições com ids diferentes não são iguais', () {
        final m1 = makeMeal(id: 'a');
        final m2 = makeMeal(id: 'b');
        expect(m1, isNot(equals(m2)));
      });

      test('refeições com calorias diferentes não são iguais', () {
        final m1 = makeMeal(calories: 100);
        final m2 = makeMeal(calories: 200);
        expect(m1, isNot(equals(m2)));
      });
    });
  });
}
