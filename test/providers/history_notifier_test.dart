import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fasting_tracker_app/models/fasting_protocol.dart';
import 'package:fasting_tracker_app/models/fasting_session.dart';
import 'package:fasting_tracker_app/features/history/providers/history_provider.dart';
import 'package:fasting_tracker_app/features/fasting/providers/fasting_provider.dart';
import 'package:fasting_tracker_app/features/fasting/repositories/fasting_repository.dart';
import 'package:fasting_tracker_app/services/local_storage_service.dart';
import 'package:fasting_tracker_app/services/notification_service.dart';
import 'package:fasting_tracker_app/core/constants/app_constants.dart';

// ─── Fakes ────────────────────────────────────────────────────────────────────

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

class FakeNotificationService extends NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {}

  @override
  Future<void> cancelNotification(int id) async {}
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

const kProtocol = FastingProtocol(
  id: '16-8',
  name: '16:8',
  fastingHours: 16,
  eatingHours: 8,
);

/// Cria um container com [FakeLocalStorageService] que já possui
/// [sessions] pré-populadas no box de histórico.
ProviderContainer makeContainer(
  FakeLocalStorageService storage,
) {
  final repo = FastingRepository(storage);
  final notifs = FakeNotificationService();
  return ProviderContainer(
    overrides: [
      fastingRepositoryProvider.overrideWithValue(repo),
      notificationServiceProvider.overrideWithValue(notifs),
    ],
  );
}

FastingSession makeCompletedSession({
  required String id,
  required DateTime startedAt,
}) {
  return FastingSession(
    id: id,
    startedAt: startedAt,
    plannedEndAt: startedAt.add(const Duration(hours: 16)),
    actualEndAt: startedAt.add(const Duration(hours: 16)),
    status: 'completed',
    protocol: kProtocol,
  );
}

void main() {
  group('HistoryNotifier', () {
    // ─── estado inicial vazio ─────────────────────────────────────────────────

    test('retorna lista vazia quando não há histórico', () {
      final storage = FakeLocalStorageService();
      final container = makeContainer(storage);
      addTearDown(container.dispose);

      final state = container.read(historyProvider);
      expect(state.sessions, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    // ─── loadHistory ──────────────────────────────────────────────────────────

    group('loadHistory', () {
      test('carrega sessões do repositório', () async {
        final storage = FakeLocalStorageService();

        // Pré-popula o storage com sessões de histórico
        final session1 = makeCompletedSession(
          id: 'h1',
          startedAt: DateTime(2024, 1, 10),
        );
        final session2 = makeCompletedSession(
          id: 'h2',
          startedAt: DateTime(2024, 1, 11),
        );
        await storage.put(AppConstants.fastingBox, 'h1', session1.toMap());
        await storage.put(AppConstants.fastingBox, 'h2', session2.toMap());

        final container = makeContainer(storage);
        addTearDown(container.dispose);

        final state = container.read(historyProvider);
        expect(state.sessions.length, 2);
        expect(state.isLoading, isFalse);
      });

      test('ordena sessões por data decrescente (mais recente primeiro)', () async {
        final storage = FakeLocalStorageService();

        final older = makeCompletedSession(
          id: 'old',
          startedAt: DateTime(2024, 1, 1),
        );
        final newer = makeCompletedSession(
          id: 'new',
          startedAt: DateTime(2024, 3, 1),
        );

        // Insere na ordem inversa para confirmar que a ordenação acontece
        await storage.put(AppConstants.fastingBox, 'old', older.toMap());
        await storage.put(AppConstants.fastingBox, 'new', newer.toMap());

        final container = makeContainer(storage);
        addTearDown(container.dispose);

        final sessions = container.read(historyProvider).sessions;
        expect(sessions.first.id, 'new');
        expect(sessions.last.id, 'old');
      });

      test('filtra entradas com id = active_session do histórico', () async {
        final storage = FakeLocalStorageService();

        // O filtro usa map['id'] != 'active_session'.
        // Para simular corretamente, a sessão ativa precisa ter field id = 'active_session'.
        final activeMap = FastingSession(
          id: AppConstants.activeSessionKey,
          startedAt: DateTime(2024, 5, 1),
          plannedEndAt: DateTime(2024, 5, 1).add(const Duration(hours: 16)),
          status: 'active',
          protocol: kProtocol,
        ).toMap();

        await storage.put(
          AppConstants.fastingBox,
          AppConstants.activeSessionKey,
          activeMap,
        );

        final completed = makeCompletedSession(
          id: 'h1',
          startedAt: DateTime(2024, 4, 1),
        );
        await storage.put(AppConstants.fastingBox, 'h1', completed.toMap());

        final container = makeContainer(storage);
        addTearDown(container.dispose);

        final sessions = container.read(historyProvider).sessions;
        // Sessão com id = 'active_session' não deve aparecer no histórico
        expect(
          sessions.any((s) => s.id == AppConstants.activeSessionKey),
          isFalse,
        );
        expect(sessions.length, 1);
        expect(sessions.first.id, 'h1');
      });


      test('pode recarregar o histórico via loadHistory()', () async {
        final storage = FakeLocalStorageService();
        final container = makeContainer(storage);
        addTearDown(container.dispose);

        // Inicia sem sessões
        expect(container.read(historyProvider).sessions, isEmpty);

        // Adiciona sessão diretamente no storage e recarrega
        final session = makeCompletedSession(
          id: 'hx',
          startedAt: DateTime(2024, 6, 1),
        );
        await storage.put(AppConstants.fastingBox, 'hx', session.toMap());

        container.read(historyProvider.notifier).loadHistory();

        final sessions = container.read(historyProvider).sessions;
        expect(sessions.length, 1);
        expect(sessions.first.id, 'hx');
      });
    });
  });
}
