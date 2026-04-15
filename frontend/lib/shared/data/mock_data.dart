final List<String> categories = [
  'All',
  'Plumbing',
  'Electrical',
  'Cleaning',
  'Carpentry',
  'Painting',
];

class ServiceModel {
  final String id;
  final String title;
  final String category;
  final double price;
  final String workerName;
  final String workerAvatar;
  final double distance;
  final double rating;
  final int reviewCount;
  final String description;

  ServiceModel({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.workerName,
    required this.workerAvatar,
    required this.distance,
    required this.rating,
    required this.reviewCount,
    required this.description,
  });
}

class MockBookingModel {
  final String id;
  final String serviceTitle;
  final String workerName;
  final DateTime scheduledDate;
  final String status;
  final double price;

  MockBookingModel({
    required this.id,
    required this.serviceTitle,
    required this.workerName,
    required this.scheduledDate,
    required this.status,
    required this.price,
  });
}

final List<ServiceModel> mockServices = [
  ServiceModel(
    id: '1',
    title: 'Sink Repair',
    category: 'Plumbing',
    price: 75.0,
    workerName: 'John Smith',
    workerAvatar: '🔧',
    distance: 2.5,
    rating: 4.8,
    reviewCount: 124,
    description: 'Professional sink repair service with 5+ years experience',
  ),
  ServiceModel(
    id: '2',
    title: 'House Cleaning',
    category: 'Cleaning',
    price: 120.0,
    workerName: 'Sarah Johnson',
    workerAvatar: '🧹',
    distance: 1.2,
    rating: 4.9,
    reviewCount: 89,
    description: 'Complete house cleaning service including all rooms',
  ),
  ServiceModel(
    id: '3',
    title: 'Electrical Wiring',
    category: 'Electrical',
    price: 150.0,
    workerName: 'Mike Wilson',
    workerAvatar: '⚡',
    distance: 3.8,
    rating: 4.7,
    reviewCount: 156,
    description: 'Licensed electrician for all your electrical needs',
  ),
];

final List<MockBookingModel> mockBookings = [
  MockBookingModel(
    id: '1',
    serviceTitle: 'Sink Repair',
    workerName: 'John Smith',
    scheduledDate: DateTime.now().add(const Duration(days: 1)),
    status: 'Pending',
    price: 75.0,
  ),
  MockBookingModel(
    id: '2',
    serviceTitle: 'House Cleaning',
    workerName: 'Sarah Johnson',
    scheduledDate: DateTime.now().add(const Duration(days: 2)),
    status: 'Confirmed',
    price: 120.0,
  ),
];