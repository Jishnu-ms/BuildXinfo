import 'package:flutter/material.dart';

class CustomSidebarButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;

  const CustomSidebarButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.color = Colors.grey, // Default color matching image
    this.borderColor = const Color(0xFFF1F1F1), // Default light border
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: color, size: 20),
        title: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
