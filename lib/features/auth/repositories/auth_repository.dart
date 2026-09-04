import '../../../core/constants/app_constants.dart';
import '../../../models/user_model.dart';
import '../../../services/local_storage_service.dart';

class AuthRepository {
  final LocalStorageService _storage;

  AuthRepository(this._storage);
  Future<void> saveUser(UserModel user) async {
    await _storage.put(
      AppConstants.userBox,
      AppConstants.currentUserKey,
      user.toMap(),
    );
  }

  UserModel? getUser() {
    final data = _storage.get(
      AppConstants.userBox,
      AppConstants.currentUserKey,
    );
    return data != null ? UserModel.fromMap(data) : null;
  }

  Future<void> clearUser() async {
    await _storage.delete(
      AppConstants.userBox,
      AppConstants.currentUserKey,
    );
  }
}