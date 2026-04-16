abstract class WorkerServicesEvent {}

class LoadWorkerServices extends WorkerServicesEvent {}

class AddWorkerService extends WorkerServicesEvent {
  final String title;
  final String category;
  final double price;
  final String description;

  AddWorkerService({
    required this.title,
    required this.category,
    required this.price,
    required this.description,
  });
}

class UpdateWorkerService extends WorkerServicesEvent {
  final int id;
  final String title;
  final String category;
  final double price;
  final String description;

  UpdateWorkerService({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.description,
  });
}

class DeleteWorkerService extends WorkerServicesEvent {
  final int id;
  DeleteWorkerService(this.id);
}

class ToggleServiceStatus extends WorkerServicesEvent {
  final String serviceId;
  ToggleServiceStatus(this.serviceId);
}
