import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/create_request_bloc.dart';
import '../bloc/create_request_event.dart';
import '../bloc/create_request_state.dart';
import '../../../../../core/network/api_client.dart';
import 'package:frontend/core/utils/location_helper.dart';
import '../../data/datasources/job_request_api.dart';
import '../../data/repositories/job_request_repository.dart';
import '../../../../services/data/repositories/services_repository.dart';
import '../../../../services/data/datasources/services_api.dart';

class CreateRequestScreen extends StatelessWidget {
  const CreateRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateRequestBloc(
        repository: JobRequestRepository(JobRequestApi(ApiClient())),
        serviceRepository: ServiceRepository(ServiceApi(ApiClient())),
      )..add(LoadCategories()),
      child: const CreateRequestView(),
    );
  }
}

class CreateRequestView extends StatefulWidget {
  const CreateRequestView({super.key});

  @override
  State<CreateRequestView> createState() => _CreateRequestViewState();
}

class _CreateRequestViewState extends State<CreateRequestView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  String? _selectedCategory;
  List<String> _dynamicCategories = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Job Request'),
        elevation: 0,
      ),
      body: BlocListener<CreateRequestBloc, CreateRequestState>(
        listener: (context, state) {
          if (state is CategoriesLoaded) {
            setState(() {
              _dynamicCategories = state.categories;
              if (_dynamicCategories.isNotEmpty && _selectedCategory == null) {
                _selectedCategory = _dynamicCategories.first;
              }
            });
          } else if (state is CreateRequestSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Request posted! You\'ll be notified when workers are available.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            Navigator.pop(context);
          } else if (state is CreateRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<CreateRequestBloc, CreateRequestState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card
                    Card(
                      color: const Color(0xFF14B8A6).withOpacity(0.1),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Color(0xFF14B8A6)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Post your request and get notified when matching services become available!',
                                style: TextStyle(fontSize: 14),
                                ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title Field
                    const Text(
                      'Service Title',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Fix leaking sink',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Category Dropdown
                    const Text(
                      'Category',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _dynamicCategories.isEmpty 
                      ? const Center(child: LinearProgressIndicator())
                      : DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.category),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: _dynamicCategories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                          },
                        ),
                    const SizedBox(height: 20),

                    // Description Field
                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Describe what you need...',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Budget Field
                    const Text(
                      'Budget (Optional)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter your budget',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: state is CreateRequestLoading || _selectedCategory == null
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    // Automatically fetch location on click
                                    final position = await LocationHelper.getCurrentPosition();
                                    
                                    if (mounted) {
                                      context.read<CreateRequestBloc>().add(
                                            SubmitRequest(
                                              title: _titleController.text,
                                              description: _descriptionController.text,
                                              category: _selectedCategory!,
                                              latitude: position.latitude,
                                              longitude: position.longitude,
                                              budget: double.tryParse(_budgetController.text) ?? 0.0,
                                            ),
                                          );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('📍 Location Error: $e'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF14B8A6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: state is CreateRequestLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Post Request',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
