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

class ToggleServiceStatus extends WorkerServicesEvent {
  final String serviceId;
  ToggleServiceStatus(this.serviceId);
}