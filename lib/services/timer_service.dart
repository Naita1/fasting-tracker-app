class TimerService {
  Stream<int> get ticker => Stream.periodic(const Duration(seconds: 1), (i) => i);
}