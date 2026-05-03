import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/transactions.dart';
import '../providers/transaction_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _activeIndex = -1;

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final transactions = transactionProvider.transactions;
    final monthlyData = transactionProvider.monthlyData;
    final expenseByCategory = <String, double>{};
    for (final tx in transactions.where(
      (tx) => tx.type == 'expense' && tx.category != 'Tabungan',
    )) {
      expenseByCategory[tx.category] =
          (expenseByCategory[tx.category] ?? 0) + tx.amount;
    }

    final pieData = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalExpense = pieData.fold<double>(
      0,
      (sum, item) => sum + item.value,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 104),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 26),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analitik',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Insight keuangan Mei 2026',
                    style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 12),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const _SpendingRatioCard(),
                  const SizedBox(height: 16),
                  _PieCard(
                    data: pieData,
                    totalExpense: totalExpense,
                    activeIndex: _activeIndex,
                    onTouched: (index) => setState(() => _activeIndex = index),
                  ),
                  const SizedBox(height: 16),
                  _MonthlyBarCard(data: monthlyData),
                  const SizedBox(height: 16),
                  _TopSpendingCard(data: pieData),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendingRatioCard extends StatelessWidget {
  const _SpendingRatioCard();

  @override
  Widget build(BuildContext context) {
    const rows = [
      _RatioRow('Tagihan', 18, Color(0xFFFFB347)),
      _RatioRow('Belanja', 34, Color(0xFFFF6B6B)),
      _RatioRow('Transportasi', 11, Color(0xFF4ECDC4)),
      _RatioRow('Lainnya', 13, Color(0xFFA78BFA)),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4F46E5)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rasio Pengeluaran vs Pemasukan',
            style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 12),
          ),
          const SizedBox(height: 14),
          for (final row in rows) _RatioProgress(row: row),
        ],
      ),
    );
  }
}

class _RatioProgress extends StatelessWidget {
  final _RatioRow row;

  const _RatioProgress({required this.row});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              row.label,
              style: const TextStyle(color: Color(0xFFC7D2FE), fontSize: 10),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: row.percent / 100,
                minHeight: 7,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                color: row.color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 34,
            child: Text(
              '${row.percent}%',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PieCard extends StatelessWidget {
  final List<MapEntry<String, double>> data;
  final double totalExpense;
  final int activeIndex;
  final ValueChanged<int> onTouched;

  const _PieCard({
    required this.data,
    required this.totalExpense,
    required this.activeIndex,
    required this.onTouched,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Komposisi Pengeluaran',
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 210,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 48,
                sectionsSpace: 3,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    if (!event.isInterestedForInteractions ||
                        response?.touchedSection == null) {
                      onTouched(-1);
                      return;
                    }
                    onTouched(response!.touchedSection!.touchedSectionIndex);
                  },
                ),
                sections: [
                  for (var i = 0; i < data.length; i++)
                    PieChartSectionData(
                      value: data[i].value,
                      color:
                          (categoryColors[data[i].key] ??
                                  const Color(0xFF94A3B8))
                              .withValues(
                                alpha: activeIndex == -1 || activeIndex == i
                                    ? 1
                                    : 0.6,
                              ),
                      radius: activeIndex == i ? 88 : 80,
                      title: totalExpense == 0
                          ? ''
                          : '${((data[i].value / totalExpense) * 100).round()}%',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final item in data)
            _LegendLine(
              label: item.key,
              value: item.value,
              total: totalExpense,
              color: categoryColors[item.key] ?? const Color(0xFF94A3B8),
            ),
        ],
      ),
    );
  }
}

class _MonthlyBarCard extends StatelessWidget {
  final List<MonthlyPoint> data;

  const _MonthlyBarCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tren 5 Bulan Terakhir',
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 190,
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFFF1F5F9),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      getTitlesWidget: (value, meta) => Text(
                        '${(value / 1000000).round()}jt',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= data.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            data[index].month,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < data.length; i++)
                    BarChartGroupData(
                      x: i,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: data[i].income,
                          width: 9,
                          color: const Color(0xFF00C48C),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                        BarChartRodData(
                          toY: data[i].expense,
                          width: 9,
                          color: const Color(0xFFFF6B6B),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: Color(0xFF00C48C), label: 'Pemasukan'),
              SizedBox(width: 18),
              _LegendDot(color: Color(0xFFFF6B6B), label: 'Pengeluaran'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopSpendingCard extends StatelessWidget {
  final List<MapEntry<String, double>> data;

  const _TopSpendingCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxValue = data.isEmpty ? 1.0 : data.first.value;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengeluaran Terbesar',
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < data.take(4).length; i++)
            _TopSpendingRow(
              rank: i + 1,
              category: data[i].key,
              amount: data[i].value,
              progress: data[i].value / maxValue,
            ),
        ],
      ),
    );
  }
}

class _TopSpendingRow extends StatelessWidget {
  final int rank;
  final String category;
  final double amount;
  final double progress;

  const _TopSpendingRow({
    required this.rank,
    required this.category,
    required this.amount,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final color = categoryColors[category] ?? const Color(0xFF94A3B8);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_categoryIcon(category), color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formatRupiah(amount),
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFF1F5F9),
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendLine extends StatelessWidget {
  final String label;
  final double value;
  final double total;
  final Color color;

  const _LegendLine({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : ((value / total) * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 9),
          Icon(_categoryIcon(label), color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF475569), fontSize: 12),
          ),
          const Spacer(),
          Text(
            formatRupiah(value),
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '($percent%)',
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RatioRow {
  final String label;
  final int percent;
  final Color color;

  const _RatioRow(this.label, this.percent, this.color);
}

IconData _categoryIcon(String category) {
  return switch (category) {
    'Gaji Masuk' => Icons.work_rounded,
    'Belanja' => Icons.shopping_bag_rounded,
    'Tagihan' => Icons.receipt_long_rounded,
    'Tabungan' => Icons.savings_rounded,
    'Makanan' => Icons.restaurant_rounded,
    'Transportasi' => Icons.directions_car_rounded,
    'Hiburan' => Icons.movie_rounded,
    _ => Icons.inventory_2_rounded,
  };
}
