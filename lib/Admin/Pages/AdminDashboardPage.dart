import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardPage extends StatelessWidget {
  AdminDashboardPage({super.key});

  final List<Map<String, dynamic>> performanceMetrics = [
    {"label": "MAE", "value": "₹ 22,508"},
    {"label": "MSE", "value": "1.15"},
    {"label": "RMSE", "value": ".42"},
  ];

  // --- RESPONSIVE HELPERS ---
  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 850;
  bool isTablet(BuildContext context) => MediaQuery.of(context).size.width < 1100 && MediaQuery.of(context).size.width >= 850;
  bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    final double padding = isMobile(context) ? 16.0 : 24.0;

    return Container(
      color: const Color(0xFFF0F4F8),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Stats Row (Responsive Grid)
            _buildResponsiveStatsGrid(context),

            const SizedBox(height: 24),

            // 2. Middle & Bottom Sections
            if (isMobile(context)) ...[
              // Stack everything vertically for mobile
              _buildCostEstimationCard(),
              const SizedBox(height: 24),
              _buildModelPerformanceCard(),
              const SizedBox(height: 24),
              _buildRecentProjectsCard(),
              const SizedBox(height: 24),
              _buildUserActivityCard(),
            ] else ...[
              // Side-by-side for Tablet and Desktop
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildCostEstimationCard()),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: _buildModelPerformanceCard()),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildRecentProjectsCard()),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: _buildUserActivityCard()),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- STATS GRID LOGIC ---
  Widget _buildResponsiveStatsGrid(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collectionGroup('projects').snapshots(),
      builder: (context, projectSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, userSnap) {
            int totalProjects = projectSnap.hasData ? projectSnap.data!.docs.length : 0;
            int totalUsers = userSnap.hasData ? userSnap.data!.docs.length : 0;
            int activeProjects = projectSnap.hasData
                ? projectSnap.data!.docs.where((p) => (p.data() as Map)['status'] != 'Completed').length
                : 0;

            final List<Widget> stats = [
              StatCard(icon: LucideIcons.calculator, label: "Total Estimates", value: totalProjects.toString()),
              StatCard(icon: LucideIcons.home, label: "Active Projects", value: activeProjects.toString()),
              StatCard(icon: LucideIcons.users, label: "Registered Users", value: totalUsers.toString()),
              const StatCard(icon: LucideIcons.checkCircle, label: "Model Accuracy", value: "87.5 %", isSuccess: true),
            ];

            return LayoutBuilder(builder: (context, constraints) {
              // Calculate crossAxisCount based on width
              int crossAxisCount = isMobile(context) ? 1 : (isTablet(context) ? 2 : 4);
              
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stats.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 100, // Fixed height for stat cards
                ),
                itemBuilder: (context, index) => stats[index],
              );
            });
          },
        );
      },
    );
  }

  // --- REFACTORED CARD WIDGETS ---

  Widget _buildCostEstimationCard() {
    return _buildDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: "Cost Estimation Stats", showLegend: true),
          const Text("Predicted vs Actual Costs", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 30),
          SizedBox(height: 200, child: MainChart()),
          const Center(child: Text("Recent Estimates", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildModelPerformanceCard() {
    return _buildDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Model Performance", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          const SizedBox(height: 180, child: DonutChart()),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: performanceMetrics.map((m) => MetricTiny(label: m['label'], value: m['value'])).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentProjectsCard() {
    return _buildDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recent Projects", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          const ProjectTable(), // Note: Internal SingleChildScrollView handles overflow
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: () {}, child: const Text("View All", style: TextStyle(color: Colors.grey, fontSize: 12))),
          ),
        ],
      ),
    );
  }

  Widget _buildUserActivityCard() {
    return _buildDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("User Activity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          const ActivityList(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(onPressed: () {}, child: const Text("View Logs", style: TextStyle(color: Colors.grey))),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}

// --- COMPONENTS ---

class ActivityList extends StatelessWidget {
  const ActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collectionGroup('projects').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Text("No recent activity", style: TextStyle(color: Colors.grey, fontSize: 12));

        docs.sort((a, b) {
          final ta = (a.data() as Map<String, dynamic>)['updatedAt'] as Timestamp?;
          final tb = (b.data() as Map<String, dynamic>)['updatedAt'] as Timestamp?;
          if (ta == null && tb == null) return 0;
          if (ta == null) return 1;
          if (tb == null) return -1;
          return tb.compareTo(ta);
        });

        final recent = docs.take(5).toList();
        return Column(
          children: recent.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ActivityRow(
              user: data['updatedBy'] ?? 'User',
              action: "updated ${data['projectName'] ?? 'Project'} (${data['status'] ?? 'updated'})",
              time: _timeAgo(data['updatedAt']),
              color: _activityColor(data['status'] ?? ''),
            );
          }).toList(),
        );
      },
    );
  }

  String _timeAgo(Timestamp? ts) {
    if (ts == null) return '';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Color _activityColor(String status) {
    if (status == "Completed") return Colors.green;
    if (status == "Ongoing") return Colors.orange;
    return Colors.blue;
  }
}

