class WorkerServiceModel {
  final String id;
  final String title;
  final String category;
  final double price;
  final bool isActive;
  final String description;

  WorkerServiceModel({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.isActive,
    required this.description,
  });

  WorkerServiceModel copyWith({
    String? id,
    String? title,
    String? category,
    double? price,
    bool? isActive,
    String? description,
  }) {
    return WorkerServiceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
    );
  }
}

abstract class WorkerServicesState {}

class WorkerServicesInitial extends WorkerServicesState {}

class WorkerServicesLoading extends WorkerServicesState {}

class WorkerServicesLoaded extends WorkerServicesState {
  final List<WorkerServiceModel> services;
  WorkerServicesLoaded(this.services);
}

class WorkerServiceAdded extends WorkerServicesState {
  final String message;
  WorkerServiceAdded(this.message);
}

class WorkerServicesError extends WorkerServicesState {
  final String message;
  WorkerServicesError(this.message);
}