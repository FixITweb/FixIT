import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;

  final List<Map<String, dynamic>> slides = [
    {
      "icon": Icons.location_on,
      "title": "Find Services Near You",
      "desc": "Discover trusted workers instantly"
    },
    {
      "icon": Icons.star,
      "title": "Book Trusted Professionals",
      "desc": "See ratings and reviews before booking"
    },
    {
      "icon": Icons.flash_on,
      "title": "Get Instant Matches",
      "desc": "Post requests and get quick offers"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              onPageChanged: (val) => setState(() => currentPage = val),
              itemCount: slides.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      slides[index]['icon'] as IconData,
                      size: 120,
                      color: const Color(0xFF14B8A6),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      slides[index]['title'],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        slides[index]['desc'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to login - you can implement navigation later
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text(
                currentPage == slides.length - 1 ? "Get Started" : "Next",
              ),
            ),
          ),
        ],
      ),
    );
  }
}