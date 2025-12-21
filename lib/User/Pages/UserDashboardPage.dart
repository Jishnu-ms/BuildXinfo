import 'package:buildxinfo/Widgets/ProfileHeader.dart';
import 'package:buildxinfo/Widgets/ProjectsTableWidget.dart';
import 'package:buildxinfo/Widgets/RecentEstimatesWidget.dart';
import 'package:buildxinfo/Widgets/StatCardRow.dart';
import 'package:flutter/material.dart';

class Userdashboardpage extends StatelessWidget {
  Userdashboardpage({super.key});

  final List<ProjectData> myProjectList = [
    ProjectData(name: "Skyline Heights", location: "Delhi", status: "Ongoing"),
    ProjectData(
      name: "Sunrise Plaza",
      location: "Bangalore",
      status: "Pending",
    ),
    ProjectData(name: "Green Villa", location: "Mumbai", status: "Completed"),
    ProjectData(name: "Pearl Residency", location: "Pune", status: "Completed"),
  ];

  final List<EstimateData> myEstimates = [
    EstimateData(
      title: "SuNRleze",
      date: "5th June, 2024",
      price: "₹ 90.2 Lakhs",
    ),
    EstimateData(
      title: "Skyline Heights",
      date: "29th May, 2024",
      price: "₹ 3.4 Crores",
    ),
    EstimateData(
      title: "Pearl Residency",
      date: "17th May, 2024",
      price: "₹ 1.0 Crore",
    ),
    EstimateData(
      title: "Green Villa",
      date: "10th May, 2024",
      price: "₹ 68.5 Lakhs",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F4F8), // Background light blue-grey
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(
              userData: UserProfileData(
                name: "Priya Mehta",
                role: "Project Manager",
                email: "priyalocation@orcail.com",
                imageUrl: "https://i.pravatar.cc/150?u=priya",
              ),
            ),
            SizedBox(height: 24),
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
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ProjectsTableWidget(projects: myProjectList),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: RecentEstimatesWidget(estimates: myEstimates),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
