abstract class HomeEvent {}

class LoadServices extends HomeEvent {}

class FilterServices extends HomeEvent {
  final String category;
  FilterServices(this.category);
}

class SearchServices extends HomeEvent {
  final String query;
  SearchServices(this.query);
}