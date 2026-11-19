import 'package:flutter/material.dart';

class WorkerBottomNav extends StatelessWidget {
  final int currentIndex;

  const WorkerBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/worker-home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/worker-services');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/worker-bookings');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/worker-profile');
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.space_dashboard_outlined),
          selectedIcon: Icon(Icons.space_dashboard_rounded),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.work_outline_rounded),
          selectedIcon: Icon(Icons.work_rounded),
          label: 'Services',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month_rounded),
          label: 'Bookings',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
