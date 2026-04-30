import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';

class AuthApi {
  final ApiClient client;

  AuthApi(this.client);

  //  LOGIN
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final res = await client.post(
        Endpoints.login,
        data: {
          "username": username,
          "password": password,
        },
        requireAuth: false,
      );

      final data = res.data;

      print("LOGIN RESPONSE: $data");

      final token = data['access'] ?? data['token'];

      if (token == null) {
        throw Exception("Token not found in response");
      }

      // 💾 save token
      await client.saveToken(token);

      return data;
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  // REGISTER
Future<Map<String, dynamic>> register(
  String username,
  String password,
  String role,
  String phone,
    {double? latitude,
    double? longitude,
    }
) async {
    try {
      final res = await client.post(
        Endpoints.register,
        data: {
          "username": username,
          "password": password,
          "role": role,
            "phone_number": phone,
            if (latitude != null) "latitude": latitude,
            if (longitude != null) "longitude": longitude,
        },
        requireAuth: false, 
      );

      return res.data;
    } catch (e) {
      throw Exception("Register failed: $e");
    }
  }

  // 👤 PROFILE (Protected)
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final res = await client.get(Endpoints.profile);
      return res.data;
    } catch (e) {
      throw Exception("Get profile failed: $e");
    }
  }

  Future<Map<String, dynamic>> updateProfileLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final res = await client.put(
        Endpoints.profile,
        data: {
          "latitude": latitude,
          "longitude": longitude,
        },
      );
      return res.data;
    } catch (e) {
      throw Exception("Update profile location failed: $e");
    }
  }

  //  FORGOT PASSWORD
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final res = await client.post(
        Endpoints.forgotPassword,
        data: {
          "email": email,
        },
        requireAuth: false, // optional
      );

      return res.data;
    } catch (e) {
      throw Exception("Forgot password failed: $e");
    }
  }
}