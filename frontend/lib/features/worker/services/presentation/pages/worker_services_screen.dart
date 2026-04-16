import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/worker_services_bloc.dart';
import '../bloc/worker_services_event.dart';
import '../bloc/worker_services_state.dart';
import '../../../dashboard/presentation/widgets/worker_bottom_nav.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../services/data/datasources/services_api.dart';
import '../../../../services/data/repositories/services_repository.dart';
import '../../../../services/data/models/service_model.dart';

class WorkerServicesScreen extends StatelessWidget {
  const WorkerServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkerServicesBloc(
        ServiceRepository(ServiceApi(ApiClient())),
      )..add(LoadWorkerServices()),
      child: const WorkerServicesView(),
    );
  }
}

class WorkerServicesView extends StatelessWidget {
  const WorkerServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Services"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<WorkerServicesBloc>().add(LoadWorkerServices()),
          ),
        ],
      ),
      body: BlocConsumer<WorkerServicesBloc, WorkerServicesState>(
        listener: (context, state) {
          if (state is WorkerServiceAdded ||
              state is WorkerServiceUpdated ||
              state is WorkerServiceDeleted) {
            final msg = state is WorkerServiceAdded
                ? (state as WorkerServiceAdded).message
                : state is WorkerServiceUpdated
                    ? (state as WorkerServiceUpdated).message
                    : (state as WorkerServiceDeleted).message;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.green),
            );
          } else if (state is WorkerServicesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is WorkerServicesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WorkerServicesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<WorkerServicesBloc>().add(LoadWorkerServices()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is WorkerServicesLoaded) {
            if (state.services.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.work_outline, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      "No Services Yet",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Add your first service to start earning",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showServiceDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Service'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<WorkerServicesBloc>().add(LoadWorkerServices()),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.services.length,
                itemBuilder: (context, index) {
                  final service = state.services[index];
                  return _ServiceCard(
                    service: service,
                    onEdit: () => _showServiceDialog(context, service: service),
                    onDelete: () => _confirmDelete(context, service),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showServiceDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Service'),
      ),
      bottomNavigationBar: const WorkerBottomNav(currentIndex: 1),
    );
  }

  void _showServiceDialog(BuildContext context, {ServiceModel? service}) {
    final isEdit = service != null;
    final titleCtrl = TextEditingController(text: service?.title ?? '');
    final priceCtrl = TextEditingController(
        text: service != null ? service.price.toStringAsFixed(0) : '');
    final descCtrl = TextEditingController(text: service?.description ?? '');
    String selectedCategory = service?.category ?? 'Plumbing';

    final categories = [
      'Plumbing', 'Electrical', 'Cleaning', 'Carpentry',
      'Painting', 'Moving', 'Gardening', 'Appliance Repair', 'Other'
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(isEdit ? 'Edit Service' : 'Add New Service'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Service Title',
                    hintText: 'e.g., Sink Repair',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedCategory = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price (\$)',
                    hintText: 'e.g., 50',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe your service...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty ||
                    priceCtrl.text.isEmpty ||
                    descCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }
                final price = double.tryParse(priceCtrl.text) ?? 0.0;
                if (isEdit) {
                  context.read<WorkerServicesBloc>().add(UpdateWorkerService(
                        id: service!.id,
                        title: titleCtrl.text,
                        category: selectedCategory,
                        price: price,
                        description: descCtrl.text,
                      ));
                } else {
                  context.read<WorkerServicesBloc>().add(AddWorkerService(
                        title: titleCtrl.text,
                        category: selectedCategory,
                        price: price,
                        description: descCtrl.text,
                      ));
                }
                Navigator.pop(dialogCtx);
              },
              child: Text(isEdit ? 'Update' : 'Add Service'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ServiceModel service) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Delete "${service.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<WorkerServicesBloc>().add(DeleteWorkerService(service.id));
              Navigator.pop(dialogCtx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF14B8A6),
          child: Text(
            service.category.substring(0, 1).toUpperCase(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        title: Text(
          service.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '\$${service.price.toStringAsFixed(0)} • ${service.category}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text(' ${service.rating.toStringAsFixed(1)}'),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              service.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(children: [
                Icon(Icons.edit, size: 18),
                SizedBox(width: 8),
                Text('Edit'),
              ]),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                Icon(Icons.delete, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
