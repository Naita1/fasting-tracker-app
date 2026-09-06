import 'package:flutter_test/flutter_test.dart';
import 'package:fasting_tracker_app/models/fasting_session.dart';
import 'package:fasting_tracker_app/models/fasting_protocol.dart';

// Este arquivo mantém os testes originais de smoke/integração.
// Os testes completos e organizados estão em:
//   test/models/fasting_session_test.dart
//   test/models/fasting_protocol_test.dart
//   test/providers/fasting_notifier_test.dart

void main() {
  group('FastingSession & Timer Logic — Smoke Tests', () {
    const protocol = FastingProtocol(
      id: '1',
      name: '16:8',
      fastingHours: 16,
      eatingHours: 8,
    );

    test('Deve criar uma instancia valida de FastingSession', () {
      final now = DateTime.now();
      final session = FastingSession(
        id: '1',
        startedAt: now,
        plannedEndAt: now.add(const Duration(hours: 16)),
        status: 'active',
        protocol: protocol,
      );

      expect(session.id, equals('1'));
      expect(session.status, equals('active'));
      expect(session.protocol.name, equals('16:8'));
    });

    test('Deve converter para Map e reconstruir via fromMap', () {
      final now = DateTime.now();
      final session = FastingSession(
        id: '1',
        startedAt: now,
        plannedEndAt: now.add(const Duration(hours: 16)),
        status: 'completed',
        actualEndAt: now.add(const Duration(hours: 16)),
        protocol: protocol,
      );

      final map = session.toMap();
      final restored = FastingSession.fromMap(map);

      expect(restored.id, equals(session.id));
      expect(restored.status, equals(session.status));
      expect(restored.protocol.id, equals(session.protocol.id));
    });

    test('Deve calcular corretamente tempo decorrido e restante do jejum', () {
      final now = DateTime.now();
      final session = FastingSession(
        id: '2',
        startedAt: now.subtract(const Duration(hours: 4)),
        plannedEndAt: now.add(const Duration(hours: 12)),
        status: 'active',
        protocol: protocol,
      );

      expect(session.elapsedTime.inHours, equals(4));
      expect(session.remainingTime.inMinutes, closeTo(12 * 60, 2)); // ~720 min ± 2
    });

    test('Deve travar o progresso em 100% quando o tempo limite for ultrapassado', () {
      final now = DateTime.now();
      final session = FastingSession(
        id: '3',
        startedAt: now.subtract(const Duration(hours: 18)),
        plannedEndAt: now.subtract(const Duration(hours: 2)),
        status: 'active',
        protocol: protocol,
      );

      expect(session.progressPercentage, equals(1.0));
      expect(session.remainingTime, equals(Duration.zero));
    });
  });
}