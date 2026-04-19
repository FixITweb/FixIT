import '../../../../services/data/models/service_model.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ServiceModel> services;
  final List<ServiceModel> filteredServices;
  final List<String> categories;
  final String selectedCategory;
  final String searchQuery;
  final double? minPrice;
  final double? maxPrice;
  final double? radius;
  final String? sort;

  HomeLoaded({
    required this.services,
    required this.filteredServices,
    required this.categories,
    required this.selectedCategory,
    required this.searchQuery,
    this.minPrice,
    this.maxPrice,
    this.radius,
    this.sort,
  });

  HomeLoaded copyWith({
    List<ServiceModel>? services,
    List<ServiceModel>? filteredServices,
    List<String>? categories,
    String? selectedCategory,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    double? radius,
    String? sort,
  }) {
    return HomeLoaded(
      services: services ?? this.services,
      filteredServices: filteredServices ?? this.filteredServices,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      radius: radius ?? this.radius,
      sort: sort ?? this.sort,
    );
  }
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}