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
    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return WorkerDashboardModel(
      username: json['username'] ?? '',
      averageRating: toDouble(json['rating'] ?? json['average_rating']),
      totalEarnings: toDouble(json['total_earnings']),
      bookingsCount: toInt(json['active_bookings'] ?? json['bookings_count']),
      completedJobs:
          toInt(json['completed_bookings'] ?? json['completed_jobs']),
      servicesCount: toInt(json['total_services'] ?? json['services_count']),
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
