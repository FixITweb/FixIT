class ServiceModel {
  final String id;
  final String title;
  final String category;
  final double price;

  ServiceModel({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'].toString(),
      title: json['title'],
      category: json['category'],
      price: (json['price'] as num).toDouble(),
    );
  }
}