



import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';



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
