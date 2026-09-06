import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/fasting_session.dart';
import '../../fasting/providers/fasting_provider.dart';

class HistoryState {
  final List<FastingSession> sessions;
  final bool isLoading;
  final String? errorMessage;

  const HistoryState({
    this.sessions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  HistoryState copyWith({
    List<FastingSession>? sessions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HistoryState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final Ref _ref;

  HistoryNotifier(this._ref) : super(const HistoryState()) {
    loadHistory();
  }

  void loadHistory() {
    state = state.copyWith(isLoading: true);
    try {
      final repository = _ref.read(fastingRepositoryProvider);
      final sessions = repository.getHistory();
      sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      state = HistoryState(sessions: sessions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(ref);
});