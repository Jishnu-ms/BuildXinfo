import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool showLegend;

  const SectionHeader({
    super.key,
    required this.title,
    this.showLegend = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        if (showLegend)
          Row(
            children: [
              _legendItem("Predicted", Colors.blue),
              const SizedBox(width: 10),
              _legendItem("Actual", Colors.orange),
            ],
          ),
      ],
    );
  }

  // Keeping your exact helper method inside the class
  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
