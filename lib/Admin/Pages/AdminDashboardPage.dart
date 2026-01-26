



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';

 class ActivityList extends StatelessWidget {
  const ActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collectionGroup('projects')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Text(
            "No recent activity",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          );
        }

        // ✅ Sort safely in Dart (NO Firestore orderBy bugs)
        docs.sort((a, b) {
          final ta =
              (a.data() as Map<String, dynamic>)['updatedAt'] as Timestamp?;
          final tb =
              (b.data() as Map<String, dynamic>)['updatedAt'] as Timestamp?;

          if (ta == null && tb == null) return 0;
          if (ta == null) return 1;
          if (tb == null) return -1;
          return tb.compareTo(ta);
        });

        final recent = docs.take(5).toList();

        return Column(
          children: recent.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final user = data['updatedBy'] ?? 'User';
            final project = data['projectName'] ?? 'Project';
            final status = data['status'] ?? 'updated';

            return ActivityRow(
              user: user,
              action: "updated $project ($status)",
              time: _timeAgo(data['updatedAt']),
              color: _activityColor(status),
            );
          }).toList(),
        );
      },
    );
  }

  // ⏱ Time formatter
   String _timeAgo(Timestamp? ts) {
    if (ts == null) return '';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    return '${diff.inDays} days ago';
  }

  // 🎨 Status-based color
  static Color _activityColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green;
      case "Ongoing":
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}


class AdminDashboardPage extends StatelessWidget {
  AdminDashboardPage({super.key});

  // --- DEFINED DATA LISTS ---



  final List<Map<String, dynamic>> performanceMetrics = [
    {"label": "MAE", "value": "₹ 22,508"},
    {"label": "MSE", "value": "1.15"},
    {"label": "RMSE", "value": ".42"},
  ];

  
Widget buildStatsRow() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collectionGroup('projects')
        .snapshots(),
    builder: (context, projectSnap) {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .snapshots(),
        builder: (context, userSnap) {
          if (!projectSnap.hasData || !userSnap.hasData) {
            return const Row(
              children: [
                Expanded(child: StatCard(icon: Icons.hourglass_empty, label: "", value: "")),
                SizedBox(width: 16),
                Expanded(child: StatCard(icon: Icons.hourglass_empty, label: "", value: "")),
                SizedBox(width: 16),
                Expanded(child: StatCard(icon: Icons.hourglass_empty, label: "", value: "")),
                SizedBox(width: 16),
                Expanded(child: StatCard(icon: Icons.hourglass_empty, label: "", value: "")),
              ],
            );
          }

          final projects = projectSnap.data!.docs;
          final users = userSnap.data!.docs;

          final totalProjects = projects.length;

          final activeProjects = projects.where((p) {
            final status =
                (p.data() as Map<String, dynamic>)['status'] ?? 'Pending';
            return status != 'Completed';
          }).length;

          final totalUsers = users.length;

          return Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: LucideIcons.calculator,
                  label: "Total Estimates",
                  value: totalProjects.toString(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  icon: LucideIcons.home,
                  label: "Active Projects",
                  value: activeProjects.toString(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  icon: LucideIcons.users,
                  label: "Registered Users",
                  value: totalUsers.toString(),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: StatCard(
                  icon: LucideIcons.checkCircle,
                  label: "Model Accuracy",
                  value: "87.5 %",
                  isSuccess: true,
                ),
              ),
            ],
          );
        },
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F4F8),
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Top Stats Row (Generated from List)
          buildStatsRow(),

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
                        const ActivityList(),

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



class ActivityRow extends StatelessWidget {
  final String user;
  final String action;
  final String time;
  final Color color;

  const ActivityRow({
    super.key,
    required this.user,
    required this.action,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.check, size: 12, color: Colors.white),
          ),
          const SizedBox(width: 10),
          // User and Action Text
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 12),
                children: [
                  TextSpan(
                    text: "$user ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: action,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          // Timestamp
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }
}





class DonutChart extends StatelessWidget {
  const DonutChart({super.key});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 5,
        centerSpaceRadius: 50,
        sections: [
          PieChartSectionData(
            color: Colors.blue,
            value: 60,
            showTitle: false,
            radius: 20,
          ),
          PieChartSectionData(
            color: Colors.teal,
            value: 25,
            showTitle: false,
            radius: 20,
          ),
          PieChartSectionData(
            color: Colors.orange,
            value: 15,
            showTitle: false,
            radius: 20,
          ),
        ],
      ),
    );
  }
}





class MainChart extends StatelessWidget {
  MainChart({super.key});

  // --- DEFINED DATA LISTS ---
  final List<double> actualCosts = [1.5, 3.0, 2.5, 1.8, 4.2, 2.8, 3.5, 4.0];
  final List<FlSpot> predictedSpots = const [
    FlSpot(0, 1.2),
    FlSpot(1, 2.8),
    FlSpot(2, 2.1),
    FlSpot(3, 3.2),
    FlSpot(4, 3.9),
    FlSpot(5, 3.4),
    FlSpot(6, 4.8),
    FlSpot(7, 5.5),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. The Bar Chart (Actual Costs - Orange Bars)
        BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 6,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
            ),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: actualCosts.asMap().entries.map((e) {
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value,
                    color: Colors.orange.shade400,
                    width: 16,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),

        // 2. The Line Chart (Predicted Costs - Blue Line) layered on top
        LineChart(
          LineChartData(
            maxY: 6,
            gridData: const FlGridData(
              show: false,
            ), // Hide grid to avoid double lines
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: predictedSpots,
                isCurved: true,
                color: const Color(0xFF0066FF),
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                        radius: 3,
                        color: const Color(0xFF0066FF),
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}





class MetricTiny extends StatelessWidget {
  final String label;
  final String value;

  const MetricTiny({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize:
          MainAxisSize.min, // Ensures it doesn't take extra vertical space
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






class ProjectTable extends StatelessWidget {
  const ProjectTable({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collectionGroup('projects')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "No projects found",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        // ✅ SAFE SORT (handles missing createdAt)
        docs.sort((a, b) {
          final ta =
              (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
          final tb =
              (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;

          if (ta == null && tb == null) return 0;
          if (ta == null) return 1;
          if (tb == null) return -1;
          return tb.compareTo(ta);
        });

        final projects = docs.take(5).toList();

        return SizedBox(
          width: double.infinity,
          child: DataTable(
            headingTextStyle:
                const TextStyle(color: Colors.grey, fontSize: 12),
            horizontalMargin: 0,
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Expanded(child: Text("Project Name"))),
              DataColumn(label: Expanded(child: Text("Location"))),
              DataColumn(label: Expanded(child: Text("Status"))),
            ],
            rows: projects.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final name = data['projectName'] ?? 'Project';
              final location = data['location'] ?? '-';
              final status = data['status'] ?? 'Pending';

              final color = status == "Completed"
                  ? const Color(0xFF22C55E)
                  : status == "Ongoing"
                      ? const Color(0xFF4ADE80)
                      : Colors.orange;

              return _projectRow(
                name,
                location,
                status,
                color,
                hasDot: status == "Pending",
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // ⬇️ UNCHANGED UI
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




class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isSuccess;
  final Color iconColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isSuccess = false,
    this.iconColor = const Color(0xFF0066FF), // Default dashboard blue
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Adding the subtle shadow from the image
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Allows card to wrap content if needed
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isSuccess ? Colors.green : iconColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isSuccess ? const Color(0xFF22C55E) : iconColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8), // Slate-grey
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1E293B), // Dark navy text
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}





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
