import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  String _searchQuery = "";
  String _sortBy = "Name";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Padding(
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
            _buildHeaderActions(),
            const SizedBox(height: 24),
            Expanded(child: _buildUsersList()),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeaderActions() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (v) =>
                setState(() => _searchQuery = v.toLowerCase()),
            decoration: InputDecoration(
              hintText: "Search users...",
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
          value: _sortBy,
          items: const ["Name", "Role"],
          onChanged: (v) => setState(() => _sortBy = v),
        ),
      ],
    );
  }

  // ================= USERS LIST =================

  Widget _buildUsersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

        // SEARCH (same logic as user page)
        docs = docs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          return name.contains(_searchQuery);
        }).toList();

        // SORT
        docs.sort((a, b) {
          final da = a.data() as Map<String, dynamic>;
          final db = b.data() as Map<String, dynamic>;

          if (_sortBy == "Role") {
            return (da['role'] ?? '').compareTo(db['role'] ?? '');
          }
          return (da['name'] ?? '').compareTo(db['name'] ?? '');
        });

        if (docs.isEmpty) {
          return const Center(
            child: Text("No users found",
                style: TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return _userCard(
              context,
              doc.reference,
              data['name'] ?? 'Unnamed',
              data['email'] ?? '-',
              data['role'] ?? 'User',
              data['avatar'],
            );
          },
        );
      },
    );
  }

  // ================= USER CARD =================

  Widget _userCard(
  BuildContext context,
  DocumentReference ref,
  String name,
  String email,
  String role,
  String? avatar,
) {
  final roleColor = _roleColor(role);

  return Container(
    margin: const EdgeInsets.only(bottom: 18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.035),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Row(
      children: [
        // Accent strip (same language as project card)
        Container(
          width: 4,
          height: 92,
          decoration: BoxDecoration(
            color: roleColor.withOpacity(0.9),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      avatar != null ? NetworkImage(avatar) : null,
                  child: avatar == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 14),

                // Name + email
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2B3674),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Role badge
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _roleBadge(role),
                  ),
                ),

                // Project count
                Expanded(
                  flex: 2,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: ref.collection('projects').snapshots(),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Text(
                          "-",
                          style: TextStyle(color: Colors.grey),
                        );
                      }
                      return Text(
                        "${snap.data!.docs.length} Projects",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2B3674),
                        ),
                      );
                    },
                  ),
                ),

                // Actions
                Row(
                  children: [
                    _actionIcon(
                      Icons.edit,
                      Colors.blue,
                      onTap: () =>
                          _showEditUserSheet(context, ref, role),
                    ),
                    const SizedBox(width: 10),
                    _actionIcon(
                      Icons.delete,
                      Colors.orange,
                      onTap: () =>
                          _showDeleteUserSheet(context, ref, name),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  // ================= EDIT USER =================

  void _showEditUserSheet(
    BuildContext context,
    DocumentReference ref,
    String currentRole,
  ) {
    String selectedRole = currentRole;

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
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
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
                    children:
                        ["Admin", "Project Manager", "Engineer", "User"]
                            .map((r) {
                      final color = _roleColor(r);
                      return ChoiceChip(
                        label: Text(r),
                        selected: selectedRole == r,
                        selectedColor: color,
                        backgroundColor: color.withOpacity(0.15),
                        labelStyle: TextStyle(
                          color:
                              selectedRole == r ? Colors.white : color,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) =>
                            setModalState(() => selectedRole = r),
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
                        await ref.update({
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

  // ================= DELETE USER (UNCHANGED UI) =================

  void _showDeleteUserSheet(
    BuildContext context,
    DocumentReference ref,
    String name,
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
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
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
                "Are you sure you want to delete \"$name\"?\nThis action cannot be undone.",
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
                        await ref.delete();
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

  // ================= HELPERS =================

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
          items: items
              .map((e) =>
                  DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => onChanged(v!),
        ),
      );

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
}
