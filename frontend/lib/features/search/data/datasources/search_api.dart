import '../../../../core/network/api_client.dart';

class SearchApi {
  final ApiClient client;

  SearchApi(this.client);

  Future<Map<String, dynamic>> search(String query) async {
    final res = await client.get('search/?q=$query');
    return res.data;
  }
}
