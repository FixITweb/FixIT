import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final preferences = await SharedPreferences.getInstance();
    final hasSeenOnboarding =
        preferences.getBool('has_seen_onboarding') ?? false;
    final token = preferences.getString('token');
    final role = preferences.getString('role');

    if (!mounted) return;

    // Auto-login: If user has a valid saved session, bypass login screen
    if (token != null && token.isNotEmpty && role != null && role.isNotEmpty) {
      if (role == 'worker') {
        Navigator.pushReplacementNamed(context, '/worker-home');
      } else {
        Navigator.pushReplacementNamed(context, '/customer-home');
      }
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      hasSeenOnboarding ? '/login' : '/onboarding',
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build, size: 100, color: Color(0xFF14B8A6)),
            SizedBox(height: 20),
            Text(
              "FixIT",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF14B8A6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
