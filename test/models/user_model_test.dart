import 'package:flutter_test/flutter_test.dart';
import 'package:fasting_tracker_app/models/user_model.dart';

void main() {
  group('UserModel', () {
    const user = UserModel(
      id: 'user-1',
      email: 'test@example.com',
      isLoggedIn: true,
    );

    // ─── Construção ──────────────────────────────────────────────────────────

    group('construção', () {
      test('cria instância com todos os campos obrigatórios', () {
        expect(user.id, 'user-1');
        expect(user.email, 'test@example.com');
        expect(user.isLoggedIn, isTrue);
      });
    });

    // ─── Serialização ─────────────────────────────────────────────────────────

    group('toMap / fromMap', () {
      test('toMap retorna mapa com todos os campos', () {
        final map = user.toMap();
        expect(map['id'], 'user-1');
        expect(map['email'], 'test@example.com');
        expect(map['isLoggedIn'], true);
      });

      test('fromMap reconstrói objeto idêntico', () {
        final restored = UserModel.fromMap(user.toMap());
        expect(restored, equals(user));
      });

      test('round-trip toMap -> fromMap preserva todos os campos', () {
        const original = UserModel(
          id: 'abc',
          email: 'outro@email.com',
          isLoggedIn: false,
        );
        final restored = UserModel.fromMap(original.toMap());
        expect(restored.id, original.id);
        expect(restored.email, original.email);
        expect(restored.isLoggedIn, original.isLoggedIn);
      });

      test('fromMap com campos ausentes usa valores padrão', () {
        final u = UserModel.fromMap({});
        expect(u.id, '');
        expect(u.email, '');
        expect(u.isLoggedIn, false);
      });

      test('fromMap com isLoggedIn ausente retorna false', () {
        final u = UserModel.fromMap({'id': '1', 'email': 'a@b.com'});
        expect(u.isLoggedIn, false);
      });
    });

    // ─── copyWith ─────────────────────────────────────────────────────────────

    group('copyWith', () {
      test('sem argumentos retorna cópia idêntica', () {
        expect(user.copyWith(), equals(user));
      });

      test('atualiza apenas o email', () {
        final updated = user.copyWith(email: 'novo@email.com');
        expect(updated.email, 'novo@email.com');
        expect(updated.id, user.id);
        expect(updated.isLoggedIn, user.isLoggedIn);
      });

      test('atualiza isLoggedIn para false', () {
        final updated = user.copyWith(isLoggedIn: false);
        expect(updated.isLoggedIn, false);
        expect(updated.id, user.id);
      });

      test('atualiza id mantendo outros campos', () {
        final updated = user.copyWith(id: 'novo-id');
        expect(updated.id, 'novo-id');
        expect(updated.email, user.email);
      });
    });

    // ─── Igualdade ────────────────────────────────────────────────────────────

    group('igualdade e hashCode', () {
      test('dois usuários com mesmos campos são iguais', () {
        const u1 = UserModel(id: 'x', email: 'a@b.com', isLoggedIn: false);
        const u2 = UserModel(id: 'x', email: 'a@b.com', isLoggedIn: false);
        expect(u1, equals(u2));
        expect(u1.hashCode, equals(u2.hashCode));
      });

      test('usuários com emails diferentes não são iguais', () {
        const u1 = UserModel(id: 'x', email: 'a@b.com', isLoggedIn: false);
        const u2 = UserModel(id: 'x', email: 'c@d.com', isLoggedIn: false);
        expect(u1, isNot(equals(u2)));
      });

      test('usuários com ids diferentes não são iguais', () {
        const u1 = UserModel(id: '1', email: 'a@b.com', isLoggedIn: true);
        const u2 = UserModel(id: '2', email: 'a@b.com', isLoggedIn: true);
        expect(u1, isNot(equals(u2)));
      });
    });

    // ─── toString ─────────────────────────────────────────────────────────────

    test('toString contém id, email e isLoggedIn', () {
      final str = user.toString();
      expect(str, contains('user-1'));
      expect(str, contains('test@example.com'));
      expect(str, contains('true'));
    });
  });
}
