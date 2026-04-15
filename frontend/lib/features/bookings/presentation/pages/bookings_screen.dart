import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/datasources/booking_api.dart';
import '../../../../core/network/api_client.dart';
import '../../../customer/home/presentation/widgets/bottom_nav.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookingBloc(
        BookingRepository(BookingApi(ApiClient())),
      )..add(LoadBookings()),
      child: const BookingsView(),
    );
  }
}

class BookingsView extends StatelessWidget {
  const BookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings")),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BookingError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () => context.read<BookingBloc>().add(LoadBookings()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is BookingLoaded) {
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
                    Text("Book a service to see it here"),
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
                  child: ListTile(
                    title: Text(booking.service.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Worker: ${booking.service.worker.username} • \$${booking.service.price}"),
                        Text(
                          "Booked: ${booking.createdAt.day}/${booking.createdAt.month}/${booking.createdAt.year}",
                        ),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        booking.status.toUpperCase(),
                        style: TextStyle(
                          color: booking.status == 'accepted' 
                              ? Colors.green 
                              : booking.status == 'pending'
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                      backgroundColor: booking.status == 'accepted' 
                          ? Colors.green.withValues(alpha: 0.1)
                          : booking.status == 'pending'
                          ? Colors.orange.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(child: Text('No data'));
        },
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 3),
    );
  }
}