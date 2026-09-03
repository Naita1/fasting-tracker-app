import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/fasting_protocol.dart';
import '../../../models/fasting_session.dart';
import '../../../repositories/fasting_repository.dart';
import '../../../services/notification_service.dart';
import '../../../services/timer_service.dart';
import '../../auth/providers/auth_provider.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());
final timerServiceProvider = Provider((ref) => TimerService());

final fastingRepositoryProvider = Provider((ref) {
  return FastingRepository(ref.watch(localStorageServiceProvider));
});


final timerTickerProvider = StreamProvider.autoDispose<int>((ref) {
  return ref.watch(timerServiceProvider).ticker;
});

final fastingProvider = StateNotifierProvider<FastingNotifier, FastingSession?>((ref) {
  return FastingNotifier(
    ref.watch(fastingRepositoryProvider),
    ref.watch(notificationServiceProvider),
  );
});

class FastingNotifier extends StateNotifier<FastingSession?> {
  final FastingRepository _repository;
  final NotificationService _notificationService;

  FastingNotifier(this._repository, this._notificationService) : super(null) {
    loadActiveSession();
  }

  void loadActiveSession() {
    try {
      state = _repository.getActiveSession();
    } catch (e) {
      state = null;
    }
  }

  Future<void> startFasting(FastingProtocol protocol) async {
    try {
      final now = DateTime.now();
      final plannedEnd = now.add(Duration(hours: protocol.fastingHours));

      final session = FastingSession(
        id: now.millisecondsSinceEpoch.toString(),
        startedAt: now,
        plannedEndAt: plannedEnd,
        status: 'active',
        protocol: protocol,
      );

      await _repository.saveActiveSession(session);
      state = session;

      await _notificationService.showNotification(
        id: 1,
        title: 'Jejum Iniciado 🚀',
        body: 'Seu jejum de ${protocol.name} começou. Boa sorte!',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> stopFasting({bool isCompleted = true}) async {
    final current = state;
    if (current == null) return;

    try {
      final updatedSession = FastingSession(
        id: current.id,
        startedAt: current.startedAt,
        plannedEndAt: current.plannedEndAt,
        actualEndAt: DateTime.now(),
        status: isCompleted ? 'completed' : 'cancelled',
        protocol: current.protocol,
      );

      await _repository.saveToHistory(updatedSession);
      await _repository.clearActiveSession();
      state = null;

      await _notificationService.showNotification(
        id: 2,
        title: isCompleted ? 'Jejum Concluído! 🎉' : 'Jejum Encerrado',
        body: isCompleted
            ? 'Parabéns! Você alcançou sua meta de jejum.'
            : 'Sua sessão de jejum foi encerrada.',
      );
    } catch (e) {
      rethrow;
    }
  }
}