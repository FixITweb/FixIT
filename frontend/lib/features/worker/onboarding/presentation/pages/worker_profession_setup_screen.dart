import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/data/repositories/services_repository.dart';
import '../../../../services/data/datasources/services_api.dart';
import '../../../../../core/network/api_client.dart';

class WorkerProfessionSetupScreen extends StatefulWidget {
  const WorkerProfessionSetupScreen({super.key});

  @override
  State<WorkerProfessionSetupScreen> createState() => _WorkerProfessionSetupScreenState();
}

class _WorkerProfessionSetupScreenState extends State<WorkerProfessionSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _selectedCategory = 'Plumbing';
  bool _isLoading = false;

  final List<String> _categories = [
    'Plumbing',
    'Electrical',
    'Cleaning',
    'Carpentry',
    'Painting',
    'Gardening',
    'Appliance Repair',
    'HVAC',
    'Roofing',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.work, size: 80, color: Color(0xFF14B8A6)),
                const SizedBox(height: 20),
                const Text(
                  "Set Up Your First Service",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Tell customers what you do best. You can add more services later.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Service Title
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Service Title *',
                            hintText: 'e.g., Professional Plumbing Repair',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a service title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Category Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category *',
                            border: OutlineInputBorder(),
                          ),
                          items: _categories.map((category) {
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
                        const SizedBox(height: 16),
                        
                        // Price
                        TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Price (\$) *',
                            hintText: 'e.g., 75',
                            border: OutlineInputBorder(),
                            prefixText: '\$ ',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description *',
                            hintText: 'Describe your service in detail...',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () {
                          Navigator.pushReplacementNamed(context, '/worker-home');
                        },
                        child: const Text('Skip for Now'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createService,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Create Service'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ServiceRepository(ServiceApi(ApiClient()));
      
      await repository.createService(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        price: double.parse(_priceController.text),
        latitude: 40.7128, // Default location - should be user's location
        longitude: -74.0060,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pushReplacementNamed(context, '/worker-home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create service: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}