class ActivityRow extends StatelessWidget {
  final String user, action, time;
  final Color color;
  const ActivityRow({super.key, required this.user, required this.action, required this.time, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
            child: const Icon(Icons.check, size: 12, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 12),
                children: [
                  TextSpan(text: "$user ", style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: action, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }
}

class ProjectTable extends StatelessWidget {
  const ProjectTable({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collectionGroup('projects').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Text("No projects found", style: TextStyle(color: Colors.grey));

        docs.sort((a, b) {
          final ta = (a.data() as Map)['createdAt'] as Timestamp?;
          final tb = (b.data() as Map)['createdAt'] as Timestamp?;
          if (ta == null || tb == null) return 0;
          return tb.compareTo(ta);
        });

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                // This ensures the table is at least as wide as the container on desktop
                // but maintains a minimum width on mobile for readability.
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth > 600 ? constraints.maxWidth : 600,
                ),
                child: DataTable(
                  // Use columnSpacing to distribute space evenly on wide screens
                  columnSpacing: constraints.maxWidth > 800 ? (constraints.maxWidth / 4) : 20,
                  headingTextStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                  horizontalMargin: 0,
                  columns: const [
                    DataColumn(label: Text("Project Name")),
                    DataColumn(label: Text("Location")),
                    DataColumn(label: Text("Status")),
                  ],
                  rows: docs.take(5).map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    String status = data['status'] ?? 'Pending';
                    Color color = status == "Completed" 
                        ? const Color(0xFF22C55E) 
                        : (status == "Ongoing" ? const Color(0xFF4ADE80) : Colors.orange);
                        
                    return DataRow(cells: [
                      DataCell(
                        SizedBox(
                          width: constraints.maxWidth * 0.3, // Gives name more room
                          child: Text(
                            data['projectName'] ?? 'Project', 
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(data['location'] ?? '-')),
                      DataCell(_statusBadge(status, color)),
                    ]);
                  }).toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status, 
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class MainChart extends StatelessWidget {
  MainChart({super.key});
  final List<double> actualCosts = [1.5, 3.0, 2.5, 1.8, 4.2, 2.8, 3.5, 4.0];
  final List<FlSpot> predictedSpots = const [FlSpot(0, 1.2), FlSpot(1, 2.8), FlSpot(2, 2.1), FlSpot(3, 3.2), FlSpot(4, 3.9), FlSpot(5, 3.4), FlSpot(6, 4.8), FlSpot(7, 5.5)];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BarChart(BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 6,
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1)),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: actualCosts.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value, color: Colors.orange.shade400, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))] )).toList(),
        )),
        LineChart(LineChartData(
          maxY: 6,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [LineChartBarData(spots: predictedSpots, isCurved: true, color: const Color(0xFF0066FF), barWidth: 3, dotData: const FlDotData(show: true))],
        )),
      ],
    );
  }
}

class DonutChart extends StatelessWidget {
  const DonutChart({super.key});
  @override
  Widget build(BuildContext context) {
    return PieChart(PieChartData(sectionsSpace: 5, centerSpaceRadius: 40, sections: [
      PieChartSectionData(color: Colors.blue, value: 60, showTitle: false, radius: 15),
      PieChartSectionData(color: Colors.teal, value: 25, showTitle: false, radius: 15),
      PieChartSectionData(color: Colors.orange, value: 15, showTitle: false, radius: 15),
    ]));
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool isSuccess;
  const StatCard({super.key, required this.icon, required this.label, required this.value, this.isSuccess = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: (isSuccess ? Colors.green : const Color(0xFF0066FF)).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: isSuccess ? const Color(0xFF22C55E) : const Color(0xFF0066FF), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                Text(value, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.bold)),
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
  const SectionHeader({super.key, required this.title, this.showLegend = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        if (showLegend) Row(children: [_legendItem("Pred.", Colors.blue), const SizedBox(width: 8), _legendItem("Act.", Colors.orange)]),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    ]);
  }
}

class MetricTiny extends StatelessWidget {
  final String label, value;
  const MetricTiny({super.key, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
    ]);
  }
}