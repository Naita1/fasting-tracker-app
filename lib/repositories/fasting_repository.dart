import '../core/constants/app_constants.dart';
import '../models/fasting_session.dart';
import '../services/local_storage_service.dart';

class FastingRepository {
  final LocalStorageService _storage;
  FastingRepository(this._storage);

  Future<void> saveActiveSession(FastingSession session) async {
    await _storage.put(AppConstants.fastingBox, AppConstants.activeSessionKey, session.toMap());
  }

  FastingSession? getActiveSession() {
    final data = _storage.get(AppConstants.fastingBox, AppConstants.activeSessionKey);
    return data != null ? FastingSession.fromMap(data) : null;
  }

  Future<void> clearActiveSession() async {
    await _storage.delete(AppConstants.fastingBox, AppConstants.activeSessionKey);
  }

  Future<void> saveToHistory(FastingSession session) async {
    await _storage.put(AppConstants.fastingBox, session.id, session.toMap());
  }

  List<FastingSession> getHistory() {
    final rawList = _storage.getAll(AppConstants.fastingBox);
    return rawList
        .where((map) => map['id'] != AppConstants.activeSessionKey)
        .map((map) => FastingSession.fromMap(map))
        .toList();
  }
}