import '../models/service_model.dart';
import '../datasources/services_api.dart';

class ServiceRepository {
  final ServiceApi api;

  ServiceRepository(this.api);

  Future<List<ServiceModel>> getServices() async {
    final data = await api.fetchServices();
    return data.map((e) => ServiceModel.fromJson(e)).toList();
  }
}