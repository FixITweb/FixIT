class AuthModel {
  final String accessToken;
  final String refreshToken;

  // Optional user info (in case backend sends it)
  final int? userId;
  final String? username;

  AuthModel({
    required this.accessToken,
    required this.refreshToken,
    this.userId,
    this.username,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      accessToken: json['access'] ?? '',
      refreshToken: json['refresh'] ?? '',

      // Optional parsing (safe)
      userId: json['user'] != null ? json['user']['id'] : null,
      username: json['user'] != null ? json['user']['username'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "access": accessToken,
      "refresh": refreshToken,
      "user": userId != null
          ? {
              "id": userId,
              "username": username,
            }
          : null,
    };
  }
}