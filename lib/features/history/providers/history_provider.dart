import 'package:flutter_riverpod/flutter_riverpod.dart';

class FastingSession {
  final String status; 
  final Duration elapsedTime;
  final Duration duration;
  final DateTime startedAt;
  final dynamic protocol;

  FastingSession({
    required this.status,
    required this.elapsedTime,
    required this.duration,
    required this.startedAt,
    this.protocol,
  });
}

class HistoryState {
  final List<FastingSession> sessions;
  final bool isLoading;
  final String? errorMessage;

  const HistoryState({
    this.sessions = const [],
    this.isLoading = false,
    this.errorMessage,
  });
}

// Gerenciador do Estado
class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier() : super(const HistoryState());

  void addSession(FastingSession session) {
    state = HistoryState(
      sessions: [...state.sessions, session],
      isLoading: false,
    );
  }
}


final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier();
});