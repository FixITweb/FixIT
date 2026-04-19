abstract class CreateRequestEvent {}

class SubmitRequest extends CreateRequestEvent {
  final String title;
  final String description;
  final String category;
  final double latitude;
  final double longitude;
  final double budget;

  SubmitRequest({
    required this.title,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.budget,
  });
}

class LoadCategories extends CreateRequestEvent {}
