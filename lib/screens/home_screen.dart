import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/transactions.dart';
import '../providers/auth_provider.dart';
import '../providers/couple_provider.dart';
import '../providers/transaction_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _balanceVisible = true;

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final coupleProvider = context.watch<CoupleProvider>();
    final auth = context.watch<AuthProvider>();
    final totalIncome = transactionProvider.totalIncome;
    final totalExpense = transactionProvider.totalSpendingExpense;
    final totalSavings = transactionProvider.totalSavings;
    final totalDebt = coupleProvider.netBalance.abs();
    final balance = transactionProvider.balance;
    final healthScore = totalIncome == 0
        ? 100
        : (100 - ((totalExpense / totalIncome) * 100).round()).clamp(0, 100);
    final recentTransactions = transactionProvider.sortedTransactions;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 104),
        child: Column(
          children: [
            _Header(
              name: auth.user?.userMetadata?['name']?.toString() ?? 'Pengguna',
              balance: balance,
              totalIncome: totalIncome,
              totalExpense: totalExpense,
              totalSavings: totalSavings,
              totalDebt: totalDebt,
              balanceVisible: _balanceVisible,
              onToggleBalance: () {
                setState(() => _balanceVisible = !_balanceVisible);
              },
            ),
            Transform.translate(
              offset: const Offset(0, -56),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _QuickActions(onOpenAdd: _openAddTransaction),
                    const SizedBox(height: 16),
                    _WeeklyChart(data: transactionProvider.weeklyData),
                    const SizedBox(height: 16),
                    _HealthCard(
                      score: healthScore,
                      spentRatio: totalIncome == 0
                          ? 0
                          : totalExpense / totalIncome,
                    ),
                    const SizedBox(height: 16),
                    _RecentTransactions(
                      transactions: recentTransactions.take(3).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddTransaction({String? type, String? category}) {
    Navigator.pushNamed(
      context,
      '/add',
      arguments: {'type': type, 'category': category},
    );
  }
}

class _Header extends StatelessWidget {
  final String name;
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final double totalSavings;
  final double totalDebt;
  final bool balanceVisible;
  final VoidCallback onToggleBalance;

  const _Header({
    required this.name,
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalSavings,
    required this.totalDebt,
    required this.balanceVisible,
    required this.onToggleBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 112),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF6C63FF)],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selamat Pagi',
                    style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const Text(
            'Total Saldo',
            style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  balanceVisible ? formatRupiah(balance) : 'Rp ********',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: balanceVisible ? 32 : 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: onToggleBalance,
                icon: Icon(
                  balanceVisible
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 18,
                ),
                color: const Color(0xFFC7D2FE),
              ),
            ],
          ),
          const Text(
            'Mei 2026',
            style: TextStyle(color: Color(0xFFA5B4FC), fontSize: 12),
          ),
          const SizedBox(height: 18),
          _SummaryGrid(
            items: [
              _SummaryItem(
                label: 'Pemasukan',
                value: formatRupiah(totalIncome),
                icon: Icons.trending_up_rounded,
                color: const Color(0xFF6EE7B7),
              ),
              _SummaryItem(
                label: 'Pengeluaran',
                value: formatRupiah(totalExpense),
                icon: Icons.trending_down_rounded,
                color: const Color(0xFFFCA5A5),
              ),
              _SummaryItem(
                label: 'Tabungan',
                value: formatRupiah(totalSavings),
                icon: Icons.savings_rounded,
                color: const Color(0xFFC4B5FD),
              ),
              _SummaryItem(
                label: 'Hutang',
                value: formatRupiah(totalDebt),
                icon: Icons.favorite_rounded,
                color: const Color(0xFFF9A8D4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final List<_SummaryItem> items;

  const _SummaryGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i += 2) ...[
          Row(
            children: [
              Expanded(child: _SummaryTile(item: items[i])),
              const SizedBox(width: 12),
              Expanded(child: _SummaryTile(item: items[i + 1])),
            ],
          ),
          if (i < items.length - 2) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SummaryItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _SummaryTile extends StatelessWidget {
  final _SummaryItem item;

  const _SummaryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    color: Color(0xFFC7D2FE),
                    fontSize: 10,
                  ),
                ),
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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

class _QuickActions extends StatelessWidget {
  final void Function({String? type, String? category}) onOpenAdd;

  const _QuickActions({required this.onOpenAdd});

  @override
  Widget build(BuildContext context) {
    final items = [
      _ActionItem(
        'Pemasukan',
        Icons.account_balance_wallet_rounded,
        const Color(0xFF00C48C),
        const Color(0xFFE8FFF6),
        () => onOpenAdd(type: 'income'),
      ),
      _ActionItem(
        'Pengeluaran',
        Icons.payments_rounded,
        const Color(0xFFFF6B6B),
        const Color(0xFFFFF0F0),
        () => onOpenAdd(type: 'expense'),
      ),
      _ActionItem(
        'Tabungan',
        Icons.savings_rounded,
        const Color(0xFF6C63FF),
        const Color(0xFFF0EEFF),
        () => onOpenAdd(category: 'Tabungan'),
      ),
      _ActionItem(
        'Tagihan',
        Icons.receipt_long_rounded,
        const Color(0xFFFFB347),
        const Color(0xFFFFF8ED),
        () => onOpenAdd(category: 'Tagihan'),
      ),
    ];

    return _Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) => _QuickActionButton(item: item)).toList(),
      ),
    );
  }
}

