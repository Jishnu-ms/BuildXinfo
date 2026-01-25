import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
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
            return const Center(child: Text("No users found"));
          }

          final users = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return {
              "ref": doc.reference,
              "name": data['name'] ?? 'Unnamed',
              "email": data['email'] ?? '-',
              "role": data['role'] ?? 'User',
              "avatar": data['avatar'],
              "projects": data['projectsCount'] ?? 0,
            };
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Manage Users",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B3674),
                  ),
                ),
                const SizedBox(height: 24),
                _usersTable(context, users),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= TABLE =================

  static Widget _usersTable(
    BuildContext context,
    List<Map<String, dynamic>> users,
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
          ...users.map((u) => _userRow(context, u)),
        ],
      ),
    );
  }

  static Widget _tableHeader() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    child: Row(
      children: [
        Expanded(flex: 3, child: Text("User", style: _headerStyle)),
        Expanded(flex: 2, child: Text("Role", style: _headerStyle)),
        Expanded(flex: 1, child: Text("Projects", style: _headerStyle)),
        Expanded(flex: 2, child: Text("Actions", style: _headerStyle)),
      ],
    ),
  );

  static Widget _userRow(BuildContext context, Map<String, dynamic> u) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF4F7FE))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: u['avatar'] != null
                      ? NetworkImage(u['avatar'])
                      : null,
                  child: u['avatar'] == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u['name'], style: _rowTextStyle),
                      Text(
                        u['email'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _roleBadge(u['role']),
            ),
          ),

          Expanded(
            flex: 1,
            child: Text("${u['projects']}", style: _rowTextStyle),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _actionIcon(
                  Icons.edit,
                  Colors.blue,
                  onTap: () => _showEditUserSheet(context, u),
                ),
                const SizedBox(width: 10),
                _actionIcon(
                  Icons.delete,
                  Colors.orange,
                  onTap: () => _showDeleteUserSheet(context, u),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= EDIT USER =================

  static void _showEditUserSheet(BuildContext context, Map<String, dynamic> u) {
    String selectedRole = u['role'] ?? "User";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
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
                    "Edit User Role",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B3674),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    children: ["Admin", "Project Manager", "Engineer", "User"]
                        .map((r) {
                          final color = _roleColor(r);
                          return ChoiceChip(
                            label: Text(r),
                            selected: selectedRole == r,
                            selectedColor: color,
                            backgroundColor: color.withOpacity(0.15),
                            labelStyle: TextStyle(
                              color: selectedRole == r ? Colors.white : color,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (_) =>
                                setModalState(() => selectedRole = r),
                            showCheckmark: false,
                          );
                        })
                        .toList(),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        await u['ref'].update({
                          "role": selectedRole,
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

  // ================= DELETE USER =================

  static void _showDeleteUserSheet(
    BuildContext context,
    Map<String, dynamic> u,
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
              const Text(
                "Delete User?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B3674),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to delete ${u['name']}?\nThis cannot be undone.",
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await u['ref'].delete();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.white),
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

  static Widget _roleBadge(String role) {
    final color = _roleColor(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  static Color _roleColor(String role) {
    switch (role) {
      case "Admin":
        return const Color(0xFF2563EB);
      case "Project Manager":
        return const Color(0xFFD97706);
      case "Engineer":
        return const Color(0xFF059669);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  static Widget _actionIcon(
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 18),
    ),
  );

  static const _headerStyle = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  static const _rowTextStyle = TextStyle(
    color: Color(0xFF2B3674),
    fontWeight: FontWeight.w500,
  );
}
