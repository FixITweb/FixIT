import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/worker_dashboard_bloc.dart';
import '../bloc/worker_dashboard_event.dart';
import '../bloc/worker_dashboard_state.dart';
import '../widgets/worker_bottom_nav.dart';
import '../../../../../shared/widgets/theme_toggle_button.dart';

class WorkerDashboardScreen extends StatelessWidget {
  const WorkerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkerDashboardBloc()..add(LoadWorkerDashboard()),
      child: const WorkerDashboardView(),
    );
  }
}

class WorkerDashboardView extends StatelessWidget {
  const WorkerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<WorkerDashboardBloc>().add(RefreshDashboard()),
          ),
        ],
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
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () => context.read<WorkerDashboardBloc>().add(LoadWorkerDashboard()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is WorkerDashboardLoaded) {
            final data = state.data;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Hello, Alex 👋",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Here's your overview",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  Card(
                    child: ListTile(
                      title: const Text("Total Earnings"),
                      subtitle: Text("\$${data.totalEarnings.toStringAsFixed(0)} this month"),
                      leading: const Icon(Icons.attach_money, color: Colors.green, size: 40),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text("Active Bookings"),
                      subtitle: Text("${data.activeBookings} bookings this week"),
                      leading: const Icon(Icons.calendar_today, color: Colors.blue, size: 40),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text("Completed Jobs"),
                      subtitle: Text("${data.completedJobs} jobs completed"),
                      leading: const Icon(Icons.check_circle, color: Colors.teal, size: 40),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text("Rating"),
                      subtitle: Text("${data.rating} ⭐ average rating"),
                      leading: const Icon(Icons.star, color: Colors.amber, size: 40),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('No data'));
        },
      ),
      bottomNavigationBar: const WorkerBottomNav(currentIndex: 0),
    );
  }
}