import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ⚠️ If Android Emulator → use http://10.0.2.2:8000
// ⚠️ If Web / Desktop → use http://127.0.0.1:8000
const String apiBaseUrl = "https://bulildxinfo-dnn.onrender.com";

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
      fontFamily: 'Roboto',
    ),
    home: const UserCostEstimationPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class UserCostEstimationPage extends StatefulWidget {
  const UserCostEstimationPage({super.key});

  @override
  State<UserCostEstimationPage> createState() => _UserCostEstimationPageState();
}

class _UserCostEstimationPageState extends State<UserCostEstimationPage> {
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _workerCostController = TextEditingController(text: "500");
  
  bool _isLoading = false;

  // --- Hybrid API Specific State Variables ---
  String _buildingType = 'Residential'; // x1
  int _roomsPerFloor = 3;               // x2
  String _facilities = 'None';          // x3
  int _floors = 1;                      // x5
  String _location = 'Urban';           // Location factor

  // Material Qualities
  String _cement = 'Standard';
  String _steel = 'Standard';
  String _bricks = 'Standard';
  String _sand = 'Standard';
  String _aggregate = 'Standard';

  // Work Qualities
  String _flooring = 'Standard';
  String _painting = 'Standard';
  String _sanitary = 'Standard';
  String _electrical = 'Standard';
  String _kitchen = 'Standard';
  String _contractor = 'Standard';

  // --- Result State Variables ---
  double totalCost = 0, materialCost = 0, labourCost = 0, adjustedBase = 0, timeMonths = 0, baseMlCost = 0;

  final List<String> _qualities = ['Basic', 'Standard', 'Premium'];
  final List<String> _locations = ['Rural', 'Urban', 'Metro'];
  final List<String> _buildingTypes = ['Residential', 'Commercial'];
  final List<String> _facilitiesList = ['None', 'Lift', 'Garage', 'Both'];

