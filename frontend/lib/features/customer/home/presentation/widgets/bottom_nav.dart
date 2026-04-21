import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  
  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF10B981),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/customer-home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/requests');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/notifications');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/bookings');
            break;
          case 4:
            Navigator.pushReplacementNamed(context, '/customer-profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'Requests',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}