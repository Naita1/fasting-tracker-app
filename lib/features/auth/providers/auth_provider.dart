import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_model.dart';
import '../../../repositories/auth_repository.dart';
import '../../../services/local_storage_service.dart';

final localStorageServiceProvider = Provider((ref) => LocalStorageService());

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(ref.watch(localStorageServiceProvider));
});

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<UserModel?> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(null) {
    loadUser();
  }

  void loadUser() {
    try {
      state = _repository.getUser();
    } catch (e) {
      state = null;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      if (email.isEmpty || password.length < 6) {
        throw Exception('E-mail inválido ou senha com menos de 6 caracteres.');
      }
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        isLoggedIn: true,
      );
      await _repository.saveUser(user);
      state = user;
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _repository.clearUser();
      state = null;
    } catch (e) {
      rethrow;
    }
  }
}