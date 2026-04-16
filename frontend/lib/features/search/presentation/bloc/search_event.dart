abstract class SearchEvent {}

class SearchServices extends SearchEvent {
  final String query;

  SearchServices(this.query);
}

class LoadSearchSuggestions extends SearchEvent {}

class ClearSearch extends SearchEvent {}
