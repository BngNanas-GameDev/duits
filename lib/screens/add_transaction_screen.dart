import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../data/transactions.dart';
import '../providers/transaction_provider.dart';

const List<String> expenseCategories = [
  'Belanja',
  'Tagihan',
  'Makanan',
  'Transportasi',
  'Hiburan',
  'Tabungan',
  'Lainnya',
];

const List<String> incomeCategories = ['Gaji Masuk', 'Lainnya'];

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();

  String _type = 'expense';
  String _category = 'Belanja';
  String _amountRaw = '';
  DateTime _selectedDate = DateTime.now();
  bool _showCategoryPicker = false;
  bool _showSuccess = false;
  bool _argumentsApplied = false;
  Transaction? _editingTransaction;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentsApplied) return;
    _argumentsApplied = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final transaction = args['transaction'];
      if (transaction is Transaction) {
        _editingTransaction = transaction;
        _type = transaction.type;
        _category = transaction.category;
        _amountRaw = transaction.amount.toInt().toString();
        _amountController.text = _formatAmount(_amountRaw);
        _titleController.text = transaction.title;
        _detailController.text = transaction.detail;
        _selectedDate = DateTime.tryParse(transaction.date) ?? DateTime.now();
        return;
      }

      final type = args['type'];
      final category = args['category'];
      if (type == 'income' || type == 'expense') {
        _type = type as String;
      }
      if (category is String && _allCategories.contains(category)) {
        _category = category;
        if (type != 'income' && type != 'expense') {
          _type = 'expense';
        }
      } else {
        _category = _type == 'income' ? 'Gaji Masuk' : 'Belanja';
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  List<String> get _currentCategories =>
      _type == 'income' ? incomeCategories : expenseCategories;
  List<String> get _allCategories => [
    ...incomeCategories,
    ...expenseCategories,
  ];
  bool get _isFormValid =>
      _amountRaw.isNotEmpty && _titleController.text.trim().isNotEmpty;
  bool get _isEditing => _editingTransaction != null;

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) return const _SuccessView();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          children: [
            _Header(
              type: _type,
              isEditing: _isEditing,
              onBack: () => Navigator.maybePop(context),
              onTypeChanged: _handleTypeChange,
            ),
            _AmountInput(
              controller: _amountController,
              type: _type,
              onChanged: _handleAmountChange,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label('Kategori'),
                  const SizedBox(height: 7),
                  _CategorySelector(
                    category: _category,
                    expanded: _showCategoryPicker,
                    onTap: () => setState(
                      () => _showCategoryPicker = !_showCategoryPicker,
                    ),
                  ),
                  if (_showCategoryPicker)
                    _CategoryDropdown(
                      categories: _currentCategories,
                      selected: _category,
                      onSelected: (category) {
                        setState(() {
                          _category = category;
                          _showCategoryPicker = false;
                        });
                      },
                    ),
                  const SizedBox(height: 18),
                  _Label('Judul Transaksi'),
                  const SizedBox(height: 7),
                  _TextBox(
                    controller: _titleController,
                    hint: 'Contoh: Belanja mingguan',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 18),
                  const _Label('Detail / Keterangan (opsional)'),
                  const SizedBox(height: 7),
                  _TextBox(
                    controller: _detailController,
                    hint:
                        'Tambahkan detail pengeluaran, nama toko, atau catatan lainnya...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 18),
                  const _Label('Tanggal'),
                  const SizedBox(height: 7),
                  _DateSelector(date: _selectedDate, onTap: _selectDate),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: _isFormValid ? _handleSubmit : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        disabledBackgroundColor: const Color(0xFFE2E8F0),
                        disabledForegroundColor: const Color(0xFF94A3B8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Simpan Transaksi',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTypeChange(String newType) {
    setState(() {
      _type = newType;
      _category = newType == 'income' ? 'Gaji Masuk' : 'Belanja';
      _showCategoryPicker = false;
    });
  }

  void _handleAmountChange(String value) {
    final clean = value.replaceAll(RegExp(r'\D'), '');
    _amountRaw = clean;

    final formatted = _formatAmount(clean);
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    setState(() {});
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF6C63FF)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _handleSubmit() async {
    if (!_isFormValid) return;
    FocusScope.of(context).unfocus();

    final provider = context.read<TransactionProvider>();
    final saved = _isEditing
        ? await provider.updateTransaction(
            id: _editingTransaction!.id,
            type: _type,
            category: _category,
            amount: double.parse(_amountRaw),
            title: _titleController.text.trim(),
            detail: _detailController.text.trim(),
            date: _selectedDate,
          )
        : await provider.addTransaction(
            type: _type,
            category: _category,
            amount: double.parse(_amountRaw),
            title: _titleController.text.trim(),
            detail: _detailController.text.trim(),
            date: _selectedDate,
          );

    if (!mounted) return;
    if (!saved) {
      final message =
          context.read<TransactionProvider>().errorMessage ??
          (_isEditing
              ? 'Transaksi gagal diubah.'
              : 'Transaksi gagal disimpan.');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    setState(() => _showSuccess = true);
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (mounted) Navigator.pop(context);
    });
  }

  String _formatAmount(String clean) {
    return clean.isEmpty
        ? ''
        : clean.replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (match) => '${match[1]}.',
          );
  }
}

