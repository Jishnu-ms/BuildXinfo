import 'package:flutter/material.dart';

class ProjectTable extends StatelessWidget {
  ProjectTable({super.key});

  // --- DEFINED DATA LIST ---
  final List<Map<String, dynamic>> projects = [
    {
      "name": "Green Villa",
      "location": "Mumbai",
      "status": "Ongoing",
      "color": const Color(0xFF4ADE80),
      "hasDot": false,
    },
    {
      "name": "Skyline Heights",
      "location": "Delhi",
      "status": "Completed",
      "color": const Color(0xFF22C55E),
      "hasDot": false,
    },
    {
      "name": "Sunrise Plaza",
      "location": "Bangalore",
      "status": "Pending",
      "color": Colors.orange,
      "hasDot": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        headingTextStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        horizontalMargin: 0,
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Expanded(child: Text("Project Name"))),
          DataColumn(label: Expanded(child: Text("Location"))),
          DataColumn(label: Expanded(child: Text("Status"))),
        ],
        // Dynamically generating rows from the list
        rows: projects.map((project) {
          return _projectRow(
            project['name'],
            project['location'],
            project['status'],
            project['color'],
            hasDot: project['hasDot'],
          );
        }).toList(),
      ),
    );
  }

  // Your exact helper method logic preserved
  DataRow _projectRow(
    String name,
    String loc,
    String status,
    Color color, {
    bool hasDot = false,
  }) {
    return DataRow(
      cells: [
        DataCell(
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataCell(Text(loc)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasDot) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
