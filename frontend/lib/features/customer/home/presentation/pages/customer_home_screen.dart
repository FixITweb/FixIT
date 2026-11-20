import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../../../../../shared/widgets/theme_toggle_button.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/theme/app_theme.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final starColor = colorScheme.brightness == Brightness.dark
        ? const Color(0xFFFFD166)
        : const Color(0xFFB45309);
    final headerActionStyle = IconButton.styleFrom(
      foregroundColor: colorScheme.onSurface,
      backgroundColor: colorScheme.surfaceContainerLow,
      fixedSize: const Size.square(48),
      padding: EdgeInsets.zero,
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HomeError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<HomeBloc>().add(LoadServices()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is HomeLoaded) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: Text(
                                "Find Services",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.brandHeaderTitleStyle,
                              ),
                            ),
                            IconButtonTheme(
                              data:
                                  IconButtonThemeData(style: headerActionStyle),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const ThemeToggleButton(),
                                  IconButton(
                                    icon: const Icon(Icons.tune_rounded),
                                    tooltip: 'Filter services',
                                    onPressed: () {
                                      final homeBloc = context.read<HomeBloc>();
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(24),
                                          ),
                                        ),
                                        builder: (context) =>
                                            BlocProvider.value(
                                          value: homeBloc,
                                          child:
                                              FilterBottomSheet(state: state),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.notifications_none_rounded,
                                    ),
                                    tooltip: 'Notifications',
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/notifications',
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/search');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Search for services...',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: colorScheme.primary,
                                  size: 20,
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
                    height: 64,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      itemCount: state.categories.length + 1,
                      itemBuilder: (context, index) {
                        final cat =
                            index == 0 ? 'All' : state.categories[index - 1];
                        final isSelected = cat == state.selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(cat),
                            onSelected: (_) => context
                                .read<HomeBloc>()
                                .add(FilterServices(cat)),
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
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 56,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No services found',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Post your request to get notified when available',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, '/create-request');
                                  },
                                  icon: const Icon(Icons.add_circle_outline),
                                  label: const Text('Post Job Request'),
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () {
                                    context
                                        .read<HomeBloc>()
                                        .add(LoadServices());
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
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  leading: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.handyman_outlined,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  title: Text(
                                    service.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        "${service.worker.username} · ${service.distance.toStringAsFixed(1)} km",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star_rounded,
                                            color: starColor,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            service.rating.toStringAsFixed(1),
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium,
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              service.category,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    "\$${service.price.toStringAsFixed(0)}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: colorScheme.primary),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create-request'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Post request'),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }
}
