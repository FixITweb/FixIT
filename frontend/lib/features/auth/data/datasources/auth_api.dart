import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';

class AuthApi {
  final ApiClient client;

  AuthApi(this.client);

  Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await client.post(Endpoints.login, data: {
      "username": username,
      "password": password
    });
    return res.data;
  }

  Future<Map<String, dynamic>> register(String username, String password, String role) async {
    final res = await client.post(Endpoints.register, data: {
      "username": username,
      "password": password,
      "role": role
    });
    return res.data;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final res = await client.post(Endpoints.forgotPassword, data: {
      "email": email
    });
    return res.data;
  }
}