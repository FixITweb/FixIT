import '../../../services/data/models/service_model.dart';

class SearchResultModel {
  final List<ServiceModel> results;
  final List<String> suggestions;

  SearchResultModel({
    required this.results,
    required this.suggestions,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      results: (json['results'] as List?)
              ?.map((e) => ServiceModel.fromJson(e))
              .toList() ??
          [],
      suggestions: (json['suggestions'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'results': results.map((e) => e.toJson()).toList(),
      'suggestions': suggestions,
    };
  }
}
