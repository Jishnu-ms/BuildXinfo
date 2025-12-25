import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String apiBaseUrl = "https://mini-2ooh.onrender.com";

void main() {
  runApp(const MaterialApp(
    home: UserCostEstimationPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class UserCostEstimationPage extends StatefulWidget {
  const UserCostEstimationPage({super.key});

  @override
  State<UserCostEstimationPage> createState() => _UserCostEstimationPageState();
}

class _UserCostEstimationPageState extends State<UserCostEstimationPage> {
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();

  String _selectedLocation = 'Urban';
  String _selectedMaterial = 'Basic';
  int _selectedYear = 2024;
  int _floorCount = 1;
  bool _isLoading = false;

  double costPerSqft = 0;
  double totalCost = 0;
  double materialCost = 0;
  double labourCost = 0;
  double miscCost = 0;
  double timeMonths = 0;

  final List<String> _materials = ['Basic', 'Standard', 'Premium'];

  final Map<String, int> _locationIndex = {
    'Rural': 1,
    'Semi-Urban': 2,
    'Sub-Urban': 3,
    'Urban': 4
  };

  final Map<String, int> _materialIndex = {
    'Basic': 0,
    'Standard': 1,
    'Premium': 2
  };

  Future<void> _calculateEstimation() async {
    final area = double.tryParse(_areaController.text.trim());

    if (area == null || area <= 0) {
      _showSnackBar("Enter a valid built-up area");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$apiBaseUrl/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Total_Built_up_Area": area,
          "Material_Category": _materialIndex[_selectedMaterial],
          "Location_Index": _locationIndex[_selectedLocation],
          "Year": _selectedYear,
          "Quarter": 2
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          costPerSqft = (data["cost_per_sqft_inr"] ?? 0).toDouble();
          totalCost = (data["predicted_total_cost"] ?? 0).toDouble();
          materialCost = (data["material_cost"] ?? 0).toDouble();
          labourCost = (data["labour_cost"] ?? 0).toDouble();
          miscCost = (data["misc_cost"] ?? 0).toDouble();
          timeMonths = (data["time_months"] ?? 0).toDouble();
        });
      } else {
        _showSnackBar("Server error (${response.statusCode})");
      }
    } catch (e) {
      _showSnackBar("Connection failed (cold start?)");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetAll() {
    setState(() {
      costPerSqft = 0;
      totalCost = 0;
      materialCost = 0;
      labourCost = 0;
      miscCost = 0;
      timeMonths = 0;
    });
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "New Cost Estimation",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748)),
            ),
            const Text(
              "Early-stage construction cost prediction",
              style: TextStyle(color: Color(0xFF718096), fontSize: 16),
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildProjectInfoCard(),
                      const SizedBox(height: 24),
                      _buildEstimationParametersCard(),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: _buildResultCard()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectInfoCard() {
    return _CardBase(
      title: "Project Information",
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _customTextField(
                      "Project Name *",
                      _projectNameController,
                      "Enter project name")),
              const SizedBox(width: 16),
              Expanded(
                  child: _customDropdown(
                      "Location *",
                      _selectedLocation,
                      _locationIndex.keys.toList(),
                      (v) => setState(() => _selectedLocation = v!))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _customTextField(
                      "Built-up Area (sqft) *",
                      _areaController,
                      "Enter area",
                      isNumber: true,
                      suffixIcon: Icons.apartment)),
              const SizedBox(width: 16),
              Expanded(child: _floorStepper()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEstimationParametersCard() {
    return _CardBase(
      title: "Estimation Parameters",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _customDropdown(
              "Material Category",
              _selectedMaterial,
              _materials,
              (v) => setState(() => _selectedMaterial = v!),
              icon: Icons.layers_outlined),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFEBF4FF),
                borderRadius: BorderRadius.circular(8)),
            child: Text(
              "Location Index: ${_locationIndex[_selectedLocation]} ($_selectedLocation)",
              style: const TextStyle(
                  color: Color(0xFF2B6CB0),
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return _CardBase(
      title: "Estimated Cost",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Final Estimated Cost",
              style: TextStyle(
                  color: Color(0xFF2D3748),
                  fontWeight: FontWeight.w500)),
          Text("₹ ${totalCost.toStringAsFixed(0)}",
              style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B6CB0))),
          const Divider(height: 32),
          _resultRow("Material Cost", "₹ ${materialCost.toStringAsFixed(0)}"),
          _resultRow("Labour Cost", "₹ ${labourCost.toStringAsFixed(0)}"),
          _resultRow("Misc Cost", "₹ ${miscCost.toStringAsFixed(0)}"),
          _resultRow("Cost / sqft", "₹ ${costPerSqft.toStringAsFixed(2)}"),
          _resultRow(
              "Time Required", "${timeMonths.toStringAsFixed(1)} Months"),
          const SizedBox(height: 32),
          Row(
            children: [
              TextButton(
                  onPressed: _resetAll,
                  child: const Text("Reset",
                      style: TextStyle(color: Color(0xFF718096)))),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _calculateEstimation,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3182CE),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text("Estimate Cost",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xFF718096))),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748))),
        ],
      ),
    );
  }

  Widget _customTextField(String label, TextEditingController controller,
      String hint,
      {bool isNumber = false, IconData? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A5568))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType:
              isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon,
                    color: const Color(0xFF3182CE), size: 20)
                : null,
            filled: true,
            fillColor: const Color(0xFFF7FAFC),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _customDropdown(String label, String value, List<String> items,
      Function(String?) onChanged,
      {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A5568))),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((e) =>
                  DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon,
                    color: const Color(0xFF3182CE), size: 20)
                : null,
            filled: true,
            fillColor: const Color(0xFFF7FAFC),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _floorStepper() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Number of Floors *",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A5568))),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _floorCount,
          items: [1, 2, 3, 4]
              .map((e) => DropdownMenuItem(
                  value: e, child: Text(e.toString())))
              .toList(),
          onChanged: (v) => setState(() => _floorCount = v!),
          decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF7FAFC),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8))),
        ),
      ],
    );
  }
}

class _CardBase extends StatelessWidget {
  final String title;
  final Widget child;
  const _CardBase({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748))),
          const Divider(height: 32),
          child,
        ],
      ),
    );
  }
}