  Future<void> _calculateEstimation() async {
    final area = double.tryParse(_areaController.text.trim());
    final workerCost = double.tryParse(_workerCostController.text.trim());

    if (area == null || area <= 0) {
      _showSnackBar("Please enter a valid area");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$apiBaseUrl/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          // ML & Rule Engine Logic Inputs
          "building_type": _buildingType.toLowerCase(),
          "special_facilities": _facilities.toLowerCase(),
          "rooms_per_floor": _roomsPerFloor,
          "built_up_area_sqft": area,
          "no_of_floors": _floors,
          "worker_cost": workerCost ?? 500.0,
          "location": _location.toLowerCase(),

          // Quality Selectors
          "cement_quality": _cement.toLowerCase(),
          "steel_quality": _steel.toLowerCase(),
          "bricks_quality": _bricks.toLowerCase(),
          "sand_quality": _sand.toLowerCase(),
          "aggregate_quality": _aggregate.toLowerCase(),
          "flooring_quality": _flooring.toLowerCase(),
          "painting_quality": _painting.toLowerCase(),
          "sanitary_quality": _sanitary.toLowerCase(),
          "electrical_quality": _electrical.toLowerCase(),
          "kitchen_quality": _kitchen.toLowerCase(),
          "contractor_quality": _contractor.toLowerCase(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          baseMlCost = (data["base_ml_cost"] ?? 0).toDouble();
          adjustedBase = (data["adjusted_base_cost"] ?? 0).toDouble();
          materialCost = (data["material_cost"] ?? 0).toDouble();
          labourCost = (data["labour_cost"] ?? 0).toDouble();
          totalCost = (data["final_estimated_cost"] ?? 0).toDouble();
          timeMonths = (data["estimated_time_months"] ?? 0).toDouble();
        });
      } else {
        _showSnackBar("Server Error: ${response.body}");
      }
    } catch (e) {
      _showSnackBar("Connection failed. Check if Backend is running.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Inputs
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildMainSpecsCard(),
                      const SizedBox(height: 20),
                      _buildCollapsibleSection("Material Qualities", [
                        _selectionRow("Cement", _cement, (v) => setState(() => _cement = v)),
                        _selectionRow("Steel", _steel, (v) => setState(() => _steel = v)),
                        _selectionRow("Bricks", _bricks, (v) => setState(() => _bricks = v)),
                        _selectionRow("Sand", _sand, (v) => setState(() => _sand = v)),
                        _selectionRow("Aggregate", _aggregate, (v) => setState(() => _aggregate = v)),
                      ]),
                      const SizedBox(height: 20),
                      _buildCollapsibleSection("Work & Finishing", [
                        _selectionRow("Flooring", _flooring, (v) => setState(() => _flooring = v)),
                        _selectionRow("Painting", _painting, (v) => setState(() => _painting = v)),
                        _selectionRow("Sanitary", _sanitary, (v) => setState(() => _sanitary = v)),
                        _selectionRow("Electrical", _electrical, (v) => setState(() => _electrical = v)),
                        _selectionRow("Kitchen", _kitchen, (v) => setState(() => _kitchen = v)),
                        _selectionRow("Contractor", _contractor, (v) => setState(() => _contractor = v)),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Right Column: Results
                Expanded(
                  flex: 2,
                  child: _buildResultCard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainSpecsCard() {
    return _CardWrapper(
      title: "Project Configuration",
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildDropdown("Building Type", _buildingType, _buildingTypes, (v) => setState(() => _buildingType = v!))),
              const SizedBox(width: 16),
              Expanded(child: _buildDropdown("Special Facilities", _facilities, _facilitiesList, (v) => setState(() => _facilities = v!))),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _areaController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Total Built-up Area (sqft)",
              prefixIcon: const Icon(Icons.square_foot),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _workerCostController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Avg Worker Cost/Day",
                    prefixIcon: const Icon(Icons.payments),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildDropdown("Location", _location, _locations, (v) => setState(() => _location = v!))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildDropdown("No. of Floors", _floors, [1, 2, 3, 4, 5, 10], (v) => setState(() => _floors = v!))),
              const SizedBox(width: 16),
              Expanded(child: _buildDropdown("Rooms Per Floor", _roomsPerFloor, [1, 2, 3, 4, 5, 6, 8], (v) => setState(() => _roomsPerFloor = v!))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A202C),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("FINAL ESTIMATED COST", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Text("₹ ${totalCost.toStringAsFixed(0)}", 
               style: const TextStyle(color: Colors.greenAccent, fontSize: 32, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white24, height: 32),
          _resultRow("ML Base Prediction", baseMlCost),
          _resultRow("Adjusted Base (Hybrid)", adjustedBase),
          _resultRow("Material Total", materialCost),
          _resultRow("Labour & Finishing", labourCost),
          const Divider(color: Colors.white24, height: 32),
          _resultRow("Est. Completion Time", timeMonths, isTime: true),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _calculateEstimation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text("CALCULATE NOW", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets (Reusable) ---

  Widget _buildCollapsibleSection(String title, List<Widget> children) {
    return _CardWrapper(title: title, child: Column(children: children));
  }

  Widget _selectionRow(String label, String currentVal, Function(String) onSelect) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Wrap(
            spacing: 4,
            children: _qualities.map((q) {
              bool isSelected = currentVal == q;
              return ChoiceChip(
                label: Text(q, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.black)),
                selected: isSelected,
                onSelected: (bool selected) { if (selected) onSelect(q); },
                selectedColor: Colors.blue,
                showCheckmark: false,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, double value, {bool isTime = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(
            isTime ? "${value.toStringAsFixed(1)} Mo" : "₹ ${value.toStringAsFixed(0)}",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>(String label, T value, List<T> items, Function(T?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
        DropdownButton<T>(
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
        ),
      ],
    );
  }
}

class _CardWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  const _CardWrapper({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          const Divider(height: 25),
          child,
        ],
      ),
    );
  }
}
