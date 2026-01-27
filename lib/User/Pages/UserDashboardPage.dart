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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return Container(
          color: const Color(0xFFF0F4F8),
          padding: const EdgeInsets.all(24),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('projects')
                .orderBy('createdAt', descending: true)
                .snapshots(),
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
                      isMobile: isMobile,
                    ),

                    const SizedBox(height: 24),

                    isMobile
                        ? Column(
                            children: [
                              ProjectsTableWidget(projects: projects),
                              const SizedBox(height: 24),
                              RecentEstimatesWidget(
                                estimates: estimates.take(4).toList(),
                              ),
                            ],
                          )
                        : Row(
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
      },
    );
  }

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
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  data['imageUrl'] ??
                      "https://i.pravatar.cc/150?u=$userId",
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'] ?? 'No Name',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(data['role'] ?? 'User'),
                    Text(
                      data['email'] ?? '',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/* ===================== STAT CARDS ===================== */

class StatCardRow extends StatelessWidget {
  final List<StatCardData> stats;
  final bool isMobile;

  const StatCardRow({
    super.key,
    required this.stats,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return isMobile
        ? Wrap(
            spacing: 16,
            runSpacing: 16,
            children: stats
                .map((data) => SizedBox(
                      width: double.infinity,
                      child: _card(data),
                    ))
                .toList(),
          )
        : Row(
            children: stats
                .map((data) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: _card(data),
                      ),
                    ))
                .toList(),
          );
  }

  Widget _card(StatCardData data) {
    return Container(
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
    );
  }
}

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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(200),
            1: FixedColumnWidth(160),
            2: FixedColumnWidth(140),
          },
          children: [
            _headerRow(),
            ...projects.map(_dataRow),
          ],
        ),
      ),
    );
  }

  TableRow _headerRow() {
    return const TableRow(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text("Project Name", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text("Location", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  TableRow _dataRow(ProjectData p) {
    final color = _statusColor(p.status);
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(p.name),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(p.location),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              CircleAvatar(radius: 4, backgroundColor: color),
              const SizedBox(width: 8),
              Text(p.status, style: TextStyle(color: color)),
            ],
          ),
        ),
      ],
    );
  }
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
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(e.date,
                              style: const TextStyle(color: Colors.grey)),
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
