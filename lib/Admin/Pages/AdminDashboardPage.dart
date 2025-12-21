import 'package:buildxinfo/Widgets/ActivityRow.dart';
import 'package:buildxinfo/Widgets/DonutChart.dart';
import 'package:buildxinfo/Widgets/MainChart.dart';
import 'package:buildxinfo/Widgets/MetricTiny.dart';
import 'package:buildxinfo/Widgets/ProjectTable.dart';
import 'package:buildxinfo/Widgets/StatCard.dart';
import 'package:buildxinfo/Widgets/_sectionHeader.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AdminDashboardPage extends StatelessWidget {
  AdminDashboardPage({super.key});

  // --- DEFINED DATA LISTS ---

  final List<Map<String, dynamic>> statsData = [
    {
      "icon": LucideIcons.calculator,
      "label": "Total Estimates",
      "value": "1,250",
      "isSuccess": false,
    },
    {
      "icon": LucideIcons.home,
      "label": "Active Projects",
      "value": "18",
      "isSuccess": false,
    },
    {
      "icon": LucideIcons.users,
      "label": "Registred Users",
      "value": "342",
      "isSuccess": false,
    },
    {
      "icon": LucideIcons.checkCircle,
      "label": "Model Accuracy",
      "value": "87.5 %",
      "isSuccess": true,
    },
  ];

  final List<Map<String, dynamic>> performanceMetrics = [
    {"label": "MAE", "value": "₹ 22,508"},
    {"label": "MSE", "value": "1.15"},
    {"label": "RMSE", "value": ".42"},
  ];

  final List<Map<String, dynamic>> activities = [
    {
      "user": "Amit Sharma",
      "action": "generated a new estimate",
      "time": "10 mins ago",
      "color": Colors.blue,
    },
    {
      "user": "Priya Mehta",
      "action": "added a new project",
      "time": "1 hour ago",
      "color": Colors.redAccent,
    },
    {
      "user": "Rahul Verma",
      "action": "updated the model",
      "time": "2 days ago",
      "color": Colors.blue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F4F8),
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Top Stats Row (Generated from List)
            Row(
              children: statsData.map((data) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: data == statsData.last ? 0 : 16,
                    ),
                    child: StatCard(
                      icon: data['icon'],
                      label: data['label'],
                      value: data['value'],
                      isSuccess: data['isSuccess'],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 2. Middle Row (Charts)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildDashboardCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(
                          title: "Cost Estimation Stats",
                          showLegend: true,
                        ),
                        const Text(
                          "Predicted vs Actual Costs",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          height: 200,
                          child: MainChart(), // Changed 'MainCh' to 'MainChart'
                        ),
                        const Center(
                          child: Text(
                            "Recent Estimates",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: _buildDashboardCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Model Performance",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const SizedBox(height: 180, child: DonutChart()),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: performanceMetrics
                              .map(
                                (m) => MetricTiny(
                                  label: m['label'],
                                  value: m['value'],
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Bottom Row (Table and Activity)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildDashboardCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Recent Projects",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ProjectTable(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              "View All",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: _buildDashboardCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "User Activity",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...activities.map(
                          (act) => ActivityRow(
                            user: act['user'],
                            action: act['action'],
                            time: act['time'],
                            color: act['color'],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {},
                            child: const Text(
                              "View Logs",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Wrapper for consistency across all dashboard cards
  Widget _buildDashboardCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
