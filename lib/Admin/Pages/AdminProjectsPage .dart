import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProjectsPage extends StatelessWidget {
  const AdminProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('projects')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No projects found"));
          }

          final projects = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final String status =
                (data['status'] ?? "Pending").toString();

            return {
              "ref": doc.reference,
              "name": data['projectName'] ?? "Unnamed",
              "floors": data['floors'] ?? 0,
              "area": "${data['areaSqft'] ?? 0} sqft",
              "status": status,
              "statusColor": _statusColor(status),
              "totalCost": (data['totalCost'] ?? 0).toDouble(),
            };
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Manage Projects",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B3674),
                  ),
                ),
                const SizedBox(height: 24),
                _projectsTable(context, projects),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= TABLE =================

  static Widget _projectsTable(
    BuildContext context,
    List<Map<String, dynamic>> projects,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _tableHeader(),
          const Divider(height: 1),
          ...projects.map((p) => _projectRow(context, p)),
        ],
      ),
    );
  }

  static Widget _tableHeader() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Expanded(flex: 3, child: Text("Project", style: _headerStyle)),
            Expanded(flex: 2, child: Text("Floors / Area", style: _headerStyle)),
            Expanded(flex: 2, child: Text("Cost", style: _headerStyle)),
            Expanded(flex: 2, child: Text("Status", style: _headerStyle)),
            Expanded(flex: 2, child: Text("Actions", style: _headerStyle)),
          ],
        ),
      );

  static Widget _projectRow(BuildContext context, Map<String, dynamic> p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF4F7FE))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(p['name'], style: _rowTextStyle),
          ),
          Expanded(
            flex: 2,
            child: Text("${p['floors']} • ${p['area']}",
                style: _rowTextStyle),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "₹ ${p['totalCost'].toStringAsFixed(2)}",
              style: _rowTextStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: _statusChip(p['status'], p['statusColor']),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _actionIcon(
                  Icons.edit,
                  Colors.blue,
                  onTap: () => _showEditProjectSheet(context, p),
                ),
                const SizedBox(width: 10),
                _actionIcon(
                  Icons.delete,
                  Colors.orange,
                  onTap: () => _showDeleteProjectSheet(context, p),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= EDIT (BOTTOM SHEET) =================

  static void _showEditProjectSheet(
    BuildContext context,
    Map<String, dynamic> p,
  ) {
    final nameController = TextEditingController(text: p['name']);
    String selectedStatus = (p['status'] ?? "Pending").toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dragHandle(),
                  const Text(
                    "Edit Project",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B3674),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Project Name",
                      filled: true,
                      fillColor: const Color(0xFFF4F7FE),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    children: ["Pending", "Ongoing", "Completed"].map((s) {
                      final color = _statusColor(s);
                      return ChoiceChip(
                        label: Text(s),
                        selected: selectedStatus == s,
                        selectedColor: color,
                        backgroundColor: color.withOpacity(0.15),
                        labelStyle: TextStyle(
                          color:
                              selectedStatus == s ? Colors.white : color,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) =>
                            setModalState(() => selectedStatus = s),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        await p['ref'].update({
                          "projectName": nameController.text.trim(),
                          "status": selectedStatus,
                          "updatedAt": FieldValue.serverTimestamp(),
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B3674),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ================= DELETE (BOTTOM SHEET) =================

  static void _showDeleteProjectSheet(
    BuildContext context,
    Map<String, dynamic> p,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dragHandle(),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.delete_outline,
                    color: Colors.redAccent, size: 28),
              ),
              const SizedBox(height: 16),
              const Text(
                "Delete Project?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B3674),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to delete \"${p['name']}\"?\nThis action cannot be undone.",
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text("Cancel",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await p['ref'].delete();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Delete",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= UI HELPERS =================

  static Widget _dragHandle() => Center(
        child: Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );

  static Widget _statusChip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 4, backgroundColor: color),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );

  static Widget _actionIcon(
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      );

  static Color _statusColor(String s) {
    switch (s) {
      case "Pending":
        return const Color(0xFFFFBC11);
      case "Ongoing":
        return const Color(0xFFFFA500);
      default:
        return const Color(0xFF05CD99);
    }
  }

  static const _headerStyle =
      TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 14);

  static const _rowTextStyle =
      TextStyle(color: Color(0xFF2B3674), fontWeight: FontWeight.w500);
}
