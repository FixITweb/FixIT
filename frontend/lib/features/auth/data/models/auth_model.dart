class AuthModel {
  final String token;
  final String? role;
  final String? name;

  AuthModel({
    required this.token,
    this.role,
    this.name,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token'],
      role: json['role'],
      name: json['name'],
    );
  }
}