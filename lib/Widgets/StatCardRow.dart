import 'package:flutter/material.dart';

// 1. Define the Data Model for easy list passing
class StatCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  StatCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}

// 2. The Main Reusable Widget
class StatCardRow extends StatelessWidget {
  final List<StatCardData> stats;

  const StatCardRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats.asMap().entries.map((entry) {
        int index = entry.key;
        StatCardData data = entry.value;

        return Expanded(
          child: Padding(
            // Adds 20px spacing between cards, but 0 after the last card
            padding: EdgeInsets.only(right: index == stats.length - 1 ? 0 : 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon Container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: data.bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(data.icon, color: data.iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  // Text Content
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          data.title,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          data.value,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// --- USAGE EXAMPLE ---
/*
  StatCardRow(
    stats: [
      StatCardData(
        title: "Total Projects",
        value: "8",
        icon: Icons.folder_open,
        iconColor: Colors.blue,
        bgColor: const Color(0xFFE3F2FD),
      ),
      StatCardData(
        title: "Pending Estimates",
        value: "3",
        icon: Icons.description_outlined,
        iconColor: Colors.orange,
        bgColor: const Color(0xFFFFF3E0),
      ),
      StatCardData(
        title: "Ongoing Estimates",
        value: "5",
        icon: Icons.add_circle_outline,
        iconColor: Colors.green,
        bgColor: const Color(0xFFE8F5E9),
      ),
    ],
  )
*/
