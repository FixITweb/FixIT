import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../../../../shared/data/mock_data.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadServices>((event, emit) async {
      emit(HomeLoading());
      try {
        // Simulate API call delay
        await Future.delayed(const Duration(milliseconds: 500));
        
        emit(HomeLoaded(
          services: mockServices,
          filteredServices: mockServices,
          selectedCategory: 'All',
          searchQuery: '',
        ));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });

    on<FilterServices>((event, emit) {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        final filtered = _filterServices(
          currentState.services,
          event.category,
          currentState.searchQuery,
        );
        
        emit(currentState.copyWith(
          selectedCategory: event.category,
          filteredServices: filtered,
        ));
      }
    });

    on<SearchServices>((event, emit) {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        final filtered = _filterServices(
          currentState.services,
          currentState.selectedCategory,
          event.query,
        );
        
        emit(currentState.copyWith(
          searchQuery: event.query,
          filteredServices: filtered,
        ));
      }
    });
  }

  List<ServiceModel> _filterServices(
    List<ServiceModel> services,
    String category,
    String searchQuery,
  ) {
    return services.where((service) {
      final categoryMatch = category == 'All' || service.category == category;
      final searchMatch = service.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                         service.workerName.toLowerCase().contains(searchQuery.toLowerCase());
      return categoryMatch && searchMatch;
    }).toList();
  }
}