import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MainChart extends StatelessWidget {
  MainChart({super.key});

  // --- DEFINED DATA LISTS ---
  final List<double> actualCosts = [1.5, 3.0, 2.5, 1.8, 4.2, 2.8, 3.5, 4.0];
  final List<FlSpot> predictedSpots = const [
    FlSpot(0, 1.2),
    FlSpot(1, 2.8),
    FlSpot(2, 2.1),
    FlSpot(3, 3.2),
    FlSpot(4, 3.9),
    FlSpot(5, 3.4),
    FlSpot(6, 4.8),
    FlSpot(7, 5.5),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. The Bar Chart (Actual Costs - Orange Bars)
        BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 6,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
            ),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: actualCosts.asMap().entries.map((e) {
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value,
                    color: Colors.orange.shade400,
                    width: 16,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),

        // 2. The Line Chart (Predicted Costs - Blue Line) layered on top
        LineChart(
          LineChartData(
            maxY: 6,
            gridData: const FlGridData(
              show: false,
            ), // Hide grid to avoid double lines
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: predictedSpots,
                isCurved: true,
                color: const Color(0xFF0066FF),
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                        radius: 3,
                        color: const Color(0xFF0066FF),
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
