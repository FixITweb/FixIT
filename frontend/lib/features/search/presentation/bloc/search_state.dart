import '../../../services/data/models/service_model.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuggestionsLoaded extends SearchState {
  final List<String> suggestions;
  final List<String> trending;
  final List<String> categories;

  SearchSuggestionsLoaded({
    required this.suggestions,
    required this.trending,
    required this.categories,
  });
}

class SearchResultsLoaded extends SearchState {
  final List<ServiceModel> results;
  final List<String> suggestions;

  SearchResultsLoaded({
    required this.results,
    required this.suggestions,
  });
}

class SearchError extends SearchState {
  final String message;

  SearchError(this.message);
}
