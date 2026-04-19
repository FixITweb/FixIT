import '../models/service_model.dart';
import '../datasources/services_api.dart';

class ServiceRepository {
  final ServiceApi api;

  ServiceRepository(this.api);

  //  GET SERVICES (WITH FILTERS SUPPORT)
  Future<List<ServiceModel>> getServices({
    String? search,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? rating,
    double? lat,
    double? lng,
    double? radius,
    String? date,
    String? sort,
  }) async {
    return await api.fetchServices(
      search: search,
      category: category,
      minPrice: minPrice,
      maxPrice: maxPrice,
      rating: rating,
      lat: lat,
      lng: lng,
      radius: radius,
      date: date,
      sort: sort,
    );
  }

  //  FETCH CATEGORIES
  Future<List<String>> getCategories() async {
    return await api.fetchCategories();
  }

  //  CREATE SERVICE
  Future<void> createService({
    required String title,
    required String description,
    required String category,
    required double price,
    required double latitude,
    required double longitude,
  }) async {
    await api.createService(
      title: title,
      description: description,
      category: category,
      price: price,
      latitude: latitude,
      longitude: longitude,
    );
  }

  // UPDATE SERVICE
  Future<void> updateService({
    required int id,
    required String title,
    required String description,
    required String category,
    required double price,
  }) async {
    await api.updateService(
      id: id,
      title: title,
      description: description,
      category: category,
      price: price,
    );
  }

  // DELETE SERVICE
  Future<void> deleteService(int id) async {
    await api.deleteService(id);
  }
}