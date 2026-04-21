class RatingModel {
  final int? id;
  final int workerId;
  final int? customerId;
  final String? customerName;
  final double rating;
  final String review;
  final DateTime createdAt;

  RatingModel({
    this.id,
    required this.workerId,
    this.customerId,
    this.customerName,
    required this.rating,
    required this.review,
    required this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'],
      workerId: json['worker_id'],
      customerId: json['customer_id'],
      customerName: json['customer_name'] ?? 'Anonymous',
      rating: (json['rating'] as num).toDouble(),
      review: json['review'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'worker_id': workerId,
      if (customerId != null) 'customer_id': customerId,
      if (customerName != null) 'customer_name': customerName,
      'rating': rating,
      'review': review,
      'created_at': createdAt.toIso8601String(),
    };
  }
}