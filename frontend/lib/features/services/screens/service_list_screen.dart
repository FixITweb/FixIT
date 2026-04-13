import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../widgets/service_card.dart';
class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  List<Service> services = [
    Service(
      id: 1,
      title: "Plumber",
      description: "Fix pipes",
      category: "Plumbing",
      price: 50,
      rating: 4.5,
    ),
    Service(
      id: 2,
      title: "Electrician",
      description: "Fix wiring",
      category: "Electrical",
      price: 70,
      rating: 4.2,
    ),
    Service(
      id: 3,
      title: "Cleaner",
      description: "House cleaning",
      category: "Cleaning",
      price: 30,
      rating: 4.8,
    ),
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    List<Service> filteredServices = services
        .where((service) =>
            service.title.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Services"),
      ),
      
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search services...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          // 📋 Service List
          Expanded(
            child: ListView.builder(
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                return ServiceCard(service: filteredServices[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}