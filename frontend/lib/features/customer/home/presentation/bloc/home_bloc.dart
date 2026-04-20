import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../../../services/data/repositories/services_repository.dart';
import '../../../../services/data/models/service_model.dart';
import 'package:frontend/core/utils/location_helper.dart';


class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ServiceRepository serviceRepository;

  HomeBloc(this.serviceRepository) : super(HomeInitial()) {
    on<LoadServices>((event, emit) async {
      final currentState = state is HomeLoaded ? (state as HomeLoaded) : null;
      emit(HomeLoading());
      try {
        // Load services and categories in parallel
        final results = await Future.wait([
          serviceRepository.getServices(
            category: currentState?.selectedCategory == 'All' ? null : currentState?.selectedCategory,
            search: currentState?.searchQuery.isEmpty ?? true ? null : currentState?.searchQuery,
            minPrice: currentState?.minPrice,
            maxPrice: currentState?.maxPrice,
            radius: currentState?.radius,
            sort: currentState?.sort,
          ),
          serviceRepository.getCategories(),
        ]);

        final services = results[0] as List<ServiceModel>;
        final rawCategories = results[1] as List<String>;
        
        // Capitalize categories for the UI
        final categories = rawCategories.map((c) => _toTileCase(c)).toList();
        
        if (currentState != null) {
          emit(currentState.copyWith(
            services: services,
            filteredServices: services,
            categories: categories,
          ));
        } else {
          emit(HomeLoaded(
            services: services,
            filteredServices: services,
            categories: categories,
            selectedCategory: 'All',
            searchQuery: '',
          ));
        }
      } catch (e) {
        emit(HomeError('Failed to load services: ${e.toString()}'));
      }
    });

    on<FilterServices>((event, emit) {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        add(ApplyFilters(
          category: event.category,
          searchQuery: currentState.searchQuery,
          minPrice: currentState.minPrice,
          maxPrice: currentState.maxPrice,
          radius: currentState.radius,
          sort: currentState.sort,
        ));
      }
    });

    on<SearchServices>((event, emit) {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        add(ApplyFilters(
          category: currentState.selectedCategory,
          searchQuery: event.query,
          minPrice: currentState.minPrice,
          maxPrice: currentState.maxPrice,
          radius: currentState.radius,
          sort: currentState.sort,
        ));
      }
    });

    on<ApplyFilters>((event, emit) async {
      if (state is! HomeLoaded) return;
      final currentState = state as HomeLoaded;
      
      emit(HomeLoading());
      
      try {
        double? lat;
        double? lng;

        if (event.radius != null || event.sort == 'distance') {
          try {
            final position = await LocationHelper.getCurrentPosition();
            lat = position.latitude;
            lng = position.longitude;
          } catch (e) {
            print("Location fetch failed for filters: $e");
          }
        }

        final currentQuery = event.searchQuery ?? currentState.searchQuery;
        final actualRadius = event.radius == 50.0 ? null : event.radius;
        final actualMaxPrice = event.maxPrice == 500.0 ? null : event.maxPrice;
        final actualMinPrice = event.minPrice == 0.0 ? null : event.minPrice;

        final services = await serviceRepository.getServices(
          search: currentQuery.isEmpty ? null : currentQuery,
          category: event.category == 'All' ? null : event.category,
          minPrice: actualMinPrice,
          maxPrice: actualMaxPrice,
          radius: actualRadius,
          sort: event.sort,
          lat: lat,
          lng: lng,
        );

        emit(currentState.copyWith(
          services: services,
          filteredServices: services,
          selectedCategory: event.category,
          searchQuery: currentQuery,
          minPrice: event.minPrice,
          maxPrice: event.maxPrice,
          radius: event.radius,
          sort: event.sort,
        ));
      } catch (e) {
        emit(HomeError('Filtering failed: ${e.toString()}'));
      }
    });
  }

  String _toTileCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}