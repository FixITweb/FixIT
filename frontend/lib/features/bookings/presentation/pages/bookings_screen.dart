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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'My Bookings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF14B8A6), Color(0xFFF97316)],
                  ),
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: BlocBuilder<BookingBloc, BookingState>(
              builder: (context, state) {
                if (state is BookingLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is BookingError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'Oops! Something went wrong',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(state.message, textAlign: TextAlign.center),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => context.read<BookingBloc>().add(LoadBookings()),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is BookingLoaded) {
                  if (state.bookings.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_outlined, 
                            size: 80, 
                            color: Colors.grey.withOpacity(0.5)
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "No Bookings Yet",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Services you book will appear here",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<BookingBloc>().add(LoadBookings());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.bookings.length,
                      itemBuilder: (context, index) {
                        final booking = state.bookings[index];
                        return _BookingCard(booking: booking);
                      },
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 3),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final dynamic booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(booking.status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14B8A6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.work_outline, color: Color(0xFF14B8A6)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.service.title == 'Unavailable Service' 
                            ? 'Booking #${booking.id}' 
                            : booking.service.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (booking.service.worker.username != 'Unknown Worker')
                        Text(
                          "Worker: ${booking.service.worker.username}",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
                _StatusChip(status: booking.status, color: statusColor),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Price", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    if (booking.service.price > 0)
                      Text(
                        "\$${booking.service.price.toStringAsFixed(0)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF14B8A6)),
                      )
                    else
                      const Text(
                        "---",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Booked On", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      "${booking.createdAt.day}/${booking.createdAt.month}/${booking.createdAt.year}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    status = status.toLowerCase();
    if (status.contains('accept')) return Colors.green;
    if (status.contains('pend')) return Colors.orange;
    if (status.contains('complet')) return Colors.blue;
    return Colors.red;
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}