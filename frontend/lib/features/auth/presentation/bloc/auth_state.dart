abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String token;
  final String role;
  AuthSuccess(this.token, this.role);
}

class AuthRegistered extends AuthState {
  final String message;
  final String role;
  AuthRegistered(this.message, this.role);
}

class AuthPasswordResetSent extends AuthState {
  final String message;
  AuthPasswordResetSent(this.message);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}