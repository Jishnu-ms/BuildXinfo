import 'package:flutter/material.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> users = [
      {
        "name": "Amit Sharma",
        "email": "amit.abstract@gmail.com",
        "avatar": "https://i.pravatar.cc/150?u=amit",
        "role": "Admin",
        "projects": 12,
      },
      {
        "name": "Priya Mehta",
        "email": "priyalocation@orcail.com",
        "avatar": "https://i.pravatar.cc/150?u=priya",
        "role": "Project Manager",
        "projects": 8,
      },
      {
        "name": "Neha Singhania",
        "email": "ivehanmalai@gmail.com",
        "avatar": "https://i.pravatar.cc/150?u=neha",
        "role": "Project Manager",
        "projects": 15,
      },
      {
        "name": "Rahul Verma",
        "email": "mhull.verma@gmail.com",
        "avatar": "https://i.pravatar.cc/150?u=rahul",
        "role": "Engineer",
        "projects": 6,
      },
      {
        "name": "Karan Joshi",
        "email": "karan.joshi@gmail.com",
        "avatar": "https://i.pravatar.cc/150?u=karan",
        "role": "Engineer",
        "projects": 4,
      },
      {
        "name": "Abhishek Patil",
        "email": "bhiyshborh@gmail.com",
        "avatar": "https://i.pravatar.cc/150?u=abhi",
        "role": "Engineer",
        "projects": 4,
      },
      {
        "name": "Ananya Kapoor",
        "email": "ananya.kapoor@gmail.com",
        "avatar": "https://i.pravatar.cc/150?u=ananya",
        "role": "User",
        "projects": 2,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Manage Users",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 20),

            // Toolbar
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text("Add New User"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E40AF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
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
                const SizedBox(width: 12),
                _dropdown("Filter: All Roles"),
                const SizedBox(width: 12),
                _dropdown("Sort: Latest"),
              ],
            ),

            const SizedBox(height: 24),

            // Users Table
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _tableHeader(),
                  const Divider(height: 1),
                  ...users.map(_userRow),
                  _paginationFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------

  static Widget _dropdown(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  static Widget _tableHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: const [
          Expanded(flex: 3, child: _Header("User")),
          Expanded(flex: 2, child: _Header("Role")),
          Expanded(flex: 1, child: _Header("Projects")),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: _Header("Actions"),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _userRow(Map<String, dynamic> u) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(u['avatar']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        u['email'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
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
            child: Text(
              "${u['projects']}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _action(Icons.edit, Colors.blue),
                const SizedBox(width: 8),
                _action(Icons.delete, Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _paginationFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("1 - 7 of 50 users", style: TextStyle(color: Colors.grey)),
          Text("◀ 1 2 … 8 ▶"),
        ],
      ),
    );
  }

  static Widget _roleBadge(String role) {
    Color color;
    
    switch (role) {
      case "Admin":
        color = const Color(0xFF2563EB);
        break;
      case "Project Manager":
        color = const Color(0xFFD97706);
        break;
      case "Engineer":
        color = const Color(0xFF059669);
        break;
      default:
        color = const Color(0xFF94A3B8);
    }

    return Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 8,   // ⬅️ reduced from 12
    vertical: 4,     // ⬅️ reduced from 6
  ),
  decoration: BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(16), // slightly smaller radius
  ),
  child: Text(
    role,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 10,     // ⬅️ reduced from 11 (optional but cleaner)
      fontWeight: FontWeight.bold,
    ),
  ),
);

  }

  static Widget _action(IconData icon, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }
}

// Header Text
class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF64748B),
      ),
    );
  }
}
