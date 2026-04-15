import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';

class ProfileApi {
  final ApiClient client;

  ProfileApi(this.client);

  Future<Map<String, dynamic>> fetchProfile() async {
    final res = await client.get(Endpoints.profile);
    return res.data;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    final res = await client.put(Endpoints.profile, data: profileData);
    return res.data;
  }
}