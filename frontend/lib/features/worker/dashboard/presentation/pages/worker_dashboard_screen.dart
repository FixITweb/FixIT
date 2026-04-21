import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/worker_bottom_nav.dart';
import '../../../../../shared/widgets/theme_toggle_button.dart';
import '../bloc/worker_dashboard_bloc.dart';
import '../bloc/worker_dashboard_event.dart';
import '../bloc/worker_dashboard_state.dart';
import '../../data/datasources/worker_dashboard_api.dart';
import '../../data/repositories/worker_dashboard_repository.dart';
import '../../../../../core/network/api_client.dart';

class WorkerDashboardScreen extends StatelessWidget {
  const WorkerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkerDashboardBloc(
        WorkerDashboardRepository(WorkerDashboardApi(ApiClient())),
      )..add(const LoadWorkerDashboard()),
      child: const WorkerDashboardView(),
    );
  }
}

class WorkerDashboardView extends StatelessWidget {
  const WorkerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: const Text("Dashboard"),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: const [ThemeToggleButton()],
      ),
      body: BlocBuilder<WorkerDashboardBloc, WorkerDashboardState>(
        builder: (context, state) {
          if (state is WorkerDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WorkerDashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<WorkerDashboardBloc>().add(const LoadWorkerDashboard()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is WorkerDashboardLoaded) {
            final dashboard = state.dashboard;
            
            return RefreshIndicator(
              onRefresh: () async {
                context.read<WorkerDashboardBloc>().add(const RefreshWorkerDashboard());
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with greeting
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF14B8A6), Color(0xFFF97316)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                child: Text(
                                  dashboard.username.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back!',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dashboard.username,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${dashboard.averageRating.toStringAsFixed(1)} Rating',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Stats Grid
                    Text(
                      'Your Statistics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Row 1: Earnings and Bookings
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.attach_money,
                            iconColor: Colors.green,
                            title: 'Total Earnings',
                            value: '\$${dashboard.totalEarnings.toStringAsFixed(0)}',
                            subtitle: 'This month',
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.calendar_today,
                            iconColor: Colors.blue,
                            title: 'Active Bookings',
                            value: dashboard.bookingsCount.toString(),
                            subtitle: 'In progress',
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 2: Completed Jobs and Services
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.check_circle,
                            iconColor: Colors.teal,
                            title: 'Completed Jobs',
                            value: dashboard.completedJobs.toString(),
                            subtitle: 'Total completed',
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.work,
                            iconColor: Colors.purple,
                            title: 'Services',
                            value: dashboard.servicesCount.toString(),
                            subtitle: 'Active services',
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.calendar_today,
                            label: 'Bookings',
                            onTap: () => Navigator.pushNamed(context, '/worker-bookings'),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.work,
                            label: 'Services',
                            onTap: () => Navigator.pushNamed(context, '/worker-services'),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.notifications,
                            label: 'Notifications',
                            onTap: () => Navigator.pushNamed(context, '/worker-notifications'),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.person,
                            label: 'Profile',
                            onTap: () => Navigator.pushNamed(context, '/worker-profile'),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
      bottomNavigationBar: const WorkerBottomNav(currentIndex: 0),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF14B8A6).withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF14B8A6),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF14B8A6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
