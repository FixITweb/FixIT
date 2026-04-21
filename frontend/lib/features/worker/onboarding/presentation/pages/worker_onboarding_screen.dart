import 'package:flutter/material.dart';

class WorkerOnboardingScreen extends StatelessWidget {
  const WorkerOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.build, size: 120, color: Color(0xFF14B8A6)),
            const SizedBox(height: 40),
            const Text(
              "Welcome to FixIT Worker",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              "Start earning by offering your services to local customers",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/worker-home'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Continue to Dashboard",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}