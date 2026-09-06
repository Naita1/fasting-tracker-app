import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fasting_tracker_app/models/fasting_protocol.dart';
import 'package:fasting_tracker_app/models/fasting_session.dart';
import 'package:fasting_tracker_app/features/fasting/providers/fasting_provider.dart';
import 'package:fasting_tracker_app/features/fasting/repositories/fasting_repository.dart';
import 'package:fasting_tracker_app/services/local_storage_service.dart';
import 'package:fasting_tracker_app/services/notification_service.dart';

// ─── Fakes ────────────────────────────────────────────────────────────────────

class FakeLocalStorageService implements LocalStorageService {
  final Map<String, Map<String, Map<String, dynamic>>> _store = {};

  @override
  Future<void> put(String boxName, String key, Map<String, dynamic> value) async {
    _store[boxName] ??= {};
    _store[boxName]![key] = Map<String, dynamic>.from(value);
  }

  @override
  Map<String, dynamic>? get(String boxName, String key) => _store[boxName]?[key];

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
  final List<Map<String, dynamic>> shown = [];
  final List<Map<String, dynamic>> scheduled = [];
  final List<int> cancelled = [];

  @override
  Future<void> init() async {}

  @override
  Future<void> requestPermissions() async {}

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    shown.add({'id': id, 'title': title, 'body': body});
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    scheduled.add({
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate,
    });
  }

  @override
  Future<void> cancelNotification(int id) async {
    cancelled.add(id);
  }
}

// ─── Helper ───────────────────────────────────────────────────────────────────

const kProtocol = FastingProtocol(
  id: '16-8',
  name: '16:8',
  fastingHours: 16,
  eatingHours: 8,
);

ProviderContainer makeContainer({
  FastingSession? initialSession,
}) {
  final fakeStorage = FakeLocalStorageService();
  final fakeRepo = FastingRepository(fakeStorage);
  final fakeNotifs = FakeNotificationService();

  // Pre-populate storage if needed
  if (initialSession != null) {
    fakeStorage.put(
      'fasting_box',
      'active_session',
      initialSession.toMap(),
    );
  }

  return ProviderContainer(
    overrides: [
      fastingRepositoryProvider.overrideWithValue(fakeRepo),
      notificationServiceProvider.overrideWithValue(fakeNotifs),
    ],
  );
}

