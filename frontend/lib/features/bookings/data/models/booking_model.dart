class BookingModel {
  final int id;
  final ServiceInfo service;
  final CustomerInfo? customer;
  final String status;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.service,
    this.customer,
    required this.status,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      service: ServiceInfo.fromJson(json['service'] ?? {}),
      customer: json['customer'] != null ? CustomerInfo.fromJson(json['customer']) : null,
      status: json['status'] ?? 'pending',
      createdAt: _parseDate(json['created_at']),
    );
  }

  static DateTime _parseDate(dynamic dateStr) {
    if (dateStr == null) return DateTime.now();
    try {
      return DateTime.parse(dateStr.toString());
    } catch (e) {
      print("Error parsing date: $dateStr. Using current time.");
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service': service.toJson(),
      'customer': customer?.toJson(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ServiceInfo {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final WorkerInfo worker;

  ServiceInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.worker,
  });

  factory ServiceInfo.fromJson(Map<String, dynamic> json) {
    return ServiceInfo(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unavailable Service',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: _toDouble(json['price']),
      worker: WorkerInfo.fromJson(json['worker'] ?? {}),
    );
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'worker': worker.toJson(),
    };
  }
}

class WorkerInfo {
  final int id;
  final String username;

  WorkerInfo({
    required this.id,
    required this.username,
  });

  factory WorkerInfo.fromJson(Map<String, dynamic> json) {
    return WorkerInfo(
      id: json['id'] ?? 0,
      username: json['username'] ?? 'Unknown Worker',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
    };
  }
}

class CustomerInfo {
  final int id;
  final String username;

  CustomerInfo({
    required this.id,
    required this.username,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      id: json['id'] ?? 0,
      username: json['username'] ?? 'Unknown Customer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
    };
  }
}