import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../../../../core/network/api_client.dart';
import '../../../search/data/datasources/search_api.dart';
import '../../../search/data/repositories/search_repository.dart';

class EnhancedSearchScreen extends StatelessWidget {
  final String? initialQuery;

  const EnhancedSearchScreen({super.key, this.initialQuery});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(
        SearchRepository(SearchApi(ApiClient())),
      )..add(initialQuery != null ? SearchServices(initialQuery!) : LoadSearchSuggestions()),
      child: const EnhancedSearchView(),
    );
  }
}

class EnhancedSearchView extends StatefulWidget {
  const EnhancedSearchView({super.key});

  @override
  State<EnhancedSearchView> createState() => _EnhancedSearchViewState();
}

class _EnhancedSearchViewState extends State<EnhancedSearchView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search for services...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      context.read<SearchBloc>().add(ClearSearch());
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            if (value.isEmpty) {
              context.read<SearchBloc>().add(LoadSearchSuggestions());
            } else {
              context.read<SearchBloc>().add(SearchServices(value));
            }
          },
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              context.read<SearchBloc>().add(SearchServices(value));
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                context.read<SearchBloc>().add(SearchServices(_searchController.text));
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SearchError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<SearchBloc>().add(LoadSearchSuggestions()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is SearchInitial || state is SearchSuggestionsLoaded) {
            return _buildSuggestionsView(context, state);
          }

          if (state is SearchResultsLoaded) {
            return _buildSearchResults(context, state);
          }

          return const Center(child: Text('Start searching...'));
        },
      ),
    );
  }

  Widget _buildSuggestionsView(BuildContext context, SearchState state) {
    final suggestions = state is SearchSuggestionsLoaded ? state.suggestions : <String>[];
    final trending = state is SearchSuggestionsLoaded ? state.trending : <String>[];
    final categories = state is SearchSuggestionsLoaded ? state.categories : <String>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trending Searches
          if (trending.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.trending_up, color: Color(0xFF14B8A6)),
                const SizedBox(width: 8),
                const Text(
                  'Trending Searches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: trending.map((term) {
                return ActionChip(
                  avatar: const Icon(Icons.whatshot, size: 18, color: Colors.orange),
                  label: Text(term),
                  onPressed: () {
                    _searchController.text = term;
                    context.read<SearchBloc>().add(SearchServices(term));
                  },
                  backgroundColor: Colors.orange.withOpacity(0.1),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Popular Categories
          if (categories.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.category, color: Color(0xFF14B8A6)),
                const SizedBox(width: 8),
                const Text(
                  'Popular Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  elevation: 1,
                  child: InkWell(
                    onTap: () {
                      _searchController.text = category;
                      context.read<SearchBloc>().add(SearchServices(category));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14B8A6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getCategoryIcon(category),
                              color: const Color(0xFF14B8A6),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],

          // Search Suggestions
          if (suggestions.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Color(0xFF14B8A6)),
                const SizedBox(width: 8),
                const Text(
                  'Suggested Searches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...suggestions.map((suggestion) {
              return ListTile(
                leading: const Icon(Icons.search, color: Colors.grey),
                title: Text(suggestion),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _searchController.text = suggestion;
                  context.read<SearchBloc>().add(SearchServices(suggestion));
                },
              );
            }).toList(),
          ],

          // Quick Tips
          const SizedBox(height: 24),
          Card(
            color: const Color(0xFF14B8A6).withOpacity(0.1),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: Color(0xFF14B8A6)),
                      SizedBox(width: 8),
                      Text(
                        'Search Tips',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text('• Try searching by service type (e.g., "plumber", "electrician")'),
                  SizedBox(height: 4),
                  Text('• Use category names for better results'),
                  SizedBox(height: 4),
                  Text('• Don\'t worry about typos - we\'ll find what you need!'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, SearchResultsLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Results Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.results.length} results found',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (state.results.isEmpty)
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/create-request');
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Post Request'),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // No Results
          if (state.results.isEmpty) ...[
            Center(
              child: Column(
                children: [
                  const Icon(Icons.search_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No services found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Post your request to get notified when available',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/create-request');
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Post Job Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14B8A6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Search Results List
          ...state.results.map((service) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF14B8A6),
                  child: Text(
                    service.category.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                title: Text(
                  service.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('${service.worker.username} • ${service.distance.toStringAsFixed(1)} km'),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(' ${service.rating.toStringAsFixed(1)}'),
                        const SizedBox(width: 8),
                        Text(
                          service.category,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Text(
                  '\$${service.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF14B8A6),
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/service-detail',
                    arguments: service.id.toString(),
                  );
                },
              ),
            );
          }).toList(),

          // Related Suggestions
          if (state.suggestions.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.recommend, color: Color(0xFF14B8A6)),
                const SizedBox(width: 8),
                const Text(
                  'Related Searches',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.suggestions.map((suggestion) {
                return ActionChip(
                  label: Text(suggestion),
                  onPressed: () {
                    _searchController.text = suggestion;
                    context.read<SearchBloc>().add(SearchServices(suggestion));
                  },
                  backgroundColor: const Color(0xFF14B8A6).withOpacity(0.1),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
        return Icons.electrical_services;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'carpentry':
        return Icons.carpenter;
      case 'painting':
        return Icons.format_paint;
      case 'moving':
        return Icons.local_shipping;
      case 'gardening':
        return Icons.yard;
      default:
        return Icons.build;
    }
  }
}
