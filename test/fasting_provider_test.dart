import 'package:flutter_test/flutter_test.dart';
import 'package:fasting_tracker_app/models/fasting_session_model.dart';

void main() {
  group('FastingSessionModel Unit Tests', () {
    test('Deve criar uma instancia valida de FastingSessionModel', () {
      final now = DateTime.now();
      final session = FastingSessionModel(
        id: '1',
        startTime: now,
        targetHours: 16,
        isCompleted: false,
      );

      expect(session.id, equals('1'));
      expect(session.targetHours, equals(16));
      expect(session.isCompleted, equals(false));
    });

    test('Deve converter para Map e reconstruir via fromMap', () {
      final now = DateTime.now();
      final session = FastingSessionModel(
        id: '1',
        startTime: now,
        targetHours: 16,
        isCompleted: true,
      );

      final map = session.toMap();
      final restored = FastingSessionModel.fromMap(map);

      expect(restored.id, equals(session.id));
      expect(restored.targetHours, equals(session.targetHours));
      expect(restored.isCompleted, equals(session.isCompleted));
    });
  });
}