class ServiceModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double rating;
  final DateTime createdAt;
  final double latitude;
  final double longitude;
  final double distance; // 🔥 NEW
  final WorkerModel worker;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.rating,
    required this.createdAt,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.worker,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0, // 🔥 SAFE
      worker: WorkerModel.fromJson(json['worker']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance, // 🔥 INCLUDED
      'worker': worker.toJson(),
    };
  }
}

class WorkerModel {
  final int id;
  final String username;

  WorkerModel({
    required this.id,
    required this.username,
  });

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    return WorkerModel(
      id: json['id'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
    };
  }
}