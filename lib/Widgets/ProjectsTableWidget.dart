import 'package:flutter/material.dart';

// 1. Define the Data Model
class ProjectData {
  final String name;
  final String location;
  final String status; // 'Ongoing', 'Pending', or 'Completed'

  ProjectData({
    required this.name,
    required this.location,
    required this.status,
  });
}

// 2. The Reusable Projects Table Widget
class ProjectsTableWidget extends StatelessWidget {
  final List<ProjectData> projects;

  const ProjectsTableWidget({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "My Projects",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
            },
            // Draw a border only if you want the grid lines
            // border: TableBorder(horizontalInside: BorderSide(color: Colors.grey.shade200, width: 1)),
            children: [
              // Header Row
              _buildTableRow([
                "Project Name",
                "Location",
                "Status",
              ], isHeader: true),
              // Data Rows mapped from your list
              ...projects.map(
                (project) => _buildTableRow([
                  project.name,
                  project.location,
                  project.status,
                ]),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "View All >",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      children: cells.map((cellText) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: isHeader
              ? Text(
                  cellText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                )
              : _buildStatusCell(cellText),
        );
      }).toList(),
    );
  }

  // Logic to handle the text vs the status badge
  Widget _buildStatusCell(String text) {
    if (text == "Ongoing" || text == "Pending" || text == "Completed") {
      Color color;
      switch (text) {
        case "Ongoing":
          color = Colors.green;
          break;
        case "Pending":
          color = Colors.orange;
          break;
        case "Completed":
        default:
          color = Colors.teal;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 3, backgroundColor: color),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // Default text for Name and Location
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Color(0xFF333333),
      ),
    );
  }
}

// --- USAGE EXAMPLE ---
/*
  // Define your list
  final List<ProjectData> myProjectList = [
    ProjectData(name: "Skyline Heights", location: "Delhi", status: "Ongoing"),
    ProjectData(name: "Sunrise Plaza", location: "Bangalore", status: "Pending"),
    ProjectData(name: "Green Villa", location: "Mumbai", status: "Completed"),
    ProjectData(name: "Pearl Residency", location: "Pune", status: "Completed"),
  ];

  // Call the widget
  ProjectsTableWidget(projects: myProjectList)
*/
