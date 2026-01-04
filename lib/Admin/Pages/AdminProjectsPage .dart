import 'package:flutter/material.dart';

class AdminProjectsPage extends StatelessWidget {
  const AdminProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> projects = [
      {
        "name": "Green Villa",
        "location": "Mumbai",
        "clientName": "Amit Sharma",
        "clientImg": "https://i.pravatar.cc/150?u=amit",
        "floors": 2,
        "area": "3,200 sqft",
        "status": "Ongoing",
        "statusColor": Colors.amber,
      },
      {
        "name": "Skyline Heights",
        "location": "Delhi",
        "clientName": "Priya Mehta",
        "clientImg": "https://i.pravatar.cc/150?u=priya",
        "floors": 12,
        "area": "24,000 sqft",
        "status": "Completed",
        "statusColor": Colors.green,
      },
      {
        "name": "Sunrise Plaza",
        "location": "Bangalore",
        "clientName": "Rahul Verma",
        "clientImg": "https://i.pravatar.cc/150?u=rahul",
        "floors": 8,
        "area": "18,500 sqft",
        "status": "Pending",
        "statusColor": Colors.orange,
      },
      {
        "name": "Pearl Residency",
        "location": "Pune",
        "clientName": "Karan Joshi",
        "clientImg": "https://i.pravatar.cc/150?u=karan",
        "floors": 4,
        "area": "5,500 sqft",
        "status": "Ongoing",
        "statusColor": Colors.green,
      },
      {
        "name": "Maple Towers",
        "location": "Hyderabad",
        "clientName": "Neha Singhania",
        "clientImg": "https://i.pravatar.cc/150?u=neha",
        "floors": 15,
        "area": "32,000 sqft",
        "status": "Completed",
        "statusColor": Colors.green,
      },
      {
        "name": "Ruby Enclave",
        "location": "Chennai",
        "clientName": "Abhishek Patil",
        "clientImg": "https://i.pravatar.cc/150?u=abhi",
        "floors": 6,
        "area": "9,000 sqft",
        "status": "Pending",
        "statusColor": Colors.orange,
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
              "Manage Projects",
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
                  label: const Text("Add New Project"),
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
                      hintText: "Search projects...",
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
                _dropdown("Filter: All"),
                const SizedBox(width: 12),
                _dropdown("Sort: Latest"),
              ],
            ),

            const SizedBox(height: 24),

            // Table
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
                  _tableHeaderRow(),
                  const Divider(height: 1),
                  ...projects.map(_projectRow),
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

  static Widget _tableHeaderRow() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: const [
          Expanded(flex: 3, child: _Header("Project / Location")),
          Expanded(flex: 2, child: _Header("Client")),
          Expanded(flex: 2, child: _Header("Floors / Area")),
          Expanded(flex: 1, child: _Header("Status")),
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

  static Widget _projectRow(Map<String, dynamic> p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(p['location'], style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(p['clientImg'])),
                const SizedBox(width: 8),
                Text(p['clientName']),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${p['floors']} Floors",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(p['area'], style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: p['statusColor'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                p['status'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: p['statusColor'],
                  fontWeight: FontWeight.bold,
                ),
              ),
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
          Text("1 - 6 of 45 projects", style: TextStyle(color: Colors.grey)),
          Text("◀ 1 2 … 6 ▶"),
        ],
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

// Header Text Widget
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
