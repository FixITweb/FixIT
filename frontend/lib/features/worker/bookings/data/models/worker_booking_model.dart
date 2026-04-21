class WorkerBookingModel {
  final int id;
  final String status;
  final String serviceTitle;
  final String customerName;
  final double price;
  final DateTime scheduledDate;
  final DateTime createdAt;

  WorkerBookingModel({
    required this.id,
    required this.status,
    required this.serviceTitle,
    required this.customerName,
    required this.price,
    required this.scheduledDate,
    required this.createdAt,
  });

  factory WorkerBookingModel.fromJson(Map<String, dynamic> json) {
    return WorkerBookingModel(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'pending',
      serviceTitle: json['service'] != null 
          ? json['service']['title'] as String? ?? 'Unknown Service'
          : 'Unknown Service',
      customerName: json['customer'] != null
          ? json['customer']['username'] as String? ?? 'Unknown Customer'
          : 'Unknown Customer',
      price: json['service'] != null
          ? (json['service']['price'] as num?)?.toDouble() ?? 0.0
          : 0.0,
      scheduledDate: json['scheduled_date'] != null
          ? DateTime.parse(json['scheduled_date'] as String)
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'service': {
        'title': serviceTitle,
        'price': price,
      },
      'customer': {
        'username': customerName,
      },
      'scheduled_date': scheduledDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
