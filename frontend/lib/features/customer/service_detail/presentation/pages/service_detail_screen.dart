import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/service_detail_bloc.dart';
import '../bloc/service_detail_event.dart';
import '../bloc/service_detail_state.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../services/data/datasources/services_api.dart';
import '../../../../services/data/repositories/services_repository.dart';
import '../../../../services/data/models/service_model.dart';
import '../../../../bookings/data/repositories/booking_repository.dart';
import '../../../../bookings/data/datasources/booking_api.dart';
import '../../../../../shared/widgets/location_map_card.dart';

class ServiceDetailScreen extends StatelessWidget {
  final String serviceId;
  
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    return BlocProvider(
      create: (context) => ServiceDetailBloc(
        repository: ServiceRepository(ServiceApi(apiClient)),
        bookingRepository: BookingRepository(BookingApi(apiClient)),
      )..add(LoadServiceDetail(serviceId)),
      child: const ServiceDetailView(),
    );
  }
}

class ServiceDetailView extends StatelessWidget {
  const ServiceDetailView({super.key});

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF14B8A6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Color(0xFF14B8A6), size: 64),
              ),
              const SizedBox(height: 24),
              const Text(
                'Booking Successful!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your service request has been sent. The worker will be notified immediately.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pushReplacementNamed(context, '/bookings');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14B8A6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('View Bookings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Maybe Later', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ServiceDetailBloc, ServiceDetailState>(
        listener: (context, state) {
          if (state is BookingSuccess) {
            _showSuccessDialog(context);
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<ServiceDetailBloc, ServiceDetailState>(
          builder: (context, state) {
            if (state is ServiceDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ServiceDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            }

            // Extract service from state
            ServiceModel? service;
            if (state is ServiceDetailLoaded) service = state.service;
            if (state is BookingInProgress) service = state.service;
            if (state is BookingSuccess) service = state.service;
            if (state is BookingError) service = state.service;

            if (service == null) return const Center(child: Text('No data'));

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Header with gradient
                  Container(
                    height: 280,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF14B8A6), Color(0xFFF97316)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.share, color: Colors.white),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              service.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                service.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Worker Info Card
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: const Color(0xFF14B8A6),
                                  child: Text(
                                    service.worker.username.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 28,
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
                                        service.worker.username,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 18),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${service.rating.toStringAsFixed(1)} rating',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF14B8A6).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '\$${service.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF14B8A6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          service.description,
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.5),
                        ),
                        const SizedBox(height: 24),
                        LocationMapCard(
                          latitude: service.latitude,
                          longitude: service.longitude,
                          workerName: service.worker.username,
                          address: 'Service Location',
                          distance: service.distance,
                        ),
                        const SizedBox(height: 24),
                        
                        // Book Now Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: (state is BookingInProgress)
                                ? null
                                : () {
                                    context.read<ServiceDetailBloc>().add(BookService(service!.id));
                                  },
                            icon: (state is BookingInProgress)
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.calendar_today),
                            label: Text(
                              (state is BookingInProgress) ? 'Processing...' : 'Book Now - \$${service.price.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF14B8A6),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