class _ActionItem {
  final String label;
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const _ActionItem(
    this.label,
    this.icon,
    this.color,
    this.background,
    this.onTap,
  );
}

class _QuickActionButton extends StatelessWidget {
  final _ActionItem item;

  const _QuickActionButton({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: item.background,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(item.icon, color: item.color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const _WeeklyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Aktivitas Minggu Ini',
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EEFF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Mingguan',
                  style: TextStyle(
                    color: Color(0xFF6C63FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFFF1F5F9),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
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
                        value == 0
                            ? '0'
                            : '${(value / 1000000).toStringAsFixed(1)}jt',
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
                            data[index]['day'] as String,
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
                lineBarsData: [
                  _line('income', const Color(0xFF00C48C)),
                  _line('expense', const Color(0xFF6C63FF)),
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
              _LegendDot(color: Color(0xFF6C63FF), label: 'Pengeluaran'),
            ],
          ),
        ],
      ),
    );
  }

  LineChartBarData _line(String key, Color color) {
    return LineChartBarData(
      spots: [
        for (var i = 0; i < data.length; i++)
          FlSpot(i.toDouble(), data[i][key] as double),
      ],
      isCurved: true,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          color: color,
          strokeWidth: 2,
          strokeColor: Colors.white,
          radius: 3,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.12),
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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

class _HealthCard extends StatelessWidget {
  final int score;
  final double spentRatio;

  const _HealthCard({required this.score, required this.spentRatio});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0EEFF), Color(0xFFEEF2FF)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kesehatan Keuangan',
                  style: TextStyle(
                    color: Color(0xFF818CF8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Kondisi Baik',
                  style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pengeluaranmu masih ${(spentRatio * 100).round()}% dari total pemasukan bulan ini.',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 6,
                  backgroundColor: const Color(0xFFE0D9FF),
                  color: const Color(0xFF6C63FF),
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  '$score%',
                  style: const TextStyle(
                    color: Color(0xFF6C63FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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

class _RecentTransactions extends StatelessWidget {
  final List<Transaction> transactions;

  const _RecentTransactions({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transaksi Terbaru',
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/transactions'),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.chevron_right_rounded, size: 16),
                label: const Text('Lihat Semua'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6C63FF),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          for (final tx in transactions) _TransactionRow(tx: tx),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final Transaction tx;

  const _TransactionRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == 'income';
    final color = categoryColors[tx.category] ?? const Color(0xFF94A3B8);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_categoryIcon(tx.category), color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  tx.detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${formatRupiah(tx.amount)}',
                style: TextStyle(
                  color: isIncome
                      ? const Color(0xFF00C48C)
                      : const Color(0xFFFF6B6B),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                formatDate(tx.date),
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
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
