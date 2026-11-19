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
        final authModel = await repo.login(event.username, event.password);

        var role = authModel.role;
        if (role == null || role.isEmpty) {
          final profile = await repo.getProfile();
          role = profile['role'] is String ? profile['role'] as String : null;
        }
        if (role == null) {
          throw Exception('The server did not return an account role.');
        }
        if (role != 'customer' && role != 'worker') {
          throw Exception('The server did not return a valid account role.');
        }

        emit(AuthSuccess(authModel.accessToken, role));
      } catch (e) {
        emit(AuthError('Login failed: ${e.toString()}'));
      }
    });

    on<RegisterEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final authModel = await repo.register(
          event.username,
          event.password,
          event.role,
          event.phone,
          latitude: event.latitude,
          longitude: event.longitude,
        );

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
