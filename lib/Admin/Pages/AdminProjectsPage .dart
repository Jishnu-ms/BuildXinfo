import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProjectsPage extends StatefulWidget {
  const AdminProjectsPage({super.key});

  @override
  State<AdminProjectsPage> createState() => _AdminProjectsPageState();
}

class _AdminProjectsPageState extends State<AdminProjectsPage> {
  String _searchQuery = "";
  String _statusFilter = "All";
  String _sortBy = "Latest";

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 30),
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
              _buildHeaderActions(isMobile),
              const SizedBox(height: 24),
              Expanded(child: _buildProjectsList(isMobile)),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER (RESPONSIVE) =================

  Widget _buildHeaderActions(bool isMobile) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: isMobile ? double.infinity : 300,
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            decoration: InputDecoration(
              hintText: "Search projects...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        _dropdown(
          value: _statusFilter,
          items: const ["All", "Pending", "Ongoing", "Completed"],
          onChanged: (v) => setState(() => _statusFilter = v),
        ),
        _dropdown(
          value: _sortBy,
          items: const ["Latest", "Oldest", "Name"],
          onChanged: (v) => setState(() => _sortBy = v),
        ),
      ],
    );
  }

  // ================= LIST (WITH BUG FIX) =================

  Widget _buildProjectsList(bool isMobile) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collectionGroup('projects').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // FIX: Extract data safely into a List of Maps to prevent "field does not exist" errors
        List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

        // ================= SEARCH & FILTER =================
        docs = docs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          
          // Use .get() or data[] with null awareness
          final name = (data['projectName'] ?? '').toString().toLowerCase();
          final status = (data['status'] ?? 'Pending').toString();

          bool matchesSearch = name.contains(_searchQuery);
          bool matchesStatus = _statusFilter == "All" || status == _statusFilter;

          return matchesSearch && matchesStatus;
        }).toList();

        // ================= SORT =================
        docs.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data() as Map<String, dynamic>;

          if (_sortBy == "Name") {
            return (dataA['projectName'] ?? '').compareTo(dataB['projectName'] ?? '');
          }

          final ta = (dataA['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
          final tb = (dataB['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;

          return _sortBy == "Oldest" ? ta - tb : tb - ta;
        });

        if (docs.isEmpty) {
          return const Center(
            child: Text("No projects found", style: TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final status = (data['status'] ?? 'Pending').toString();

            return _projectCard(
              context,
              isMobile,
              doc.reference,
              data['projectName'] ?? 'Unnamed',
              data['floors'] ?? 0,
              "${data['areaSqft'] ?? 0} sqft",
              (data['totalCost'] ?? 0).toDouble(),
              status,
              _statusColor(status),
            );
          },
        );
      },
    );
  }

  // ================= CARD (RESPONSIVE) =================

 Widget _projectCard(
    BuildContext context,
    bool isMobile,
    DocumentReference ref,
    String name,
    int floors,
    String area,
    double cost,
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
              // Modern Status Accent
              Container(
                width: 6,
                color: statusColor.withOpacity(0.8),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: isMobile
                      ? _buildMobileCardContent(context, ref, name, floors, area, cost, status, statusColor)
                      : _buildDesktopCardContent(context, ref, name, floors, area, cost, status, statusColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopCardContent(BuildContext context, DocumentReference ref, String name, int floors, String area, double cost, String status, Color statusColor) {
    return Row(
      children: [
        Expanded(flex: 4, child: _projectTitleInfo(name, floors, area)),
        Expanded(
          flex: 2,
          child: _costText(cost),
        ),
        Expanded(
          flex: 2,
          child: Align(alignment: Alignment.centerLeft, child: _statusChip(status, statusColor)),
        ),
        _actionButtons(context, ref, name, status),
      ],
    );
  }

  Widget _buildMobileCardContent(BuildContext context, DocumentReference ref, String name, int floors, String area, double cost, String status, Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _projectTitleInfo(name, floors, area)),
            _actionButtons(context, ref, name, status),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(height: 1, thickness: 0.8, color: Color(0xFFF4F7FE)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _statusChip(status, statusColor),
            _costText(cost),
          ],
        ),
      ],
    );
  }

  /* ================= MODERN SUB-COMPONENTS ================= */

  Widget _projectTitleInfo(String name, int floors, String area) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B2559),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: [
            _iconMeta(Icons.layers_outlined, "$floors Floors"),
            _iconMeta(Icons.square_foot_rounded, area),
          ],
        ),
      ],
    );
  }

  Widget _iconMeta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFFA3AED0)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF707EAE),
          ),
        ),
      ],
    );
  }

  Widget _costText(double cost) {
    return Text(
      "₹${cost.toStringAsFixed(2)}",
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1B2559),
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
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
  

  Widget _actionButtons(BuildContext context, DocumentReference ref, String name, String status) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _actionIcon(Icons.edit, Colors.blue, onTap: () => _showEditProjectSheet(context, ref, name, status)),
        const SizedBox(width: 10),
        _actionIcon(Icons.delete, Colors.orange, onTap: () => _showDeleteProjectSheet(context, ref, name)),
      ],
    );
  }

  // ================= MODALS & HELPERS =================

  void _showEditProjectSheet(BuildContext context, DocumentReference ref, String currentName, String currentStatus) {
    final nameController = TextEditingController(text: currentName);
    String selectedStatus = currentStatus;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dragHandle(),
              const Text("Edit Project", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Project Name",
                  filled: true,
                  fillColor: const Color(0xFFF4F7FE),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
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
                    labelStyle: TextStyle(color: selectedStatus == s ? Colors.white : color, fontWeight: FontWeight.bold),
                    onSelected: (_) => setModalState(() => selectedStatus = s),
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
                      "projectName": nameController.text.trim(),
                      "status": selectedStatus,
                      "updatedAt": FieldValue.serverTimestamp(),
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B3674),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteProjectSheet(BuildContext context, DocumentReference projectRef, String projectName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dragHandle(),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
            ),
            const SizedBox(height: 16),
            const Text("Delete Project?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
            const SizedBox(height: 8),
            Text("Are you sure you want to delete \"$projectName\"?\nThis action cannot be undone.",
                style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.4)),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text("Cancel", style: TextStyle(color: Color(0xFF2B3674), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await projectRef.delete();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text("Delete", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown({required String value, required List<String> items, required Function(String) onChanged}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
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



  static Widget _actionIcon(IconData icon, Color color, {VoidCallback? onTap}) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 18),
    ),
  );

  static Color _statusColor(String s) {
    switch (s) {
      case "Pending": return const Color(0xFFFFBC11);
      case "Ongoing": return const Color(0xFFFFA500);
      default: return const Color(0xFF05CD99);
    }
  }
}