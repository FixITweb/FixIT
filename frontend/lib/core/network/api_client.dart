import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({String? baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? 'http://127.0.0.1:8000/api/',
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
            headers: {
              "Content-Type": "application/json",
            },
          ),
        );

  //  SAVE TOKEN
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  //  GET TOKEN
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  //  AUTH HEADER CONTROL
  Future<Options> _getAuthOptions({bool requireAuth = true}) async {
    if (!requireAuth) return Options();

    final token = await getToken();

    return Options(
      headers: token != null
          ? {
              "Authorization": "Bearer $token",
            }
          : {},
    );
  }

  //  GET
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requireAuth = true,
  }) async {
    try {
      final options = await _getAuthOptions(requireAuth: requireAuth);

      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  //  POST
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requireAuth = true, // 🔥 THIS FIXES YOUR ERROR
  }) async {
    try {
      final options = await _getAuthOptions(requireAuth: requireAuth);

      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  //  PUT
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requireAuth = true,
  }) async {
    try {
      final options = await _getAuthOptions(requireAuth: requireAuth);

      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE
  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requireAuth = true,
  }) async {
    try {
      final options = await _getAuthOptions(requireAuth: requireAuth);

      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  //  ERROR HANDLING
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Connection timeout');

        case DioExceptionType.badResponse:
          return Exception(
              'Server error: ${error.response?.statusCode} - ${error.response?.data}');

        case DioExceptionType.cancel:
          return Exception('Request cancelled');

        default:
          return Exception('Network error: ${error.message}');
      }
    }
    return Exception('Unknown error');
  }
}