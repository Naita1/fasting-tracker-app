import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/fasting_protocol.dart';
import '../../../models/fasting_session.dart';
import '../../../services/local_storage_service.dart';
import '../../../services/notification_service.dart';
import '../../../services/timer_service.dart';
import '../../history/providers/history_provider.dart';
import '../repositories/fasting_repository.dart';
import 'fasting_state.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());
final timerServiceProvider = Provider((ref) => TimerService());

final fastingRepositoryProvider =
    Provider((ref) => FastingRepository(LocalStorageService()));

final timerTickerProvider = StreamProvider.autoDispose<int>((ref) {
  return ref.watch(timerServiceProvider).ticker;
});

final fastingNotifierProvider =
    StateNotifierProvider<FastingNotifier, FastingState>((ref) {
  return FastingNotifier(
    ref.watch(fastingRepositoryProvider),
    ref.watch(notificationServiceProvider),
    ref,
  );
});

class FastingNotifier extends StateNotifier<FastingState> {
  final FastingRepository _repository;
  final NotificationService _notificationService;
  final Ref _ref;

  static const int _completionNotificationId = 10;

  FastingNotifier(
    this._repository,
    this._notificationService,
    this._ref,
  ) : super(const FastingState()) {
    loadActiveSession();
  }

  void loadActiveSession() {
    try {
      final session = _repository.getActiveSession();
      state = FastingState(session: session);
    } catch (_) {
      state = const FastingState();
    }
  }

  Future<void> startFasting(FastingProtocol protocol) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);

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
      state = FastingState(session: session, isLoading: false);

      await _notificationService.showNotification(
        id: 1,
        title: 'Jejum Iniciado 🚀',
        body: 'Seu jejum de ${protocol.name} começou. Mantenha o foco!',
      );

      await _notificationService.scheduleNotification(
        id: _completionNotificationId,
        title: 'Jejum Concluído! 🎉',
        body: 'Parabéns! Você alcançou sua meta de ${protocol.name}.',
        scheduledDate: plannedEnd,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> stopFasting({bool isCompleted = true}) async {
    final current = state.session;
    if (current == null || state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final updatedSession = current.copyWith(
        actualEndAt: DateTime.now(),
        status: isCompleted ? 'completed' : 'cancelled',
      );

      await _repository.saveToHistory(updatedSession);
      await _repository.clearActiveSession();

      await _notificationService.cancelNotification(_completionNotificationId);

      state = const FastingState();

      _ref.invalidate(historyNotifierProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}