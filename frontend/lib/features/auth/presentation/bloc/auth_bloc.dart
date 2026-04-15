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
        // Mock login - simulate successful login without API call
        await Future.delayed(const Duration(seconds: 1));
        
        // Determine role based on email for demo purposes
        String role = 'customer';
        if (event.email.contains('worker') || event.email.contains('alex')) {
          role = 'worker';
        }
        
        emit(AuthSuccess('mock_token_123', role));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<RegisterEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        // Mock registration - simulate successful registration
        await Future.delayed(const Duration(seconds: 1));
        emit(AuthRegistered('Registration successful!', event.role));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<ForgotPasswordEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        // Mock forgot password
        await Future.delayed(const Duration(seconds: 1));
        emit(AuthPasswordResetSent('Reset link sent to ${event.email}'));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LogoutEvent>((event, emit) async {
      emit(AuthInitial());
    });
  }
}