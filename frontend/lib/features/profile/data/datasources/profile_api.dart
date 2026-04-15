import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';

class ProfileApi {
  final ApiClient client;

  ProfileApi(this.client);

  Future<Map<String, dynamic>> fetchProfile() async {
    final res = await client.get(Endpoints.profile);
    return res.data;
  }
}