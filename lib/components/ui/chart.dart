import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// --- ChartConfig (Mirip dengan type ChartConfig di React) ---
class ChartConfig {
  final String label;
  final Color color;
  final IconData? icon;

  ChartConfig({required this.label, required this.color, this.icon});
}

class AppChartContainer extends StatelessWidget {
  final String title;
  final Widget chart;
  final Map<String, ChartConfig> config;

  const AppChartContainer({
    super.key,
    required this.title,
    required this.chart,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),
          AspectRatio(aspectRatio: 1.7, child: chart),
          const SizedBox(height: 16),
          // --- ChartLegendContent ---
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: config.entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: entry.value.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    entry.value.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// --- Tooltip & Style Helper ---
class ChartStyle {
  static FlGridData gridData = FlGridData(
    show: true,
    drawVerticalLine: false,
    getDrawingHorizontalLine: (value) =>
        FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 1),
  );

  static FlTitlesData titlesData(List<String> bottomLabels) => FlTitlesData(
    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          int index = value.toInt();
          if (index >= 0 && index < bottomLabels.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                bottomLabels[index],
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    ),
  );
}
