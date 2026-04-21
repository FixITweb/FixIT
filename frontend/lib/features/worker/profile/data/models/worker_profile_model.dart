class WorkerProfileModel {
  final int id;
  final String username;
  final String email;
  final String role;
  final int servicesCount;
  final int bookingsCount;
  final int completedJobs;
  final double totalEarnings;
  final double averageRating;
  final DateTime createdAt;

  WorkerProfileModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.servicesCount,
    required this.bookingsCount,
    required this.completedJobs,
    required this.totalEarnings,
    required this.averageRating,
    required this.createdAt,
  });

  factory WorkerProfileModel.fromJson(Map<String, dynamic> json) {
    return WorkerProfileModel(
      id: json['id'] as int,
      username: json['username'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'worker',
      servicesCount: json['services_count'] as int? ?? 0,
      bookingsCount: json['bookings_count'] as int? ?? 0,
      completedJobs: json['completed_jobs'] as int? ?? 0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'services_count': servicesCount,
      'bookings_count': bookingsCount,
      'completed_jobs': completedJobs,
      'total_earnings': totalEarnings,
      'average_rating': averageRating,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
