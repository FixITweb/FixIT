class WorkerDashboardModel {
  final String username;
  final double totalEarnings;
  final int activeBookings;
  final int completedJobs;
  final double rating;
  final int totalBookings;
  final int totalServices;

  WorkerDashboardModel({
    required this.username,
    required this.totalEarnings,
    required this.activeBookings,
    required this.completedJobs,
    required this.rating,
    required this.totalBookings,
    required this.totalServices,
  });

  factory WorkerDashboardModel.fromJson(Map<String, dynamic> json) {
    return WorkerDashboardModel(
      username: json['username'] ?? '',
      totalEarnings: (json['total_earnings'] ?? 0).toDouble(),
      activeBookings: json['active_bookings'] ?? 0,
      completedJobs: json['completed_jobs'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      totalBookings: json['total_bookings'] ?? 0,
      totalServices: json['total_services'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'total_earnings': totalEarnings,
      'active_bookings': activeBookings,
      'completed_jobs': completedJobs,
      'rating': rating,
      'total_bookings': totalBookings,
      'total_services': totalServices,
    };
  }
}
