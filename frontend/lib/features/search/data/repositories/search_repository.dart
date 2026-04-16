import '../models/search_result_model.dart';
import '../datasources/search_api.dart';

class SearchRepository {
  final SearchApi api;

  SearchRepository(this.api);

  Future<SearchResultModel> search(String query) async {
    try {
      final data = await api.search(query);
      return SearchResultModel.fromJson(data);
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }
}
