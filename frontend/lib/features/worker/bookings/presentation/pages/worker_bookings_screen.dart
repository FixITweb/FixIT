import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/worker_bookings_bloc.dart';
import '../bloc/worker_bookings_event.dart';
import '../bloc/worker_bookings_state.dart';
import '../../data/models/worker_booking_model.dart';
import '../../data/datasources/worker_bookings_api.dart';
import '../../data/repositories/worker_bookings_repository.dart';
import '../../../dashboard/presentation/widgets/worker_bottom_nav.dart';
import '../../../../../core/network/api_client.dart';

class WorkerBookingsScreen extends StatelessWidget {
  const WorkerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkerBookingsBloc(
        WorkerBookingsRepository(WorkerBookingsApi(ApiClient())),
      )..add(LoadWorkerBookings()),
      child: const WorkerBookingsView(),
    );
  }
}

class WorkerBookingsView extends StatefulWidget {
  const WorkerBookingsView({super.key});

  @override
  State<WorkerBookingsView> createState() => _WorkerBookingsViewState();
}

class _WorkerBookingsViewState extends State<WorkerBookingsView> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Incoming Bookings"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<WorkerBookingsBloc>().add(LoadWorkerBookings()),
          ),
        ],
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
                    onPressed: () => context
                        .read<WorkerBookingsBloc>()
                        .add(LoadWorkerBookings()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is WorkerBookingsLoaded) {
            if (state.bookings.isEmpty) {
              final colorScheme = Theme.of(context).colorScheme;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 80, color: colorScheme.outlineVariant),
                    const SizedBox(height: 24),
                    Text(
                      "No New Bookings",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "New service requests will appear here",
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }

            // Filter bookings based on selected filter
            final filteredBookings = _selectedFilter == 'all'
                ? state.bookings
                : state.bookings
                    .where((b) => b.status.toLowerCase() == _selectedFilter)
                    .toList();

            return RefreshIndicator(
              onRefresh: () async {
                context.read<WorkerBookingsBloc>().add(LoadWorkerBookings());
              },
              child: Column(
                children: [
                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All',
                          isSelected: _selectedFilter == 'all',
                          onTap: () => setState(() => _selectedFilter = 'all'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Pending',
                          isSelected: _selectedFilter == 'pending',
                          onTap: () =>
                              setState(() => _selectedFilter = 'pending'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Accepted',
                          isSelected: _selectedFilter == 'accepted',
                          onTap: () =>
                              setState(() => _selectedFilter = 'accepted'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Completed',
                          isSelected: _selectedFilter == 'completed',
                          onTap: () =>
                              setState(() => _selectedFilter = 'completed'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filteredBookings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox_outlined,
                                    size: 64,
                                    color: Theme.of(context).colorScheme.outlineVariant),
                                const SizedBox(height: 16),
                                Text(
                                  'No $_selectedFilter bookings',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: filteredBookings.length,
                            itemBuilder: (context, index) {
                              final booking = filteredBookings[index];
                              return _WorkerBookingCard(booking: booking);
                            },
                          ),
                  ),
                ],
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    bool isPending = booking.status.toLowerCase() == 'pending';
    bool isAccepted = booking.status.toLowerCase() == 'accepted';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? colorScheme.outlineVariant.withOpacity(0.35)
              : colorScheme.outlineVariant.withOpacity(0.6),
        ),
        boxShadow: isDark
            ? []
            : [
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
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      )
                    else
                      Text(
                        "---",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.outline,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  booking.serviceTitle == 'Unavailable Service'
                      ? 'Booking #${booking.id}'
                      : booking.serviceTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (booking.customerName != 'Unknown Customer') ...[
                      Icon(Icons.person_outline,
                          size: 16, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        booking.customerName,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (booking.customerPhone != null &&
                        booking.customerPhone!.isNotEmpty) ...[
                      Icon(Icons.phone_outlined,
                          size: 16, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          booking.customerPhone!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ] else
                      const Spacer(),
                    Icon(Icons.event_outlined,
                        size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      "${booking.scheduledDate.day}/${booking.scheduledDate.month}",
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isPending)
            _ActionRow(
              leftLabel: "Reject",
              leftDestructive: true,
              onLeft: () => context
                  .read<WorkerBookingsBloc>()
                  .add(RejectBooking(booking.id)),
              rightLabel: "Accept Job",
              onRight: () => context
                  .read<WorkerBookingsBloc>()
                  .add(AcceptBooking(booking.id)),
            )
          else if (isAccepted)
            _ActionRow(
              leftLabel: "Help",
              leftDestructive: false,
              onLeft: () {},
              rightLabel: "Complete Job",
              onRight: () => context
                  .read<WorkerBookingsBloc>()
                  .add(CompleteBooking(booking.id)),
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
      case 'pending':
        color = Colors.orange;
        break;
      case 'accepted':
        color = Colors.green;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status,
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String leftLabel;
  final bool leftDestructive;
  final VoidCallback onLeft;
  final String rightLabel;
  final VoidCallback onRight;

  const _ActionRow({
    required this.leftLabel,
    required this.leftDestructive,
    required this.onLeft,
    required this.rightLabel,
    required this.onRight,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onLeft,
              style: leftDestructive
                  ? OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                    )
                  : null,
              child: Text(leftLabel),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: onRight,
              child: Text(rightLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : (isDark ? colorScheme.surfaceContainer : Colors.white),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : (isDark
                    ? colorScheme.outlineVariant.withOpacity(0.5)
                    : colorScheme.outlineVariant),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
