import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/service_model.dart';

class ServiceApi {
  final ApiClient client;

  ServiceApi(this.client);

  Future<List<ServiceModel>> fetchServices({
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
    try {
      final queryParams = {
        if (search != null) "search": search,
        if (category != null) "category": category,
        if (minPrice != null) "min_price": minPrice,
        if (maxPrice != null) "max_price": maxPrice,
        if (rating != null) "rating": rating,
        if (lat != null) "lat": lat,
        if (lng != null) "lng": lng,
        if (radius != null) "radius": radius,
        if (date != null) "date": date,
        if (sort != null) "sort": sort,
      };

      final res = await client.get(
        Endpoints.services,
        queryParameters: queryParams,
      );

      final List data = res.data;

      return data.map((e) => ServiceModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Fetch services failed: $e");
    }
  }

  Future<List<ServiceModel>> fetchMyServices() async {
    try {
      final res = await client.get(Endpoints.myServices);
      final List data = res.data;
      return data.map((e) => ServiceModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Fetch my services failed: $e");
    }
  }

  //  FETCH CATEGORIES
  Future<List<String>> fetchCategories() async {
    try {
      final res = await client.get(Endpoints.categories);
      final List data = res.data;
      return data.map((e) => e.toString()).toList();
    } catch (e) {
      throw Exception("Fetch categories failed: $e");
    }
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
    try {
      await client.post(
        Endpoints.services,
        data: {
          "title": title,
          "description": description,
          "category": category,
          "price": price,
          "latitude": latitude,
          "longitude": longitude,
        },
      );
    } catch (e) {
      throw Exception("Create service failed: $e");
    }
  }

  // UPDATE SERVICE
  Future<void> updateService({
    required int id,
    required String title,
    required String description,
    required String category,
    required double price,
  }) async {
    try {
      await client.put(
        'services/$id/',
        data: {
          "title": title,
          "description": description,
          "category": category,
          "price": price,
        },
      );
    } catch (e) {
      throw Exception("Update service failed: $e");
    }
  }

  // DELETE SERVICE
  Future<void> deleteService(int id) async {
    try {
      await client.delete('services/$id/');
    } catch (e) {
      throw Exception("Delete service failed: $e");
    }
  }
}
