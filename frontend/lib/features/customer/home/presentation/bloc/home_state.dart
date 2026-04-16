import '../../../../services/data/models/service_model.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ServiceModel> services;
  final List<ServiceModel> filteredServices;
  final String selectedCategory;
  final String searchQuery;

  HomeLoaded({
    required this.services,
    required this.filteredServices,
    required this.selectedCategory,
    required this.searchQuery,
  });

  HomeLoaded copyWith({
    List<ServiceModel>? services,
    List<ServiceModel>? filteredServices,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return HomeLoaded(
      services: services ?? this.services,
      filteredServices: filteredServices ?? this.filteredServices,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}