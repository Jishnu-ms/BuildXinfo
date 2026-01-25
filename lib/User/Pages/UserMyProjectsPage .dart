import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Usermyprojectspage extends StatefulWidget {
  const Usermyprojectspage({super.key});

  @override
  State<Usermyprojectspage> createState() => _UsermyprojectspageState();
}

class _UsermyprojectspageState extends State<Usermyprojectspage> {
  final user = FirebaseAuth.instance.currentUser;

  String _searchQuery = "";
  String _statusFilter = "All";
  String _sortBy = "Latest";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      color: const Color(0xFFF4F7FE),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Projects',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B3674),
            ),
          ),
          const SizedBox(height: 24),
          _buildHeaderActions(),
          const SizedBox(height: 24),
          Expanded(child: _buildProjectsTable()),
        ],
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeaderActions() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search projects...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        _dropdown(
          value: _statusFilter,
          items: const ["All", "Pending", "Ongoing", "Completed"],
          onChanged: (v) => setState(() => _statusFilter = v),
        ),
        const SizedBox(width: 16),
        _dropdown(
          value: _sortBy,
          items: const ["Latest", "Oldest", "Name"],
          onChanged: (v) => setState(() => _sortBy = v),
        ),
      ],
    );
  }

  // ================= TABLE =================

  Widget _buildProjectsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          const Divider(height: 1),
          Expanded(
            child: user == null
                ? const Center(child: Text("Not logged in"))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .collection('projects')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var docs = snapshot.data!.docs;

                      // SEARCH
                      docs = docs.where((d) {
                        final name =
                            (d['projectName'] ?? '').toString().toLowerCase();
                        return name.contains(_searchQuery);
                      }).toList();

                      // FILTER
                      if (_statusFilter != "All") {
                        docs = docs.where((d) {
                          final status = _deriveStatus(
                                  d.data() as Map<String, dynamic>)
                              .text;
                          return status == _statusFilter;
                        }).toList();
                      }

                      // SORT
                      docs.sort((a, b) {
                        if (_sortBy == "Name") {
                          return (a['projectName'] ?? '')
                              .compareTo(b['projectName'] ?? '');
                        }

                        final ta =
                            (a['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ??
                                0;
                        final tb =
                            (b['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ??
                                0;

                        return _sortBy == "Oldest" ? ta - tb : tb - ta;
                      });

                      if (docs.isEmpty) {
                        return const Center(
                          child: Text("No projects found",
                              style: TextStyle(color: Colors.grey)),
                        );
                      }

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final status = _deriveStatus(data);

                          return _buildProjectRow(
                            doc.id,
                            data['projectName'] ?? 'Unnamed',
                            data['location'] ?? '-',
                            data['floors']?.toString() ?? '-',
                            "${data['areaSqft'] ?? '-'} sqft",
                            status.text,
                            status.color,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Expanded(flex: 3, child: Text('Project Name', style: _headerStyle)),
            Expanded(flex: 2, child: Text('Location', style: _headerStyle)),
            Expanded(flex: 1, child: Text('Floors', style: _headerStyle)),
            Expanded(flex: 2, child: Text('Area', style: _headerStyle)),
            Expanded(flex: 2, child: Text('Status', style: _headerStyle)),
            Expanded(flex: 2, child: Text('Actions', style: _headerStyle)),
          ],
        ),
      );

  // ================= ROW =================

  Widget _buildProjectRow(
    String projectId,
    String name,
    String loc,
    String floors,
    String area,
    String status,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF4F7FE))),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name, style: _rowTextStyle)),
          Expanded(flex: 2, child: Text(loc, style: _rowTextStyle)),
          Expanded(flex: 1, child: Text(floors, style: _rowTextStyle)),
          Expanded(flex: 2, child: Text(area, style: _rowTextStyle)),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _statusChip(status, statusColor),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _buildActionIcon(
                  Icons.edit,
                  Colors.blue,
                  onTap: () => _showEditProjectSheet(projectId, name, status),
                ),
                const SizedBox(width: 8),
                _buildActionIcon(
                  Icons.delete,
                  Colors.orange,
                  onTap: () => _deleteProject(projectId, name),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= EDIT =================

  void _showEditProjectSheet(
    String projectId,
    String currentName,
    String currentStatus,
  ) {
    final nameController = TextEditingController(text: currentName);
    String selectedStatus = currentStatus;

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
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
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
                      final color = s == "Pending"
                          ? const Color(0xFFFFBC11)
                          : s == "Ongoing"
                              ? const Color(0xFFFFA500)
                              : const Color(0xFF05CD99);

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
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user!.uid)
                            .collection('projects')
                            .doc(projectId)
                            .update({
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

  // ================= DELETE =================

 Future<void> _deleteProject(String projectId, String projectName) async {
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
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            // Icon
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 28,
              ),
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
              "Are you sure you want to delete \"$projectName\"?\nThis action cannot be undone.",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Color(0xFF2B3674),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user!.uid)
                          .collection('projects')
                          .doc(projectId)
                          .delete();

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
                        color: Colors.white,
                      ),
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


  // ================= STATUS =================

  _StatusInfo _deriveStatus(Map<String, dynamic> data) {
    if (data['status'] != null) {
      return _statusFromText(data['status']);
    }

    final t = (data['estimatedTimeMonths'] ?? 0).toDouble();
    return t == 0
        ? _statusFromText("Pending")
        : t < 12
            ? _statusFromText("Ongoing")
            : _statusFromText("Completed");
  }

  _StatusInfo _statusFromText(String s) {
    switch (s) {
      case "Pending":
        return _StatusInfo("Pending", const Color(0xFFFFBC11));
      case "Ongoing":
        return _StatusInfo("Ongoing", const Color(0xFFFFA500));
      default:
        return _StatusInfo("Completed", const Color(0xFF05CD99));
    }
  }

  // ================= UI HELPERS =================

  Widget _statusChip(String text, Color color) => Container(
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

  Widget _buildActionIcon(
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

  Widget _dropdown({
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          items:
              items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => onChanged(v!),
        ),
      );

  static const _headerStyle =
      TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 14);
  static const _rowTextStyle =
      TextStyle(color: Color(0xFF2B3674), fontWeight: FontWeight.w500, fontSize: 14);
}

// ================= STATUS MODEL =================

class _StatusInfo {
  final String text;
  final Color color;
  _StatusInfo(this.text, this.color);
}
