import 'package:flutter_test/flutter_test.dart';
import 'package:fasting_tracker_app/models/fasting_session.dart';
import 'package:fasting_tracker_app/models/fasting_protocol.dart';

void main() {
  const protocol = FastingProtocol(
    id: '16-8',
    name: '16:8',
    fastingHours: 16,
    eatingHours: 8,
  );

  FastingSession makeSession({
    String id = '1',
    DateTime? startedAt,
    DateTime? plannedEndAt,
    DateTime? actualEndAt,
    String status = 'active',
    DateTime? pausedAt,
    Duration accumulatedPausedDuration = Duration.zero,
  }) {
    final now = DateTime.now();
    return FastingSession(
      id: id,
      startedAt: startedAt ?? now.subtract(const Duration(hours: 4)),
      plannedEndAt: plannedEndAt ?? now.add(const Duration(hours: 12)),
      actualEndAt: actualEndAt,
      status: status,
      protocol: protocol,
      pausedAt: pausedAt,
      accumulatedPausedDuration: accumulatedPausedDuration,
    );
  }

  group('FastingSession', () {
    // ─── Getters booleanos ────────────────────────────────────────────────────

    group('isActive / isPaused', () {
      test('isActive é true quando status = active', () {
        final s = makeSession(status: 'active');
        expect(s.isActive, isTrue);
        expect(s.isPaused, isFalse);
      });

      test('isPaused é true quando status = paused', () {
        final s = makeSession(status: 'paused');
        expect(s.isPaused, isTrue);
        expect(s.isActive, isFalse);
      });

      test('nem isActive nem isPaused para status = completed', () {
        final s = makeSession(status: 'completed');
        expect(s.isActive, isFalse);
        expect(s.isPaused, isFalse);
      });
    });

    // ─── elapsedTime ─────────────────────────────────────────────────────────

    group('elapsedTime', () {
      test('retorna tempo decorrido correto para sessão ativa', () {
        final now = DateTime.now();
        final s = makeSession(
          startedAt: now.subtract(const Duration(hours: 4)),
          plannedEndAt: now.add(const Duration(hours: 12)),
        );
        expect(s.elapsedTime.inHours, equals(4));
      });

      test('desconta pausa acumulada do tempo decorrido', () {
        final now = DateTime.now();
        final s = makeSession(
          startedAt: now.subtract(const Duration(hours: 6)),
          plannedEndAt: now.add(const Duration(hours: 10)),
          accumulatedPausedDuration: const Duration(hours: 2),
        );
        // 6h corridas - 2h pausadas = 4h efetivas
        expect(s.elapsedTime.inHours, equals(4));
      });

      test('usa pausedAt como referência quando sessão está pausada', () {
        final now = DateTime.now();
        final pausedMoment = now.subtract(const Duration(hours: 1));
        final s = makeSession(
          startedAt: now.subtract(const Duration(hours: 5)),
          plannedEndAt: now.add(const Duration(hours: 11)),
          status: 'paused',
          pausedAt: pausedMoment,
        );
        // Referência é pausedAt (now - 1h), início é now - 5h => 4h decorridas
        expect(s.elapsedTime.inHours, equals(4));
      });

      test('nunca retorna valor negativo', () {
        final now = DateTime.now();
        // accumulatedPause maior que o tempo corrido
        final s = makeSession(
          startedAt: now.subtract(const Duration(hours: 1)),
          plannedEndAt: now.add(const Duration(hours: 15)),
          accumulatedPausedDuration: const Duration(hours: 5),
        );
        expect(s.elapsedTime, equals(Duration.zero));
      });
    });

    // ─── remainingTime ────────────────────────────────────────────────────────

    group('remainingTime', () {
      test('retorna tempo restante correto para sessão ativa', () {
        final now = DateTime.now();
        final s = makeSession(
          startedAt: now.subtract(const Duration(hours: 4)),
          plannedEndAt: now.add(const Duration(hours: 12)),
        );
        expect(s.remainingTime.inMinutes, closeTo(12 * 60, 2));
      });

      test('retorna Duration.zero quando status é completed', () {
        final s = makeSession(status: 'completed');
        expect(s.remainingTime, equals(Duration.zero));
      });

      test('retorna Duration.zero quando status é cancelled', () {
        final s = makeSession(status: 'cancelled');
        expect(s.remainingTime, equals(Duration.zero));
      });

      test('retorna Duration.zero quando tempo esgotado (clamp)', () {
        final now = DateTime.now();
        final s = makeSession(
          startedAt: now.subtract(const Duration(hours: 18)),
          plannedEndAt: now.subtract(const Duration(hours: 2)),
          status: 'active',
        );
        expect(s.remainingTime, equals(Duration.zero));
      });
    });

    // ─── progressPercentage ──────────────────────────────────────────────────

    group('progressPercentage', () {
      test('retorna 0.5 com 50% de progresso', () {
        final now = DateTime.now();
        final s = makeSession(
          startedAt: now.subtract(const Duration(hours: 8)),
          plannedEndAt: now.add(const Duration(hours: 8)),
        );
        expect(s.progressPercentage, closeTo(0.5, 0.01));
      });

      test('clamp em 1.0 quando tempo ultrapassado', () {
        final now = DateTime.now();
        final s = makeSession(
          startedAt: now.subtract(const Duration(hours: 20)),
          plannedEndAt: now.subtract(const Duration(hours: 4)),
          status: 'active',
        );
        expect(s.progressPercentage, equals(1.0));
      });

      test('retorna 0.0 para totalDuration <= 0', () {
        final now = DateTime.now();
        final s = FastingSession(
          id: '0',
          startedAt: now,
          plannedEndAt: now, // duração zero
          status: 'active',
          protocol: protocol,
        );
        expect(s.progressPercentage, equals(0.0));
      });
    });

    // ─── Serialização ─────────────────────────────────────────────────────────

    group('toMap / fromMap', () {
      test('toMap serializa todos os campos', () {
        final now = DateTime(2024, 1, 15, 8, 0);
        final s = FastingSession(
          id: 'abc',
          startedAt: now,
          plannedEndAt: now.add(const Duration(hours: 16)),
          actualEndAt: now.add(const Duration(hours: 16)),
          status: 'completed',
          protocol: protocol,
          accumulatedPausedDuration: const Duration(seconds: 3600),
        );
        final map = s.toMap();

        expect(map['id'], 'abc');
        expect(map['status'], 'completed');
        expect(map['accumulatedPausedSeconds'], 3600);
        expect(map['actualEndAt'], isNotNull);
      });

      test('round-trip toMap -> fromMap preserva todos os campos', () {
        final now = DateTime(2024, 3, 10, 12, 0, 0);
        final original = FastingSession(
          id: 'xyz',
          startedAt: now,
          plannedEndAt: now.add(const Duration(hours: 16)),
          actualEndAt: now.add(const Duration(hours: 16)),
          status: 'completed',
          protocol: protocol,
          accumulatedPausedDuration: const Duration(seconds: 1800),
        );
        final restored = FastingSession.fromMap(original.toMap());

        expect(restored.id, original.id);
        expect(restored.status, original.status);
        expect(restored.protocol.id, original.protocol.id);
        expect(
          restored.startedAt.toIso8601String(),
          original.startedAt.toIso8601String(),
        );
        expect(
          restored.accumulatedPausedDuration,
          original.accumulatedPausedDuration,
        );
      });

      test('fromMap com campos ausentes usa valores padrão', () {
        final s = FastingSession.fromMap({});
        expect(s.id, '');
        expect(s.status, 'active');
        expect(s.pausedAt, isNull);
        expect(s.actualEndAt, isNull);
        expect(s.accumulatedPausedDuration, Duration.zero);
      });

      test('fromMap preserva pausedAt quando está presente', () {
        final now = DateTime(2024, 5, 1, 10, 0);
        final s = FastingSession(
          id: '1',
          startedAt: now,
          plannedEndAt: now.add(const Duration(hours: 16)),
          status: 'paused',
          protocol: protocol,
          pausedAt: now.add(const Duration(hours: 4)),
        );
        final restored = FastingSession.fromMap(s.toMap());
        expect(restored.pausedAt, isNotNull);
      });
    });

    // ─── copyWith ─────────────────────────────────────────────────────────────

    group('copyWith', () {
      test('sem argumentos retorna cópia idêntica', () {
        final s = makeSession();
        final copy = s.copyWith();
        expect(copy, equals(s));
      });

      test('atualiza status mantendo outros campos', () {
        final s = makeSession(status: 'active');
        final paused = s.copyWith(status: 'paused');
        expect(paused.status, 'paused');
        expect(paused.id, s.id);
        expect(paused.startedAt, s.startedAt);
      });

      test('limpa pausedAt via função retornando null', () {
        final s = makeSession(
          status: 'paused',
          pausedAt: DateTime.now(),
        );
        final resumed = s.copyWith(pausedAt: () => null);
        expect(resumed.pausedAt, isNull);
      });

      test('seta novo pausedAt via função', () {
        final s = makeSession(status: 'active');
        final now = DateTime.now();
        final paused = s.copyWith(pausedAt: () => now);
        expect(paused.pausedAt, equals(now));
      });
    });

    // ─── Igualdade ────────────────────────────────────────────────────────────

    group('igualdade e hashCode', () {
      test('sessões com mesmos campos são iguais', () {
        final now = DateTime(2024, 1, 1);
        final s1 = FastingSession(
          id: '1',
          startedAt: now,
          plannedEndAt: now.add(const Duration(hours: 16)),
          status: 'active',
          protocol: protocol,
        );
        final s2 = FastingSession(
          id: '1',
          startedAt: now,
          plannedEndAt: now.add(const Duration(hours: 16)),
          status: 'active',
          protocol: protocol,
        );
        expect(s1, equals(s2));
        expect(s1.hashCode, equals(s2.hashCode));
      });

      test('sessões com ids diferentes não são iguais', () {
        final now = DateTime.now();
        final s1 = makeSession(id: 'a', startedAt: now);
        final s2 = makeSession(id: 'b', startedAt: now);
        expect(s1, isNot(equals(s2)));
      });
    });

    // ─── toString ─────────────────────────────────────────────────────────────

    test('toString contém id, status e nome do protocolo', () {
      final s = makeSession(id: 'sess-1', status: 'active');
      final str = s.toString();
      expect(str, contains('sess-1'));
      expect(str, contains('active'));
      expect(str, contains('16:8'));
    });
  });
}
