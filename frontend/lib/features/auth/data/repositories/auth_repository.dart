import '../datasources/auth_api.dart';
import '../models/auth_model.dart';

class AuthRepository {
  final AuthApi api;

  AuthRepository(this.api);

  Future<AuthModel> login(String email, String password) async {
    final data = await api.login(email, password);
    return AuthModel.fromJson(data);
  }

  Future<AuthModel> register(String name, String email, String password, String role) async {
    final data = await api.register(name, email, password, role);
    return AuthModel.fromJson(data);
  }

  Future<String> forgotPassword(String email) async {
    final data = await api.forgotPassword(email);
    return data['message'] ?? 'Reset link sent successfully';
  }
}