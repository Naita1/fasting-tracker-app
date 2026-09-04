import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_model.dart';
import '../../../services/local_storage_service.dart';
import '../repositories/auth_repository.dart';
import 'auth_state.dart';

final localStorageServiceProvider = Provider((ref) => LocalStorageService());

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(ref.watch(localStorageServiceProvider));
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    loadUser();
  }

  void loadUser() {
    try {
      final user = _repository.getUser();
      state = state.copyWith(user: user);
    } catch (_) {
      state = state.copyWith(user: null);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);

    try {
      if (email.isEmpty || password.length < 6) {
        throw InvalidCredentialsException(
          'E-mail inválido ou senha com menos de 6 caracteres.',
        );
      }

      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        isLoggedIn: true,
      );

      await _repository.saveUser(user);
      state = AuthState(user: user, isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false, 
        errorMessage: () => e.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false, 
        errorMessage: () => 'Ocorreu um erro inesperado.',
      );
    }
  }

  Future<void> register(
  String email,
  String password,
  String confirmPassword,
) async {
  state = state.copyWith(isLoading: true, errorMessage: () => null);

  try {
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      throw InvalidCredentialsException('Por favor, insira um e-mail válido.');
    }

    if (password.length < 6) {
      throw InvalidCredentialsException('A senha deve ter pelo menos 6 caracteres.');
    }

    if (password != confirmPassword) {
      throw InvalidCredentialsException('As senhas não coincidem.');
    }

    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      isLoggedIn: true,
    );

    await _repository.saveUser(user);
    state = AuthState(user: user, isLoading: false);
  } on AuthException catch (e) {
    state = state.copyWith(isLoading: false, errorMessage: () => e.message);
  } catch (_) {
    state = state.copyWith(
      isLoading: false,
      errorMessage: () => 'Ocorreu um erro inesperado ao criar a conta.',
    );
  }
}

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);

    try {
      await _repository.clearUser();
      state = const AuthState();
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false, 
        errorMessage: () => e.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false, 
        errorMessage: () => 'Ocorreu um erro inesperado.',
      );
    }
  }
}