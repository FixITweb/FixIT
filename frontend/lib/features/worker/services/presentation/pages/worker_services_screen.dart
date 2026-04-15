import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/worker_services_bloc.dart';
import '../bloc/worker_services_event.dart';
import '../bloc/worker_services_state.dart';
import '../../../dashboard/presentation/widgets/worker_bottom_nav.dart';

class WorkerServicesScreen extends StatelessWidget {
  const WorkerServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkerServicesBloc()..add(LoadWorkerServices()),
      child: const WorkerServicesView(),
    );
  }
}

class WorkerServicesView extends StatelessWidget {
  const WorkerServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Services")),
      body: BlocConsumer<WorkerServicesBloc, WorkerServicesState>(
        listener: (context, state) {
          if (state is WorkerServiceAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is WorkerServicesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
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
                  Text('Error: ${state.message}'),
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
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.work_outline, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "No Services Yet",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text("Add your first service to start earning"),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.services.length,
              itemBuilder: (context, index) {
                final service = state.services[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(service.title),
                    subtitle: Text("\$${service.price}/hour • ${service.isActive ? 'Active' : 'Inactive'}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: service.isActive,
                          onChanged: (_) => context.read<WorkerServicesBloc>().add(
                            ToggleServiceStatus(service.id),
                          ),
                        ),
                        Icon(
                          service.isActive ? Icons.check_circle : Icons.pause_circle,
                          color: service.isActive ? Colors.green : Colors.grey,
                        ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddServiceDialog(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const WorkerBottomNav(currentIndex: 1),
    );
  }

  void _showAddServiceDialog(BuildContext context) {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Plumbing';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add New Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Service Title'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'Plumbing', child: Text('Plumbing')),
                  DropdownMenuItem(value: 'Electrical', child: Text('Electrical')),
                  DropdownMenuItem(value: 'Cleaning', child: Text('Cleaning')),
                  DropdownMenuItem(value: 'Carpentry', child: Text('Carpentry')),
                ],
                onChanged: (value) => selectedCategory = value!,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price per hour (\$)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && priceController.text.isNotEmpty) {
                context.read<WorkerServicesBloc>().add(
                  AddWorkerService(
                    title: titleController.text,
                    category: selectedCategory,
                    price: double.tryParse(priceController.text) ?? 0.0,
                    description: descriptionController.text,
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add Service'),
          ),
        ],
      ),
    );
  }
}