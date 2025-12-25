import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DonutChart extends StatelessWidget {
  const DonutChart({super.key});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 5,
        centerSpaceRadius: 50,
        sections: [
          PieChartSectionData(
            color: Colors.blue,
            value: 60,
            showTitle: false,
            radius: 20,
          ),
          PieChartSectionData(
            color: Colors.teal,
            value: 25,
            showTitle: false,
            radius: 20,
          ),
          PieChartSectionData(
            color: Colors.orange,
            value: 15,
            showTitle: false,
            radius: 20,
          ),
        ],
      ),
    );
  }
}
