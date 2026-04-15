abstract class CreateServiceEvent {}

class CreateService extends CreateServiceEvent {
  final String title;
  final String description;
  final String category;
  final double price;

  CreateService({
    required this.title,
    required this.description,
    required this.category,
    required this.price,
  });
}