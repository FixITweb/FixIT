import 'package:flutter/material.dart';
import '../../../dashboard/presentation/widgets/worker_bottom_nav.dart';

class WorkerNotificationsScreen extends StatelessWidget {
  const WorkerNotificationsScreen({super.key});

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
              title: Text("New booking request from Sarah"),
              subtitle: Text("2 minutes ago"),
              trailing: Icon(Icons.circle, size: 8, color: Colors.teal),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.star, color: Colors.amber),
              title: Text("You received a 5-star review"),
              subtitle: Text("1 hour ago"),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text("Booking confirmed with Mike Chen"),
              subtitle: Text("Yesterday"),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.payment, color: Colors.green),
              title: Text("Payment received"),
              subtitle: Text("You earned \$75 from sink repair job"),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.schedule, color: Colors.orange),
              title: Text("Upcoming job reminder"),
              subtitle: Text("Kitchen repair tomorrow at 10:00 AM"),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const WorkerBottomNav(currentIndex: 3),
    );
  }
}