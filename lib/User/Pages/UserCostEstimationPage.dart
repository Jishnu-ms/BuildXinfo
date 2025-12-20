import 'package:flutter/material.dart';

class UserCostEstimationPage extends StatelessWidget {
  const UserCostEstimationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "USER COST ESTIMATION PAGE\n(Early-stage prediction)",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }
}