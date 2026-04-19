import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/worker_bookings_bloc.dart';
import '../bloc/worker_bookings_event.dart';
import '../bloc/worker_bookings_state.dart';
import '../../../dashboard/presentation/widgets/worker_bottom_nav.dart';
import '../../../../bookings/data/repositories/booking_repository.dart';
import '../../../../bookings/data/datasources/booking_api.dart';
import '../../../../../core/network/api_client.dart';

class WorkerBookingsScreen extends StatelessWidget {
  const WorkerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkerBookingsBloc(
        BookingRepository(BookingApi(ApiClient())),
      )..add(LoadWorkerBookings()),
      child: const WorkerBookingsView(),
    );
  }
}

class WorkerBookingsView extends StatelessWidget {
  const WorkerBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Incoming Bookings", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: BlocConsumer<WorkerBookingsBloc, WorkerBookingsState>(
        listener: (context, state) {
          if (state is WorkerBookingUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF14B8A6),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is WorkerBookingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
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
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 24),
                    const Text(
                      "No New Bookings",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "New service requests will appear here",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<WorkerBookingsBloc>().add(LoadWorkerBookings());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: state.bookings.length,
                itemBuilder: (context, index) {
                  final booking = state.bookings[index];
                  return _WorkerBookingCard(booking: booking);
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
      bottomNavigationBar: const WorkerBottomNav(currentIndex: 2),
    );
  }
}

class _WorkerBookingCard extends StatelessWidget {
  final WorkerBookingModel booking;
  const _WorkerBookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    bool isPending = booking.status.toLowerCase() == 'pending';
    bool isAccepted = booking.status.toLowerCase() == 'accepted';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusTag(status: booking.status),
                    if (booking.price > 0)
                      Text(
                        "\$${booking.price.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF14B8A6),
                        ),
                      )
                    else
                      const Text(
                        "---",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  booking.serviceTitle == 'Unavailable Service' 
                      ? 'Booking #${booking.id}' 
                      : booking.serviceTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (booking.customerName != 'Unknown Customer') ...[
                      const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(booking.customerName, style: const TextStyle(color: Colors.black87)),
                      const Spacer(),
                    ] else
                      const Spacer(),
                    const Icon(Icons.event_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "${booking.scheduledDate.day}/${booking.scheduledDate.month}",
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isPending)
            _ActionRow(
              leftLabel: "Reject",
              leftColor: Colors.red[50]!,
              leftTextColor: Colors.red,
              onLeft: () => context.read<WorkerBookingsBloc>().add(RejectBooking(booking.id)),
              rightLabel: "Accept Job",
              rightColor: const Color(0xFF14B8A6),
              onRight: () => context.read<WorkerBookingsBloc>().add(AcceptBooking(booking.id)),
            )
          else if (isAccepted)
            _ActionRow(
              leftLabel: "Help",
              leftColor: Colors.grey[100]!,
              leftTextColor: Colors.grey,
              onLeft: () {},
              rightLabel: "Complete Job",
              rightColor: const Color(0xFFF97316),
              onRight: () => context.read<WorkerBookingsBloc>().add(CompleteBooking(booking.id)),
            ),
        ],
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final String status;
  const _StatusTag({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending': color = Colors.orange; break;
      case 'accepted': color = Colors.green; break;
      case 'completed': color = Colors.blue; break;
      case 'rejected': color = Colors.red; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String leftLabel;
  final Color leftColor;
  final Color leftTextColor;
  final VoidCallback onLeft;
  final String rightLabel;
  final Color rightColor;
  final VoidCallback onRight;

  const _ActionRow({
    required this.leftLabel,
    required this.leftColor,
    required this.leftTextColor,
    required this.onLeft,
    required this.rightLabel,
    required this.rightColor,
    required this.onRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: Text(
                  leftLabel,
                  style: TextStyle(color: leftTextColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Container(height: 30, width: 1, color: Colors.grey[100]),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: onRight,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: rightColor,
                  borderRadius: const BorderRadius.only(bottomRight: Radius.circular(24)),
                ),
                child: Text(
                  rightLabel,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}