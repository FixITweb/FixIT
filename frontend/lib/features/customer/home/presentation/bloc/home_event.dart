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

class ApplyFilters extends HomeEvent {
  final String? category;
  final String? searchQuery;
  final double? minPrice;
  final double? maxPrice;
  final double? radius;
  final String? sort;

  ApplyFilters({
    this.category,
    this.searchQuery,
    this.minPrice,
    this.maxPrice,
    this.radius,
    this.sort,
  });
}