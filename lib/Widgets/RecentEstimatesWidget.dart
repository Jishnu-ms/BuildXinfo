import 'package:flutter/material.dart';

// 1. Define the Data Model
class EstimateData {
  final String title;
  final String date;
  final String price;

  EstimateData({
    required this.title,
    required this.date,
    required this.price,
  });
}

// 2. The Reusable Recent Estimates Widget
class RecentEstimatesWidget extends StatelessWidget {
  final List<EstimateData> estimates;

  const RecentEstimatesWidget({super.key, required this.estimates});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Estimates",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          // Map the list to build the items
          ...estimates.map((item) => _buildEstimateItem(item)),
          
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "View All >",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimateItem(EstimateData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          // The Orange Document Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.description, 
              color: Colors.orangeAccent, 
              size: 20
            ),
          ),
          const SizedBox(width: 12),
          // Title and Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  data.date,
                  style: const TextStyle(
                    color: Colors.grey, 
                    fontSize: 12
                  ),
                ),
              ],
            ),
          ),
          // Price Text
          Text(
            data.price,
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// --- USAGE EXAMPLE ---
/*
  final List<EstimateData> myEstimates = [
    EstimateData(title: "SuNRleze", date: "5th June, 2024", price: "₹ 90.2 Lakhs"),
    EstimateData(title: "Skyline Heights", date: "29th May, 2024", price: "₹ 3.4 Crores"),
    EstimateData(title: "Pearl Residency", date: "17th May, 2024", price: "₹ 1.0 Crore"),
    EstimateData(title: "Green Villa", date: "10th May, 2024", price: "₹ 68.5 Lakhs"),
  ];

  RecentEstimatesWidget(estimates: myEstimates)
*/