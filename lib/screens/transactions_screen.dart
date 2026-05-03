import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/transactions.dart';
import '../providers/transaction_provider.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  static const List<String> _allCategories = [
    'Gaji Masuk',
    'Belanja',
    'Tagihan',
    'Tabungan',
    'Makanan',
    'Transportasi',
    'Hiburan',
    'Lainnya',
  ];

  String _search = '';
  String _filter = 'all';
  String _selectedCategory = 'all';
  bool _showFilter = false;

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final sorted = transactionProvider.sortedTransactions;

    final filtered = sorted.where((tx) {
      final query = _search.toLowerCase();
      final matchSearch =
          tx.title.toLowerCase().contains(query) ||
          tx.detail.toLowerCase().contains(query);
      final matchType = _filter == 'all' || tx.type == _filter;
      final matchCategory =
          _selectedCategory == 'all' || tx.category == _selectedCategory;
      return matchSearch && matchType && matchCategory;
    }).toList();

    final grouped = <String, List<Transaction>>{};
    for (final tx in filtered) {
      grouped.putIfAbsent(tx.date, () => []).add(tx);
    }

    final totalIncome = filtered
        .where((tx) => tx.type == 'income')
        .fold<double>(0, (sum, tx) => sum + tx.amount);
    final totalExpense = filtered
        .where((tx) => tx.type == 'expense')
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Header(
              totalIncome: totalIncome,
              totalExpense: totalExpense,
              count: filtered.length,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SearchBar(
                  showFilter: _showFilter,
                  onSearch: (value) => setState(() => _search = value),
                  onToggleFilter: () =>
                      setState(() => _showFilter = !_showFilter),
                ),
                if (_showFilter) ...[
                  const SizedBox(height: 12),
                  _FilterPanel(
                    filter: _filter,
                    selectedCategory: _selectedCategory,
                    categories: _allCategories,
                    onFilterChanged: (value) => setState(() => _filter = value),
                    onCategoryChanged: (value) =>
                        setState(() => _selectedCategory = value),
                  ),
                ],
                const SizedBox(height: 14),
                if (grouped.isEmpty)
                  const _EmptyState()
                else
                  ...grouped.entries.map(
                    (entry) => _DateGroup(
                      date: entry.key,
                      transactions: entry.value,
                      onSelect: _showDetail,
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(Transaction tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => _DetailSheet(tx: tx, pageContext: context),
    );
  }
}

class _Header extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final int count;

  const _Header({
    required this.totalIncome,
    required this.totalExpense,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.chevron_left_rounded),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Riwayat Transaksi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: 'Total Masuk',
                  value: formatRupiah(totalIncome),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryMetric(
                  label: 'Total Keluar',
                  value: formatRupiah(totalExpense),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryMetric(label: 'Transaksi', value: '$count Item'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFFC7D2FE), fontSize: 10),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final bool showFilter;
  final ValueChanged<String> onSearch;
  final VoidCallback onToggleFilter;

  const _SearchBar({
    required this.showFilter,
    required this.onSearch,
    required this.onToggleFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'Cari transaksi...',
              hintStyle: const TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFF6C63FF)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 52,
          height: 52,
          child: IconButton(
            onPressed: onToggleFilter,
            icon: Icon(
              Icons.filter_list_rounded,
              color: showFilter ? Colors.white : const Color(0xFF6C63FF),
            ),
            style: IconButton.styleFrom(
              backgroundColor: showFilter
                  ? const Color(0xFF6C63FF)
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xFFF1F5F9)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterPanel extends StatelessWidget {
  final String filter;
  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onCategoryChanged;

  const _FilterPanel({
    required this.filter,
    required this.selectedCategory,
    required this.categories,
    required this.onFilterChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jenis Transaksi',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: 'Semua',
                value: 'all',
                selected: filter == 'all',
                onSelected: onFilterChanged,
              ),
              _FilterChip(
                label: 'Pemasukan',
                value: 'income',
                selected: filter == 'income',
                onSelected: onFilterChanged,
              ),
              _FilterChip(
                label: 'Pengeluaran',
                value: 'expense',
                selected: filter == 'expense',
                onSelected: onFilterChanged,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Kategori',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CategoryChip(
                label: 'Semua',
                color: const Color(0xFF64748B),
                selected: selectedCategory == 'all',
                onTap: () => onCategoryChanged('all'),
              ),
              for (final category in categories)
                _CategoryChip(
                  label: category,
                  color: categoryColors[category] ?? const Color(0xFF64748B),
                  selected: selectedCategory == category,
                  onTap: () => onCategoryChanged(category),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final ValueChanged<String> onSelected;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(value),
      selectedColor: const Color(0xFF6C63FF),
      backgroundColor: const Color(0xFFF8F7FF),
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xFF6C63FF),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide.none,
      ),
      showCheckmark: false,
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DateGroup extends StatelessWidget {
  final String date;
  final List<Transaction> transactions;
  final ValueChanged<Transaction> onSelect;

  const _DateGroup({
    required this.date,
    required this.transactions,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                formatDate(date),
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
              const SizedBox(width: 12),
              Text(
                '${transactions.length} transaksi',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                for (var i = 0; i < transactions.length; i++) ...[
                  _TransactionTile(
                    tx: transactions[i],
                    onTap: () => onSelect(transactions[i]),
                  ),
                  if (i < transactions.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 1, color: Color(0xFFF8FAFC)),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction tx;
  final VoidCallback onTap;

  const _TransactionTile({required this.tx, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == 'income';
    final color = categoryColors[tx.category] ?? const Color(0xFF94A3B8);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          tx.category,
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        formatDate(tx.date),
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                        ),
                      ),
                    ],
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
                  tx.time,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  final Transaction tx;
  final BuildContext pageContext;

  const _DetailSheet({required this.tx, required this.pageContext});

  @override
  Widget build(BuildContext context) {
    final color = categoryColors[tx.category] ?? const Color(0xFF94A3B8);
    final isIncome = tx.type == 'income';
    final typeColor = isIncome
        ? const Color(0xFF00C48C)
        : const Color(0xFFFF6B6B);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    _categoryIcon(tx.category),
                    color: color,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          tx.category,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        tx.title,
                        style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Text(
                    'Jumlah',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isIncome ? '+' : '-'}${formatRupiah(tx.amount)}',
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _DetailLine(label: 'Tanggal', value: formatDate(tx.date)),
            _DetailLine(label: 'Waktu', value: '${tx.time} WIB'),
            _DetailLine(
              label: 'Jenis',
              value: isIncome ? 'Pemasukan' : 'Pengeluaran',
              color: typeColor,
            ),
            const SizedBox(height: 8),
            const Text(
              'Keterangan',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                tx.detail,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        pageContext,
                        '/add',
                        arguments: {'transaction': tx},
                      );
                    },
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6C63FF),
                      side: const BorderSide(color: Color(0xFFC4B5FD)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _confirmCancel(context),
                    icon: const Icon(Icons.undo_rounded, size: 18),
                    label: const Text('Batalkan'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batalkan transaksi?'),
        content: const Text(
          'Transaksi akan dihapus dari riwayat dan perhitungan saldo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
            ),
            child: const Text('Batalkan Transaksi'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final ok = await context.read<TransactionProvider>().cancelTransaction(
      tx.id,
    );
    if (!context.mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(pageContext).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil dibatalkan.')),
      );
    } else {
      final message =
          context.read<TransactionProvider>().errorMessage ??
          'Transaksi gagal dibatalkan.';
      ScaffoldMessenger.of(
        pageContext,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _DetailLine({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? const Color(0xFF334155),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 54, color: Color(0xFFCBD5E1)),
          SizedBox(height: 12),
          Text(
            'Tidak ada transaksi',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Coba ubah filter atau pencarian',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
        ],
      ),
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
