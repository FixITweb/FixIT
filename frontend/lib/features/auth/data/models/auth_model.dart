class AuthModel {
  final String accessToken;
  final String refreshToken;

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