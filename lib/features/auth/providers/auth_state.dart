import '../../../models/user_model.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException(super.message);
}

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState();

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? Function()? errorMessage, 
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}