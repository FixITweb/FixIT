class BookingModel {
  final int id;
  final ServiceInfo service;
  final CustomerInfo? customer;
  final String status;
  final DateTime createdAt;
  //new
  final String? customerPhone;
  final String? workerPhone;

  BookingModel({
    required this.id,
    required this.service,
    this.customer,
    required this.status,
    required this.createdAt,
    //new
    this.customerPhone,
    this.workerPhone,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? 0,

      // SAFE SERVICE PARSING (fixes your crash)
      service: (json['service'] is Map<String, dynamic>)
          ? ServiceInfo.fromJson(json['service'])
          : ServiceInfo.empty(),

      // SAFE CUSTOMER PARSING
      customer: (json['customer'] is Map<String, dynamic>)
          ? CustomerInfo.fromJson(json['customer'])
          : null,

      status: json['status'] ?? 'pending',

      createdAt: _parseDate(
        json['createdAt'] ?? json['created_at'],
      ),

      customerPhone: json['customerPhone']?.toString() ?? json['customer_phone']?.toString(),
      workerPhone: json['workerPhone']?.toString() ?? json['worker_phone']?.toString(),
    );
  }

  static DateTime _parseDate(dynamic dateStr) {
    if (dateStr == null) return DateTime.now();
    try {
      return DateTime.parse(dateStr.toString());
    } catch (e) {
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

      //new
      'customer_phone': customerPhone,
      'worker_phone': workerPhone,
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

      worker: (json['worker'] is Map<String, dynamic>)
          ? WorkerInfo.fromJson(json['worker'])
          : WorkerInfo.empty(),
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

  // 🔥 EMPTY FALLBACK (VERY IMPORTANT)
  factory ServiceInfo.empty() {
    return ServiceInfo(
      id: 0,
      title: 'Unavailable Service',
      description: '',
      category: '',
      price: 0.0,
      worker: WorkerInfo.empty(),
    );
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

  factory WorkerInfo.empty() {
    return WorkerInfo(
      id: 0,
      username: 'Unknown Worker',
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

  factory CustomerInfo.empty() {
    return CustomerInfo(
      id: 0,
      username: 'Unknown Customer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
    };
  }
}