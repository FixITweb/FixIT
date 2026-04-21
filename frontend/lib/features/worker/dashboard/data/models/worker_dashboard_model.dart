class WorkerDashboardModel {
  final String username;
  final double averageRating;
  final double totalEarnings;
  final int bookingsCount;
  final int completedJobs;
  final int servicesCount;

  WorkerDashboardModel({
    required this.username,
    required this.averageRating,
    required this.totalEarnings,
    required this.bookingsCount,
    required this.completedJobs,
    required this.servicesCount,
  });

  factory WorkerDashboardModel.fromJson(Map<String, dynamic> json) {
    return WorkerDashboardModel(
      username: json['username'] ?? '',
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      totalEarnings: (json['total_earnings'] ?? 0).toDouble(),
      bookingsCount: json['bookings_count'] ?? 0,
      completedJobs: json['completed_jobs'] ?? 0,
      servicesCount: json['services_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'average_rating': averageRating,
      'total_earnings': totalEarnings,
      'bookings_count': bookingsCount,
      'completed_jobs': completedJobs,
      'services_count': servicesCount,
    };
  }
}
