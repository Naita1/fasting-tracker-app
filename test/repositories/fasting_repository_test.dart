import 'package:flutter_test/flutter_test.dart';
import 'package:fasting_tracker_app/models/fasting_session.dart';
import 'package:fasting_tracker_app/models/fasting_protocol.dart';
import 'package:fasting_tracker_app/features/fasting/repositories/fasting_repository.dart';
import 'package:fasting_tracker_app/services/local_storage_service.dart';
import 'package:fasting_tracker_app/core/constants/app_constants.dart';

/// Implementação in-memory de [LocalStorageService] para testes.
/// Não usa Hive — armazena tudo em um Map local.
class FakeLocalStorageService implements LocalStorageService {
  final Map<String, Map<String, Map<String, dynamic>>> _store = {};

  @override
  Future<void> put(
    String boxName,
    String key,
    Map<String, dynamic> value,
  ) async {
    _store[boxName] ??= {};
    _store[boxName]![key] = Map<String, dynamic>.from(value);
  }

  @override
  Map<String, dynamic>? get(String boxName, String key) {
    return _store[boxName]?[key];
  }

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

void main() {
  const protocol = FastingProtocol(
    id: '16-8',
    name: '16:8',
    fastingHours: 16,
    eatingHours: 8,
  );

  late FakeLocalStorageService fakeStorage;
  late FastingRepository repository;

  setUp(() {
    fakeStorage = FakeLocalStorageService();
    repository = FastingRepository(fakeStorage);
  });

  FastingSession makeSession({
    String id = 'sess-1',
    String status = 'active',
    DateTime? startedAt,
  }) {
    final now = startedAt ?? DateTime(2024, 1, 10, 8, 0);
    return FastingSession(
      id: id,
      startedAt: now,
      plannedEndAt: now.add(const Duration(hours: 16)),
      status: status,
      protocol: protocol,
    );
  }

  group('FastingRepository', () {
    // ─── getActiveSession ─────────────────────────────────────────────────────

    group('getActiveSession', () {
      test('retorna null quando não há sessão ativa salva', () {
        expect(repository.getActiveSession(), isNull);
      });

      test('retorna sessão após saveActiveSession', () async {
        final session = makeSession();
        await repository.saveActiveSession(session);

        final loaded = repository.getActiveSession();
        expect(loaded, isNotNull);
        expect(loaded!.id, session.id);
        expect(loaded.status, session.status);
      });

      test('usa a chave activeSessionKey no box fastingBox', () async {
        final session = makeSession();
        await repository.saveActiveSession(session);

        // Verifica diretamente no fake storage
        final raw = fakeStorage.get(
          AppConstants.fastingBox,
          AppConstants.activeSessionKey,
        );
        expect(raw, isNotNull);
        expect(raw!['id'], session.id);
      });
    });

    // ─── saveActiveSession ────────────────────────────────────────────────────

    group('saveActiveSession', () {
      test('salva sessão serializando corretamente', () async {
        final session = makeSession();
        await repository.saveActiveSession(session);

        final stored = fakeStorage.get(
          AppConstants.fastingBox,
          AppConstants.activeSessionKey,
        );
        expect(stored!['status'], 'active');
        expect(stored['id'], 'sess-1');
      });

      test('sobrescreve sessão anterior', () async {
        final first = makeSession(id: 'first');
        final second = makeSession(id: 'second');

        await repository.saveActiveSession(first);
        await repository.saveActiveSession(second);

        final loaded = repository.getActiveSession();
        expect(loaded!.id, 'second');
      });
    });

    // ─── clearActiveSession ───────────────────────────────────────────────────

    group('clearActiveSession', () {
      test('remove sessão ativa do storage', () async {
        final session = makeSession();
        await repository.saveActiveSession(session);
        expect(repository.getActiveSession(), isNotNull);

        await repository.clearActiveSession();
        expect(repository.getActiveSession(), isNull);
      });

      test('não lança exceção quando não há sessão ativa', () async {
        expect(() => repository.clearActiveSession(), returnsNormally);
      });
    });

    // ─── saveToHistory ────────────────────────────────────────────────────────

    group('saveToHistory', () {
      test('salva sessão usando o id como chave', () async {
        final session = makeSession(id: 'hist-1', status: 'completed');
        await repository.saveToHistory(session);

        final raw = fakeStorage.get(AppConstants.fastingBox, 'hist-1');
        expect(raw, isNotNull);
        expect(raw!['status'], 'completed');
      });

      test('salva múltiplas sessões no histórico', () async {
        await repository.saveToHistory(
          makeSession(id: 'h1', status: 'completed'),
        );
        await repository.saveToHistory(
          makeSession(id: 'h2', status: 'cancelled'),
        );

        expect(fakeStorage.get(AppConstants.fastingBox, 'h1'), isNotNull);
        expect(fakeStorage.get(AppConstants.fastingBox, 'h2'), isNotNull);
      });
    });

    // ─── getHistory ───────────────────────────────────────────────────────────

    group('getHistory', () {
      test('retorna lista vazia quando não há sessões', () {
        expect(repository.getHistory(), isEmpty);
      });

      test('filtra entradas com id = active_session do histórico', () async {
        // O filtro do getHistory usa map['id'] != 'active_session'.
        // Para simular como o Hive se comporta, salvamos diretamente um mapa
        // cuja chave no box é 'active_session' E cujo campo 'id' também é 'active_session'.
        await fakeStorage.put(
          AppConstants.fastingBox,
          AppConstants.activeSessionKey,
          makeSession(id: AppConstants.activeSessionKey, status: 'active').toMap(),
        );
        // Salva uma sessão no histórico (com id próprio)
        await repository.saveToHistory(
          makeSession(id: 'h1', status: 'completed'),
        );

        final history = repository.getHistory();
        // Deve conter apenas h1, não active_session
        expect(history.length, 1);
        expect(history.first.id, 'h1');
      });

      test('retorna todas as sessões do histórico corretamente', () async {
        for (var i = 1; i <= 3; i++) {
          await repository.saveToHistory(
            makeSession(id: 'h$i', status: 'completed'),
          );
        }
        final history = repository.getHistory();
        expect(history.length, 3);
      });

      test('sessões do histórico são instâncias válidas de FastingSession', () async {
        await repository.saveToHistory(
          makeSession(id: 'h1', status: 'completed'),
        );
        final history = repository.getHistory();
        expect(history.first, isA<FastingSession>());
        expect(history.first.id, 'h1');
      });
    });
  });
}
