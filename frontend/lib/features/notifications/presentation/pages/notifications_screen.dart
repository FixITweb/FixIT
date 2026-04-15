import 'package:flutter/material.dart';
import '../../../customer/home/presentation/widgets/bottom_nav.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.notifications_active, color: Colors.teal),
              title: Text("John accepted your booking"),
              subtitle: Text("2 minutes ago"),
              trailing: Icon(Icons.circle, size: 8, color: Colors.teal),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.star, color: Colors.amber),
              title: Text("New review received"),
              subtitle: Text("5 stars from Sarah"),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.payment, color: Colors.green),
              title: Text("Payment completed"),
              subtitle: Text("Service payment of \$75 processed"),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.schedule, color: Colors.orange),
              title: Text("Upcoming appointment"),
              subtitle: Text("House cleaning tomorrow at 10:00 AM"),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }
}