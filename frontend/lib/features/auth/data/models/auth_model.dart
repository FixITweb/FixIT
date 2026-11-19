class AuthModel {
  final String accessToken;
  final String refreshToken;

  final int? userId;
  final String? username;
  final String? role;

  AuthModel({
    required this.accessToken,
    required this.refreshToken,
    this.userId,
    this.username,
    this.role,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      accessToken: json['access'] ?? '',
      refreshToken: json['refresh'] ?? '',
      userId: json['user'] != null ? json['user']['id'] : null,
      username: json['user'] != null ? json['user']['username'] : null,
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "access": accessToken,
      "refresh": refreshToken,
      "role": role,
      "user": userId != null
          ? {
              "id": userId,
              "username": username,
            }
          : null,
    };
  }
}
