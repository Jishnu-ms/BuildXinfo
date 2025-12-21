import 'package:flutter/material.dart';

class MetricTiny extends StatelessWidget {
  final String label;
  final String value;
  
  const MetricTiny({
    super.key, 
    required this.label, 
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Ensures it doesn't take extra vertical space
      children: [
        Text(
          value, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label, 
          style: const TextStyle(
            color: Colors.grey, 
            fontSize: 10, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}