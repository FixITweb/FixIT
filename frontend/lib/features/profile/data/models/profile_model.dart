class ProfileModel {
  final int id;
  final String username;
  final String role;
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    required this.username,
    required this.role,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      username: json['username'],
      role: json['role'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}