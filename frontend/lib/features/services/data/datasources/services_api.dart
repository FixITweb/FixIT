import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';

class ServiceApi {
  final ApiClient client;

  ServiceApi(this.client);

  Future<List<dynamic>> fetchServices() async {
    final res = await client.get(Endpoints.services);
    return res.data;
  }
}