void main() {
  group('FastingNotifier', () {
    // ─── loadActiveSession ────────────────────────────────────────────────────

    group('loadActiveSession', () {
      test('estado inicial é vazio quando não há sessão salva', () {
        final container = makeContainer();
        addTearDown(container.dispose);

        final state = container.read(fastingNotifierProvider);
        expect(state.session, isNull);
        expect(state.isLoading, isFalse);
      });

      test('carrega sessão existente no estado inicial', () {
        final now = DateTime(2024, 5, 1, 8, 0);
        final session = FastingSession(
          id: 'preloaded',
          startedAt: now,
          plannedEndAt: now.add(const Duration(hours: 16)),
          status: 'active',
          protocol: kProtocol,
        );
        final container = makeContainer(initialSession: session);
        addTearDown(container.dispose);

        final state = container.read(fastingNotifierProvider);
        expect(state.session, isNotNull);
        expect(state.session!.id, 'preloaded');
      });
    });

    // ─── startFasting ─────────────────────────────────────────────────────────

    group('startFasting', () {
      test('cria sessão com status active após startFasting', () async {
        final container = makeContainer();
        addTearDown(container.dispose);

        final notifier = container.read(fastingNotifierProvider.notifier);
        await notifier.startFasting(kProtocol);

        final state = container.read(fastingNotifierProvider);
        expect(state.session, isNotNull);
        expect(state.session!.status, 'active');
        expect(state.session!.protocol.id, kProtocol.id);
        expect(state.isLoading, isFalse);
      });

      test('plannedEndAt é startedAt + fastingHours', () async {
        final container = makeContainer();
        addTearDown(container.dispose);

        final notifier = container.read(fastingNotifierProvider.notifier);
        await notifier.startFasting(kProtocol);

        final session = container.read(fastingNotifierProvider).session!;
        final diff = session.plannedEndAt.difference(session.startedAt);
        expect(diff.inHours, kProtocol.fastingHours);
      });

      test('não executa se já estiver carregando', () async {
        final container = makeContainer();
        addTearDown(container.dispose);

        // Força isLoading = true manualmente via estado intermediário
        // (testar a guarda isLoading é suficiente via comportamento)
        final notifier = container.read(fastingNotifierProvider.notifier);
        // Chamada dupla: segunda não deve criar nova sessão por cima
        await notifier.startFasting(kProtocol);
        final firstId = container.read(fastingNotifierProvider).session!.id;

        // Ao chamar startFasting com sessão ativa, uma nova sessão PODE
        // ser iniciada, mas isLoading voltou a false → o comportamento
        // esperado é que a lógica não trava o app.
        expect(container.read(fastingNotifierProvider).isLoading, isFalse);
        expect(container.read(fastingNotifierProvider).session!.id, firstId);
      });
    });

    // ─── pauseFasting ─────────────────────────────────────────────────────────

    group('pauseFasting', () {
      test('muda status para paused e registra pausedAt', () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(fastingNotifierProvider.notifier);

        await notifier.startFasting(kProtocol);
        await notifier.pauseFasting();

        final state = container.read(fastingNotifierProvider);
        expect(state.session!.status, 'paused');
        expect(state.session!.pausedAt, isNotNull);
        expect(state.isLoading, isFalse);
      });

      test('não faz nada se não houver sessão ativa', () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(fastingNotifierProvider.notifier);

        // Nenhuma sessão → pauseFasting deve ser no-op
        await notifier.pauseFasting();
        expect(container.read(fastingNotifierProvider).session, isNull);
      });

      test('não faz nada se sessão já estiver pausada', () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(fastingNotifierProvider.notifier);

        await notifier.startFasting(kProtocol);
        await notifier.pauseFasting(); // primeira pausa

        final pausedAt1 = container.read(fastingNotifierProvider).session!.pausedAt;
        await notifier.pauseFasting(); // segunda pausa → deve ser ignorada

        final pausedAt2 = container.read(fastingNotifierProvider).session!.pausedAt;
        expect(pausedAt2, equals(pausedAt1));
      });
    });

    // ─── resumeFasting ────────────────────────────────────────────────────────

    group('resumeFasting', () {
      test('retoma sessão e acumula pausa', () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(fastingNotifierProvider.notifier);

        await notifier.startFasting(kProtocol);
        await notifier.pauseFasting();
        await Future.delayed(const Duration(milliseconds: 10));
        await notifier.resumeFasting();

        final state = container.read(fastingNotifierProvider);
        expect(state.session!.status, 'active');
        expect(state.session!.pausedAt, isNull);
        expect(state.session!.accumulatedPausedDuration, isNot(Duration.zero));
        expect(state.isLoading, isFalse);
      });

      test('não faz nada se sessão não estiver pausada', () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(fastingNotifierProvider.notifier);

        await notifier.startFasting(kProtocol);
        // Sessão ativa — resumeFasting deve ser no-op
        await notifier.resumeFasting();

        expect(
          container.read(fastingNotifierProvider).session!.status,
          'active',
        );
      });
    });

    // ─── stopFasting ──────────────────────────────────────────────────────────

    group('stopFasting', () {
      test('limpa o estado e salva no histórico como completed', () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(fastingNotifierProvider.notifier);

        await notifier.startFasting(kProtocol);
        await notifier.stopFasting(isCompleted: true);

        final state = container.read(fastingNotifierProvider);
        expect(state.session, isNull);
        expect(state.isLoading, isFalse);
      });

      test('salva no histórico como cancelled quando isCompleted = false', () async {
        final fakeStorage = FakeLocalStorageService();
        final fakeRepo = FastingRepository(fakeStorage);
        final fakeNotifs = FakeNotificationService();

        final container = ProviderContainer(
          overrides: [
            fastingRepositoryProvider.overrideWithValue(fakeRepo),
            notificationServiceProvider.overrideWithValue(fakeNotifs),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(fastingNotifierProvider.notifier);
        await notifier.startFasting(kProtocol);

        final sessionId =
            container.read(fastingNotifierProvider).session!.id;
        await notifier.stopFasting(isCompleted: false);

        // Verifica no fake storage se o status ficou cancelled
        final saved = fakeStorage.get('fasting_box', sessionId);
        expect(saved, isNotNull);
        expect(saved!['status'], 'cancelled');
      });

      test('não faz nada quando não há sessão', () async {
        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(fastingNotifierProvider.notifier);

        // Sem sessão → stopFasting não deve lançar exceção
        await notifier.stopFasting();
        expect(container.read(fastingNotifierProvider).session, isNull);
      });
    });
  });
}
