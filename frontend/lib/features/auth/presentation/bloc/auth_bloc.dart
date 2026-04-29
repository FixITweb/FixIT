import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../data/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;

  AuthBloc(this.repo) : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        // Login to get JWT tokens
        final authModel = await repo.login(event.username, event.password);
        
        // Fetch user profile to get the role
        final profile = await repo.getProfile();
        final role = profile['role'] ?? 'customer';
        
        emit(AuthSuccess(authModel.accessToken, role));
      } catch (e) {
        emit(AuthError('Login failed: ${e.toString()}'));
      }
    });

    on<RegisterEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        // Register and automatically login to get JWT tokens
        // final authModel = await repo.register(event.name, event.password, event.role);

        final authModel = await repo.register(
              event.username,
              event.password,
              event.role,
              event.phone,
            );
        
        // User is now registered AND logged in with JWT tokens
        // Role is already known from registration
        emit(AuthSuccess(authModel.accessToken, event.role));
      } catch (e) {
        emit(AuthError('Registration failed: ${e.toString()}'));
      }
    });

    on<ForgotPasswordEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final message = await repo.forgotPassword(event.email);
        emit(AuthPasswordResetSent(message));
      } catch (e) {
        emit(AuthError('Password reset failed: ${e.toString()}'));
      }
    });

    on<LogoutEvent>((event, emit) async {
      emit(AuthInitial());
    });
  }
}