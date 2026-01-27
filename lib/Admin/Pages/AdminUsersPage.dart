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
    // Get screen width to adjust padding/font sizes globally if needed
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding = screenWidth > 600 ? 30 : 16;

    return Scaffold(
     
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
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
              _buildHeaderActions(screenWidth),
              const SizedBox(height: 24),
              Expanded(child: _buildUsersList(screenWidth)),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER (Responsive Row/Column) =================

  Widget _buildHeaderActions(double width) {
    bool isMobile = width < 600;
    return Flex(
      direction: isMobile ? Axis.vertical : Axis.horizontal,
      children: [
        Expanded(
          flex: isMobile ? 0 : 1,
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
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
        SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 12 : 0),
        SizedBox(
          width: isMobile ? double.infinity : 150,
          child: _dropdown(
            value: _sortBy,
            items: const ["Name", "Role"],
            onChanged: (v) => setState(() => _sortBy = v),
          ),
        ),
      ],
    );
  }

  // ================= USERS LIST =================

  Widget _buildUsersList(double screenWidth) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

        docs = docs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          return name.contains(_searchQuery);
        }).toList();

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
            child: Text("No users found", style: TextStyle(color: Colors.grey)),
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
              screenWidth,
            );
          },
        );
      },
    );
  }

  // ================= RESPONSIVE USER CARD =================
Widget _userCard(
    BuildContext context,
    DocumentReference ref,
    String name,
    String email,
    String role,
    String? avatar,
    double screenWidth,
  ) {
    final roleColor = _roleColor(role);
    bool isMobile = screenWidth < 750;

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
              // Modern Accent Strip
              Container(
                width: 6,
                color: roleColor.withOpacity(0.8),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: isMobile 
                    ? _buildMobileLayout(context, ref, name, email, role, avatar)
                    : _buildDesktopLayout(context, ref, name, email, role, avatar),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(context, ref, name, email, role, avatar) {
    return Row(
      children: [
        _buildModernAvatar(avatar, userId: ref.id),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: _nameEmailCol(name, email),
        ),
        Expanded(
          flex: 2,
          child: _roleBadge(role, _roleColor(role)),
        ),
        Expanded(
          flex: 2,
          child: _projectCountStream(ref),
        ),
        _actionButtons(context, ref, name, role),
      ],
    );
  }

  Widget _buildMobileLayout(context, ref, name, email, role, avatar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildModernAvatar(avatar, userId: ref.id, radius: 22),
            const SizedBox(width: 12),
            Expanded(child: _nameEmailCol(name, email)),
            _actionButtons(context, ref, name, role),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(height: 1, thickness: 0.8, color: Color(0xFFF4F7FE)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _roleBadge(role, _roleColor(role)),
            _projectCountStream(ref),
          ],
        ),
      ],
    );
  }

  // ================= MODERNIZED SUB-COMPONENTS =================

  Widget _buildModernAvatar(String? avatar, {required String userId, double radius = 24}) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF4F7FE), width: 2),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFF4F7FE),
        backgroundImage: avatar != null ? NetworkImage(avatar) : null,
        child: avatar == null 
          ? Icon(Icons.person, color: const Color(0xFFA3AED0), size: radius) 
          : null,
      ),
    );
  }

  Widget _nameEmailCol(String name, String email) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B2559),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13, 
              fontWeight: FontWeight.w500,
              color: Color(0xFF707EAE),
            ),
          ),
        ],
      );

 Widget _roleBadge(String role, Color color) {
  return Align(
    alignment: Alignment.centerLeft, // Prevents the badge from stretching horizontally
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12), // Slightly deeper tint for better contrast
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: color.withOpacity(0.2), // Subtle border adds "definition" on desktop
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Vital: Keeps the container tight to the text
        children: [
          // Using a Container instead of CircleAvatar for a crisper pixel-perfect dot
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            role.toUpperCase(),
            style: TextStyle(
              fontSize: 10.5, // Slightly smaller for a more "UI Label" feel
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.8, // Increased tracking for premium readability
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _projectCountStream(DocumentReference ref) => StreamBuilder<QuerySnapshot>(
        stream: ref.collection('projects').snapshots(),
        builder: (context, snap) {
          int count = snap.hasData ? snap.data!.docs.length : 0;
          return Row(
            children: [
              const Icon(Icons.assignment_outlined, size: 16, color: Color(0xFFA3AED0)),
              const SizedBox(width: 6),
              Text(
                "$count Projects",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B2559),
                ),
              ),
            ],
          );
        },
      );

  Widget _actionButtons(context, ref, name, role) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _modernActionIcon(
            Icons.edit_outlined,
            const Color(0xFF422AFB), // Primary Indigo
            onTap: () => _showEditUserSheet(context, ref, role),
          ),
          const SizedBox(width: 10),
          _modernActionIcon(
            Icons.delete_outline_rounded,
            const Color(0xFFEE5D50), // Modern Red
            onTap: () => _showDeleteUserSheet(context, ref, name),
          ),
        ],
      );

  Widget _modernActionIcon(IconData icon, Color color, {required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
  // ================= MODALS & HELPERS (Keep existing logic) =================

  // ================= EDIT USER (Original UI + Responsive Wrap) =================

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
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32), // Adjusted for drag handle
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
                  // Wrap ensures chips don't overflow on small screens
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
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
                          color: selectedRole == r ? Colors.white : color,
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

  // ================= DELETE USER (Original UI Restored) =================

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
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
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
  Widget _dropdown({required String value, required List<String> items, required Function(String) onChanged}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => onChanged(v!),
          ),
        ),
      );

  static Widget _dragHandle() => Center(
        child: Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
        ),
      );



  static Color _roleColor(String role) {
    switch (role) {
      case "Admin": return const Color(0xFF2563EB);
      case "Project Manager": return const Color(0xFFD97706);
      case "Engineer": return const Color(0xFF059669);
      default: return const Color(0xFF94A3B8);
    }
  }

  static Widget _actionIcon(IconData icon, Color color, {VoidCallback? onTap}) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18),
        ),
      );
}