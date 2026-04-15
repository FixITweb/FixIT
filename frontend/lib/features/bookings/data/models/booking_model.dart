class BookingModel {
  final String id;
  final String serviceId;
  final String userId;
  final String providerId;
  final DateTime scheduledDate;
  final String status;
  final double totalPrice;
  final String? notes;

  BookingModel({
    required this.id,
    required this.serviceId,
    required this.userId,
    required this.providerId,
    required this.scheduledDate,
    required this.status,
    required this.totalPrice,
    this.notes,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'].toString(),
      serviceId: json['service_id'].toString(),
      userId: json['user_id'].toString(),
      providerId: json['provider_id'].toString(),
      scheduledDate: DateTime.parse(json['scheduled_date']),
      status: json['status'],
      totalPrice: (json['total_price'] as num).toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'user_id': userId,
      'provider_id': providerId,
      'scheduled_date': scheduledDate.toIso8601String(),
      'status': status,
      'total_price': totalPrice,
      'notes': notes,
    };
  }
}