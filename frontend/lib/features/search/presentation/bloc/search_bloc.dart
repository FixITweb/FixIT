import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_event.dart';
import 'search_state.dart';
import '../../data/repositories/search_repository.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository repository;

  SearchBloc(this.repository) : super(SearchInitial()) {
    on<LoadSearchSuggestions>((event, emit) async {
      emit(SearchLoading());
      try {
        // Load default suggestions, trending, and categories
        final suggestions = [
          'Plumber near me',
          'Emergency electrician',
          'House cleaning service',
          'Furniture assembly',
          'AC repair',
        ];

        final trending = [
          'Plumbing',
          'Electrical',
          'Cleaning',
          'Carpentry',
        ];

        final categories = [
          'Plumbing',
          'Electrical',
          'Cleaning',
          'Carpentry',
          'Painting',
          'Moving',
          'Gardening',
          'Appliance Repair',
        ];

        emit(SearchSuggestionsLoaded(
          suggestions: suggestions,
          trending: trending,
          categories: categories,
        ));
      } catch (e) {
        emit(SearchError('Failed to load suggestions: ${e.toString()}'));
      }
    });

    on<SearchServices>((event, emit) async {
      emit(SearchLoading());
      try {
        final searchResult = await repository.search(event.query);
        
        emit(SearchResultsLoaded(
          results: searchResult.results,
          suggestions: searchResult.suggestions,
        ));
      } catch (e) {
        emit(SearchError('Search failed: ${e.toString()}'));
      }
    });

    on<ClearSearch>((event, emit) async {
      add(LoadSearchSuggestions());
    });
  }
}
