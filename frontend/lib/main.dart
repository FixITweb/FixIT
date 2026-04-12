import 'package:flutter/material.dart';
import 'features/services/screens/service_list_screen.dart';

void main() {
  runApp(const FixITApp());
}

class FixITApp extends StatelessWidget {
  const FixITApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FixIT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ServiceListScreen(),
    );
  }
}