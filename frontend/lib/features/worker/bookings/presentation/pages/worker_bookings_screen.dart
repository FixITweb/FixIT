import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/worker_bookings_bloc.dart';
import '../bloc/worker_bookings_event.dart';
import '../bloc/worker_bookings_state.dart';
import '../../../dashboard/presentation/widgets/worker_bottom_nav.dart';

class WorkerBookingsScreen extends StatelessWidget {
  const WorkerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkerBookingsBloc()..add(LoadWorkerBookings()),
      child: const WorkerBookingsView(),
    );
  }
}

class WorkerBookingsView extends StatelessWidget {
  const WorkerBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bookings")),
      body: BlocConsumer<WorkerBookingsBloc, WorkerBookingsState>(
        listener: (context, state) {
          if (state is WorkerBookingUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is WorkerBookingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is WorkerBookingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WorkerBookingsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () => context.read<WorkerBookingsBloc>().add(LoadWorkerBookings()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is WorkerBookingsLoaded) {
            if (state.bookings.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "No Bookings Yet",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text("Bookings will appear here when customers book your services"),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.bookings.length,
              itemBuilder: (context, index) {
                final booking = state.bookings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                booking.serviceTitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Chip(
                              label: Text(
                                booking.status,
                                style: TextStyle(
                                  color: _getStatusColor(booking.status),
                                ),
                              ),
                              backgroundColor: _getStatusColor(booking.status).withValues(alpha: 0.1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("Customer: ${booking.customerName}"),
                        Text("Date: ${booking.scheduledDate.day}/${booking.scheduledDate.month}/${booking.scheduledDate.year}"),
                        Text("Price: \$${booking.price}"),
                        const SizedBox(height: 12),
                        if (booking.status == 'Pending') ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => context.read<WorkerBookingsBloc>().add(
                                    AcceptBooking(booking.id),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Accept'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => context.read<WorkerBookingsBloc>().add(
                                    RejectBooking(booking.id),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Reject'),
                                ),
                              ),
                            ],
                          ),
                        ] else if (booking.status == 'Accepted') ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => context.read<WorkerBookingsBloc>().add(
                                CompleteBooking(booking.id),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Mark as Completed'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const Center(child: Text('No data'));
        },
      ),
      bottomNavigationBar: const WorkerBottomNav(currentIndex: 2),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Accepted':
        return Colors.green;
      case 'Completed':
        return Colors.blue;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}