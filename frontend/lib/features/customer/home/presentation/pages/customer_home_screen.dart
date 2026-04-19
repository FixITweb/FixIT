import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../../../../../shared/widgets/theme_toggle_button.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../services/data/datasources/services_api.dart';
import '../../../../services/data/repositories/services_repository.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        ServiceRepository(
          ServiceApi(ApiClient()),
        ),
      )..add(LoadServices()),
      child: const CustomerHomeView(),
    );
  }
}

class CustomerHomeView extends StatelessWidget {
  const CustomerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<HomeBloc>().add(LoadServices()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is HomeLoaded) {
            return Column(
              children: [
                // Gradient Header
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF14B8A6), Color(0xFFF97316)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Find Services",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              const ThemeToggleButton(),
                              IconButton(
                                icon: const Icon(Icons.tune, color: Colors.white),
                                onPressed: () {
                                  final homeBloc = context.read<HomeBloc>();
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                                    ),
                                    builder: (context) => BlocProvider.value(
                                      value: homeBloc,
                                      child: FilterBottomSheet(state: state),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/search');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.grey),
                              const SizedBox(width: 12),
                              const Text(
                                'Search for services...',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF14B8A6).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF14B8A6),
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Categories
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.categories.length + 1,
                    itemBuilder: (context, index) {
                      final cat = index == 0 ? 'All' : state.categories[index - 1];
                      final isSelected = cat == state.selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8, top: 16),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(cat),
                          onSelected: (_) => context.read<HomeBloc>().add(FilterServices(cat)),
                        ),
                      );
                    },
                  ),
                ),

                // Services List
                Expanded(
                  child: state.filteredServices.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text(
                                'No services found',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  backgroundColor: const Color(0xFF14B8A6),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  context.read<HomeBloc>().add(LoadServices());
                                },
                                child: const Text('Try searching again'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.filteredServices.length,
                          itemBuilder: (context, index) {
                            final service = state.filteredServices[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: CircleAvatar(
                                  radius: 32,
                                  backgroundColor: const Color(0xFF14B8A6),
                                  child: Text(
                                    service.category.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 24,
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
                                    Text("${service.worker.username} • ${service.distance.toStringAsFixed(1)} km"),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        Text(" ${service.rating.toStringAsFixed(1)}"),
                                        const SizedBox(width: 8),
                                        Text(
                                          service.category,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  "\$${service.price.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF14B8A6),
                                  ),
                                ),
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/service-detail',
                                  arguments: service.id.toString(),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const Center(child: Text('No data'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-service'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }
}