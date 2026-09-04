import '../../../models/fasting_session.dart';

class FastingState {
  final FastingSession? session;
  final bool isLoading;

  const FastingState({
    this.session,
    this.isLoading = false,
  });

  factory FastingState.initial() {
    return const FastingState();
  }

  FastingState copyWith({
    FastingSession? Function()? session,
    bool? isLoading,
  }) {
    return FastingState(
      session: session != null ? session() : this.session,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}