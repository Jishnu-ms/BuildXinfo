// ignore_for_file: file_names

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return Container(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
         
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
              const SizedBox(height: 20),
              _buildHeaderActions(isMobile),
              const SizedBox(height: 20),
              Expanded(child: _buildProjectsTable(isMobile)),
            ],
          ),
        );
      },
    );
  }

  /* ================= HEADER ================= */

  Widget _buildHeaderActions(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _searchField(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _dropdown(
                  value: _statusFilter,
                  items: const ["All", "Pending", "Ongoing", "Completed"],
                  onChanged: (v) => setState(() => _statusFilter = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dropdown(
                  value: _sortBy,
                  items: const ["Latest", "Oldest", "Name"],
                  onChanged: (v) => setState(() => _sortBy = v),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: 3, child: _searchField()),
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

  Widget _searchField() {
    return TextField(
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
    );
  }

  /* ================= TABLE ================= */

 Widget _buildProjectsTable(bool isMobile) {
    return user == null
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

              docs = docs.where((d) {
                final name = (d['projectName'] ?? '').toString().toLowerCase();
                return name.contains(_searchQuery.toLowerCase());
              }).toList();

              if (_statusFilter != "All") {
                docs = docs.where((d) {
                  final status = _deriveStatus(
                    d.data() as Map<String, dynamic>,
                  ).text;
                  return status == _statusFilter;
                }).toList();
              }

              docs.sort((a, b) {
                if (_sortBy == "Name") {
                  return (a['projectName'] ?? '').compareTo(
                    b['projectName'] ?? '',
                  );
                }
                final ta =
                    (a['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
                final tb =
                    (b['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
                return _sortBy == "Oldest" ? ta - tb : tb - ta;
              });

              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No projects found",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final status = _deriveStatus(data);

                  return _buildProjectRow(
                    isMobile,
                    docs[index].id,
                    data['projectName'] ?? 'Unnamed Project',
                    data['location'] ?? 'Not specified',
                    data['floors']?.toString() ?? '0',
                    "${data['areaSqft'] ?? '0'} sqft",
                    status.text,
                    status.color,
                  );
                },
              );
            },
          );
  }

  /* ================= MODERNIZED ROW ================= */

  Widget _buildProjectRow(
    bool isMobile,
    String projectId,
    String name,
    String loc,
    String floors,
    String area,
    String status,
    Color statusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Status Indicator Bar
              Container(
                width: 6,
                color: statusColor.withOpacity(0.8),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: _projectNameText(name)),
                                _statusChip(status, statusColor),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _projectMetaGrid(loc, floors, area),
                            const Divider(height: 32, thickness: 0.8, color: Color(0xFFF4F7FE)),
                            _actions(projectId, name, status),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _projectNameText(name),
                                  const SizedBox(height: 8),
                                  _projectMetaGrid(loc, floors, area),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            _statusChip(status, statusColor),
                            const SizedBox(width: 32),
                            _actions(projectId, name, status),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* ================= SUB-COMPONENTS ================= */

  Widget _projectNameText(String name) {
    return Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1B2559),
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _projectMetaGrid(String loc, String floors, String area) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _metaItem(Icons.location_on_outlined, loc),
        _metaItem(Icons.layers_outlined, "$floors Floors"),
        _metaItem(Icons.square_foot_rounded, area),
      ],
    );
  }

  Widget _metaItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: const Color(0xFFA3AED0)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF707EAE),
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _actions(String id, String name, String status) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionIcon(
          Icons.edit,
          Colors.blue,
          onTap: () => _showEditProjectSheet(id, name, status),
        ),
        const SizedBox(width: 10),
        _buildActionIcon(
          Icons.delete,
          Colors.orange,
          onTap: () => _deleteProject(id, name),
        ),
      ],
    );
  }

  /* ================= EDIT ================= */

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
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                          color: selectedStatus == s ? Colors.white : color,
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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

  /* ================= DELETE ================= */

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

  /* ================= STATUS ================= */

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
        return _StatusInfo("Pending", const Color.fromARGB(255, 255, 88, 17));
      case "Ongoing":
        return _StatusInfo("Ongoing", const Color(0xFFFFA500));
      default:
        return _StatusInfo("Completed", const Color(0xFF05CD99));
    }
  }

  /* ================= UI HELPERS ================= */



  Widget _buildActionIcon(IconData icon, Color color, {VoidCallback? onTap}) =>
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
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: DropdownButton<String>(
      value: value,
      underline: const SizedBox(),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) => onChanged(v!),
    ),
  );
}

/* ================= STATUS MODEL ================= */

class _StatusInfo {
  final String text;
  final Color color;
  _StatusInfo(this.text, this.color);
}
