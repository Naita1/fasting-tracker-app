import 'package:flutter_test/flutter_test.dart';
import 'package:fasting_tracker_app/models/fasting_session.dart';
import 'package:fasting_tracker_app/models/fasting_protocol.dart';

void main() {
  group('FastingSession Unit Tests', () {
    test('Deve criar uma instancia valida de FastingSession', () {
      final now = DateTime.now();
      const protocol = FastingProtocol(id: '1', name: '16:8', fastingHours: 16, eatingHours: 8);
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
      const protocol = FastingProtocol(id: '1', name: '16:8', fastingHours: 16, eatingHours: 8);
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
  });
}