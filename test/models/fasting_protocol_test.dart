import 'package:flutter_test/flutter_test.dart';
import 'package:fasting_tracker_app/models/fasting_protocol.dart';

void main() {
  group('FastingProtocol', () {
    const protocol = FastingProtocol(
      id: '16-8',
      name: '16:8',
      fastingHours: 16,
      eatingHours: 8,
      description: 'Protocolo intermediário',
    );

    // ─── Construção ──────────────────────────────────────────────────────────

    group('construção', () {
      test('cria instância com todos os campos obrigatórios', () {
        const p = FastingProtocol(
          id: 'test',
          name: 'Test',
          fastingHours: 12,
          eatingHours: 12,
        );
        expect(p.id, 'test');
        expect(p.name, 'Test');
        expect(p.fastingHours, 12);
        expect(p.eatingHours, 12);
        expect(p.isCustom, false);
        expect(p.description, isNull);
      });

      test('cria instância customizada com isCustom = true', () {
        const p = FastingProtocol(
          id: 'custom',
          name: 'Meu Protocolo',
          fastingHours: 20,
          eatingHours: 4,
          isCustom: true,
          description: 'Protocolo personalizado',
        );
        expect(p.isCustom, true);
        expect(p.description, 'Protocolo personalizado');
      });
    });

    // ─── Serialização ─────────────────────────────────────────────────────────

    group('toMap / fromMap', () {
      test('toMap retorna mapa com todos os campos corretos', () {
        final map = protocol.toMap();
        expect(map['id'], '16-8');
        expect(map['name'], '16:8');
        expect(map['fastingHours'], 16);
        expect(map['eatingHours'], 8);
        expect(map['isCustom'], false);
        expect(map['description'], 'Protocolo intermediário');
      });

      test('fromMap reconstrói objeto idêntico ao original', () {
        final restored = FastingProtocol.fromMap(protocol.toMap());
        expect(restored, equals(protocol));
      });

      test('fromMap usa valores padrão quando campos estão ausentes', () {
        final p = FastingProtocol.fromMap({});
        expect(p.id, '');
        expect(p.name, '');
        expect(p.fastingHours, 16);
        expect(p.eatingHours, 8); // 24 - 16
        expect(p.isCustom, false);
        expect(p.description, isNull);
      });

      test('fromMap aceita fastingHours como double (num)', () {
        final p = FastingProtocol.fromMap({
          'id': 'x',
          'name': 'X',
          'fastingHours': 18.0,
          'eatingHours': 6.0,
        });
        expect(p.fastingHours, 18);
        expect(p.eatingHours, 6);
      });

      test('round-trip toMap -> fromMap preserva todos os campos', () {
        const original = FastingProtocol(
          id: 'custom-1',
          name: 'Custom',
          fastingHours: 20,
          eatingHours: 4,
          isCustom: true,
          description: 'Avançado',
        );
        final restored = FastingProtocol.fromMap(original.toMap());
        expect(restored, equals(original));
      });
    });

    // ─── copyWith ─────────────────────────────────────────────────────────────

    group('copyWith', () {
      test('sem argumentos retorna cópia idêntica', () {
        final copy = protocol.copyWith();
        expect(copy, equals(protocol));
      });

      test('atualiza apenas o campo informado', () {
        final copy = protocol.copyWith(fastingHours: 18);
        expect(copy.fastingHours, 18);
        expect(copy.id, protocol.id);
        expect(copy.name, protocol.name);
        expect(copy.eatingHours, protocol.eatingHours);
      });

      test('pode atualizar description para valor não nulo', () {
        final copy = protocol.copyWith(description: 'Nova descrição');
        expect(copy.description, 'Nova descrição');
      });
    });

    // ─── Igualdade ────────────────────────────────────────────────────────────

    group('igualdade e hashCode', () {
      test('dois protocolos com mesmos campos são iguais', () {
        const p1 = FastingProtocol(
          id: '16-8', name: '16:8', fastingHours: 16, eatingHours: 8,
        );
        const p2 = FastingProtocol(
          id: '16-8', name: '16:8', fastingHours: 16, eatingHours: 8,
        );
        expect(p1, equals(p2));
        expect(p1.hashCode, equals(p2.hashCode));
      });

      test('protocolos com ids diferentes não são iguais', () {
        const p1 = FastingProtocol(
          id: '16-8', name: '16:8', fastingHours: 16, eatingHours: 8,
        );
        const p2 = FastingProtocol(
          id: '18-6', name: '16:8', fastingHours: 16, eatingHours: 8,
        );
        expect(p1, isNot(equals(p2)));
      });

      test('objeto não é igual a si mesmo via referência diferente', () {
        final p = protocol.copyWith();
        expect(identical(protocol, p), isFalse);
        expect(protocol, equals(p));
      });
    });

    // ─── toString ─────────────────────────────────────────────────────────────

    test('toString retorna representação legível', () {
      final str = protocol.toString();
      expect(str, contains('16-8'));
      expect(str, contains('16:8'));
      expect(str, contains('16'));
    });
  });
}
