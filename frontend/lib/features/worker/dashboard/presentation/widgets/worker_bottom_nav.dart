import 'package:flutter/material.dart';

class WorkerBottomNav extends StatelessWidget {
  final int currentIndex;
  
  const WorkerBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF14B8A6),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/worker-dashboard');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/worker-services');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/worker-bookings');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/worker-notifications');
            break;
          case 4:
            Navigator.pushReplacementNamed(context, '/worker-profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.work),
          label: 'Services',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}