class _Header extends StatelessWidget {
  final String type;
  final bool isEditing;
  final VoidCallback onBack;
  final ValueChanged<String> onTypeChanged;

  const _Header({
    required this.type,
    required this.isEditing,
    required this.onBack,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
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
                onPressed: onBack,
                icon: const Icon(Icons.chevron_left_rounded),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isEditing ? 'Edit Transaksi' : 'Tambah Transaksi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                _TypeButton(
                  label: 'Pengeluaran',
                  icon: Icons.payments_rounded,
                  active: type == 'expense',
                  color: const Color(0xFFFF6B6B),
                  onTap: () => onTypeChanged('expense'),
                ),
                _TypeButton(
                  label: 'Pemasukan',
                  icon: Icons.account_balance_wallet_rounded,
                  active: type == 'income',
                  color: const Color(0xFF00C48C),
                  onTap: () => onTypeChanged('income'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: active ? color : Colors.white70),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: active ? color : Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final String type;
  final ValueChanged<String> onChanged;

  const _AmountInput({
    required this.controller,
    required this.type,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = type == 'income'
        ? const Color(0xFF00C48C)
        : const Color(0xFF6C63FF);
    return Container(
      width: double.infinity,
      color: const Color(0xFFF8F7FF),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Column(
        children: [
          const Text(
            'Jumlah',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Rp',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 80,
                      maxWidth: 260,
                    ),
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: 120,
            height: 2,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final String category;
  final bool expanded;
  final VoidCallback onTap;

  const _CategorySelector({
    required this.category,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = categoryColors[category] ?? const Color(0xFF94A3B8);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _fieldDecoration(),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_categoryIcon(category), color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 180),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  const _CategoryDropdown({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: _fieldDecoration(),
      child: Column(
        children: [
          for (final category in categories)
            ListTile(
              onTap: () => onSelected(category),
              leading: Icon(
                _categoryIcon(category),
                color: categoryColors[category],
              ),
              title: Text(
                category,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: selected == category
                  ? const Icon(Icons.check_rounded, color: Color(0xFF6C63FF))
                  : null,
            ),
        ],
      ),
    );
  }
}

class _TextBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const _TextBox({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(color: Color(0xFF1F2937), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: _inputBorder(const Color(0xFFF1F5F9)),
        enabledBorder: _inputBorder(const Color(0xFFF1F5F9)),
        focusedBorder: _inputBorder(const Color(0xFFC4B5FD)),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _DateSelector({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final value = date.toIso8601String().split('T').first;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: _fieldDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.calendar_month_rounded, color: Color(0xFF6C63FF)),
          ],
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00C48C), Color(0xFF00A877)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Transaksi Disimpan!',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Kembali ke halaman sebelumnya...',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

BoxDecoration _fieldDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: const Color(0xFFF1F5F9)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

OutlineInputBorder _inputBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: BorderSide(color: color),
  );
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
