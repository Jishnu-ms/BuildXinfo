import 'package:flutter/material.dart';

class AdminProjectsPage extends StatelessWidget {
  const AdminProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent, // Keeps the main layout background
      body: Center(
        child: Text(
          "ADMIN PROJECTS PAGE\n(List of active builds)",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}