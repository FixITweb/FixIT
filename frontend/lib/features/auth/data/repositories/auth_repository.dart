import '../datasources/auth_api.dart';
import '../models/auth_model.dart';

class AuthRepository {
  final AuthApi api;

  AuthRepository(this.api);

  // ================= LOGIN =================
  Future<AuthModel> login(String username, String password) async {
    try {
      final data = await api.login(username, password);
      return AuthModel.fromJson(data);
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  // ================= REGISTER =================
  Future<String> register(String username, String password, String role) async {
    try {
      final data = await api.register(username, password, role);

      return data['message'] ?? "Registered successfully";
    } catch (e) {
      throw Exception("Register failed: $e");
    }
  }

  // ================= PROFILE =================
  Future<Map<String, dynamic>> getProfile() async {
    try {
      return await api.getProfile();
    } catch (e) {
      throw Exception("Failed to load profile: $e");
    }
  }

  // ================= FORGOT PASSWORD =================
  Future<String> forgotPassword(String email) async {
    try {
      final data = await api.forgotPassword(email);
      return data['message'] ?? 'Reset link sent successfully';
    } catch (e) {
      throw Exception("Forgot password failed: $e");
    }
  }
}