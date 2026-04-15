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
      createdAt: DateTime.parse(json['created_at']),
    );
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
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      worker: WorkerInfo.fromJson(json['worker'] ?? {}),
    );
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
      username: json['username'] ?? '',
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
      username: json['username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
    };
  }
}