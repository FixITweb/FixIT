import 'package:flutter/material.dart';
import '../models/service_model.dart';

class ServiceCard extends StatelessWidget {
  final Service service;

  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(service.title),
        subtitle: Text(service.category),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("\$${service.price}"),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                Text(service.rating.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}