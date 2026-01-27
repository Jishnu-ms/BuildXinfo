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
        final String name = data['name'] ?? 'No Name';
        final String role = data['role'] ?? 'User';
        final String email = data['email'] ?? '';

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE0E5F2).withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar with Modern Border/Ring
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF422AFB).withOpacity(0.1),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFF4F7FE),
                  backgroundImage: NetworkImage(
                    data['imageUrl'] ?? "https://i.pravatar.cc/150?u=$userId",
                  ),
                ),
              ),
              const SizedBox(width: 20),
              
              // User Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B2559),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Role Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF422AFB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        role,
                        style: const TextStyle(
                          color: Color(0xFF422AFB),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Email with Icon
                    Row(
                      children: [
                        const Icon(
                          Icons.mail_outline_rounded,
                          size: 16,
                          color: Color(0xFFA3AED0),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            email,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF707EAE),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Optional: Edit Profile or Settings Action
              if (MediaQuery.of(context).size.width > 600)
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings_outlined),
                  color: const Color(0xFFA3AED0),
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
        return const Color(0xFFFF4911);
      case "Ongoing":
        return const Color(0xFFFFA500);
      default:
        return const Color(0xFF05CD99);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE0E5F2).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant Header Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Projects",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B2559),
                    letterSpacing: -0.5,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("See all", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Scrollable Table Content
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _headerRow(),
                  const SizedBox(height: 8),
                  ...projects.map((p) => _dataRow(p)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF4F7FE), width: 2)),
      ),
      child: Row(
        children: const [
          SizedBox(width: 220, child: Text("PROJECT NAME", style: _headerStyle)),
          SizedBox(width: 180, child: Text("LOCATION", style: _headerStyle)),
          SizedBox(width: 140, child: Text("STATUS", style: _headerStyle)),
        ],
      ),
    );
  }

  Widget _dataRow(ProjectData p) {
    final color = _statusColor(p.status);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF4F7FE), width: 1)),
      ),
      child: Row(
        children: [
          // Project Name with modern weight
          SizedBox(
            width: 220,
            child: Text(
              p.name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B2559),
                fontSize: 15,
              ),
            ),
          ),
          // Location with muted color
          SizedBox(
            width: 180,
            child: Text(
              p.location,
              style: const TextStyle(
                color: Color(0xFF707EAE),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          // Status with Soft Background Chip
          SizedBox(
            width: 140,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 3, backgroundColor: color),
                      const SizedBox(width: 6),
                      Text(
                        p.status,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const TextStyle _headerStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: Color(0xFFA3AED0),
    letterSpacing: 0.5,
  );
}

/* ===================== RECENT ESTIMATES ===================== */

class RecentEstimatesWidget extends StatelessWidget {
  final List<EstimateData> estimates;

  const RecentEstimatesWidget({super.key, required this.estimates});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE0E5F2).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Estimates",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B2559),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          ...estimates.map((e) => _buildEstimateItem(e)),
        ],
      ),
    );
  }

  Widget _buildEstimateItem(EstimateData e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          // Modern Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7F2), // Very soft orange tint
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.description_outlined, 
              color: Color(0xFFFF4911),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF1B2559),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  e.date,
                  style: const TextStyle(
                    color: Color(0xFFA3AED0),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Price Tag
          Text(
            e.price,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFF1B2559),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
