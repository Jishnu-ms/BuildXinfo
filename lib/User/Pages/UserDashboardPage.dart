import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/* ===================== DASHBOARD PAGE ===================== */

class Userdashboardpage extends StatelessWidget {
  const Userdashboardpage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Not logged in"));
    }

    return Container(
      color: const Color(0xFFF0F4F8),
      padding: const EdgeInsets.all(24),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('projects')
            .orderBy('createdAt', descending: true)
            .snapshots(), // 🔥 REAL-TIME
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          int pending = 0;
          int ongoing = 0;

          final projects = <ProjectData>[];
          final estimates = <EstimateData>[];

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = _deriveStatus(data);

            if (status == "Pending") pending++;
            if (status == "Ongoing") ongoing++;

            projects.add(ProjectData(
              name: data['projectName'] ?? 'Unnamed',
              location: data['location'] ?? '-',
              status: status,
            ));

            estimates.add(EstimateData(
              title: data['projectName'] ?? 'Unnamed',
              date: _formatDate(data['createdAt']),
              price: "₹ ${(data['totalCost'] ?? 0).toStringAsFixed(0)}",
            ));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                ProfileHeader(userId: user.uid),
                const SizedBox(height: 24),

                StatCardRow(
                  stats: [
                    StatCardData(
                      title: "Total Projects",
                      value: projects.length.toString(),
                      icon: Icons.folder_open,
                      iconColor: Colors.blue,
                      bgColor: const Color(0xFFE3F2FD),
                    ),
                    StatCardData(
                      title: "Pending Estimates",
                      value: pending.toString(),
                      icon: Icons.description_outlined,
                      iconColor: Colors.orange,
                      bgColor: const Color(0xFFFFF3E0),
                    ),
                    StatCardData(
                      title: "Ongoing Estimates",
                      value: ongoing.toString(),
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
                      child: ProjectsTableWidget(projects: projects),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: RecentEstimatesWidget(
                        estimates: estimates.take(4).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /* ================= STATUS LOGIC ================= */

  static String _deriveStatus(Map<String, dynamic> data) {
    if (data['status'] != null) return data['status'];

    final months = (data['estimatedTimeMonths'] ?? 0).toDouble();
    if (months <= 0) return "Pending";
    if (months < 12) return "Ongoing";
    return "Completed";
  }

  static String _formatDate(Timestamp? ts) {
    if (ts == null) return '-';
    final d = ts.toDate();
    return "${d.day}/${d.month}/${d.year}";
  }
}

/* ===================== MODELS ===================== */

class ProjectData {
  final String name;
  final String location;
  final String status;

  ProjectData({
    required this.name,
    required this.location,
    required this.status,
  });
}

class EstimateData {
  final String title;
  final String date;
  final String price;

  EstimateData({
    required this.title,
    required this.date,
    required this.price,
  });
}

/* ===================== PROFILE HEADER ===================== */

class ProfileHeader extends StatelessWidget {
  final String userId;

  const ProfileHeader({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

        return Container(
          height: 160,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  data['imageUrl'] ??
                      "https://i.pravatar.cc/150?u=$userId",
                ),
              ),
              const SizedBox(width: 24),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    data['role'] ?? 'User',
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                  Text(
                    data['email'] ?? '',
                    style: const TextStyle(color: Color(0xFF3B82F6)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/* ===================== STAT CARDS ===================== */

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

class StatCardRow extends StatelessWidget {
  final List<StatCardData> stats;

  const StatCardRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats.map((data) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: data.bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(data.icon, color: data.iconColor),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.title, style: const TextStyle(color: Colors.grey)),
                    Text(
                      data.value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/* ===================== PROJECTS TABLE ===================== */

class ProjectsTableWidget extends StatelessWidget {
  final List<ProjectData> projects;

  const ProjectsTableWidget({super.key, required this.projects});

  Color _statusColor(String status) {
    switch (status) {
      case "Pending":
        return const Color(0xFFFFBC11);
      case "Ongoing":
        return const Color(0xFFFFA500);
      default:
        return const Color(0xFF05CD99);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "My Projects",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B3674),
            ),
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2.2),
              1: FlexColumnWidth(1.6),
              2: FlexColumnWidth(1.6),
            },
            children: [
              _headerRow(),
              ...projects.map(_dataRow),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _headerRow() {
    return const TableRow(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text("Project Name", style: _headerStyle),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text("Location", style: _headerStyle),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text("Status", style: _headerStyle),
        ),
      ],
    );
  }

  TableRow _dataRow(ProjectData p) {
    final color = _statusColor(p.status);

    return TableRow(
      children: [
        _cell(p.name, true),
        _cell(p.location, false),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 4, backgroundColor: color),
              const SizedBox(width: 8),
              Text(
                p.status,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cell(String text, bool bold) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
          color: const Color(0xFF2B3674),
        ),
      ),
    );
  }

  static const _headerStyle =
      TextStyle(color: Colors.grey, fontWeight: FontWeight.w600);
}

/* ===================== RECENT ESTIMATES ===================== */

class RecentEstimatesWidget extends StatelessWidget {
  final List<EstimateData> estimates;

  const RecentEstimatesWidget({super.key, required this.estimates});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: estimates
            .map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.description, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(e.date,
                              style:
                                  const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text(e.price),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
