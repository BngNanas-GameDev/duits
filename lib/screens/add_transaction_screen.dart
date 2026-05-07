import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../data/transactions.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/palette.dart';

const List<String> expenseCategories = [
  'Belanja',
  'Tagihan',
  'Makanan',
  'Transportasi',
  'Hiburan',
  'Tabungan',
  'Lainnya',
];

const List<String> incomeCategories = ['Gaji Masuk', 'Transfer', 'Lainnya'];

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
  String? _selectedAccountId; // Optional account linkage
  bool _showAccountPicker = false; // Toggle for account dropdown
  bool _accountsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_accountsLoaded) {
      _accountsLoaded = true;
      final provider = context.read<TransactionProvider>();
      if (provider.accounts.isEmpty) {
        provider.loadAccounts();
      }
      // Default to first account (Dompet Utama)
      if (provider.accounts.isNotEmpty && _selectedAccountId == null) {
        _selectedAccountId = provider.accounts.first['id'] as String;
        if (mounted) setState(() {});
      }
    }
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
        _selectedAccountId = transaction.accountId;
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
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final palette = themeProvider.palette;

    return Scaffold(
      backgroundColor: palette.scaffoldBackground(isDark),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          children: [
            _Header(
              type: _type,
              isEditing: _isEditing,
              onBack: () => Navigator.maybePop(context),
              onTypeChanged: _handleTypeChange,
              isDark: isDark,
              palette: palette,
            ),
            _AmountInput(
              controller: _amountController,
              type: _type,
              onChanged: _handleAmountChange,
              isDark: isDark,
              palette: palette,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label('Rekening', isDark: isDark, palette: palette),
                  const SizedBox(height: 7),
                  _AccountSelector(
                    selectedAccountId: _selectedAccountId,
                    expanded: _showAccountPicker,
                    onTap: () => setState(
                      () => _showAccountPicker = !_showAccountPicker,
                    ),
                    onSelected: (accountId) {
                      setState(() {
                        _selectedAccountId = accountId;
                        _showAccountPicker = false;
                      });
                    },
                    isDark: isDark,
                    palette: palette,
                  ),
                  if (_showAccountPicker)
                    Consumer<TransactionProvider>(
                      builder: (context, provider, _) {
                        final accounts = provider.accounts;
                        if (accounts.isEmpty) {
                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: _fieldDecoration(isDark, palette),
                            child: Text(
                              'Belum ada rekening.',
                              style: TextStyle(
                                color: palette.secondaryText(isDark),
                              ),
                            ),
                          );
                        }
                        return _AccountDropdown(
                          accounts: accounts,
                          selectedAccountId: _selectedAccountId,
                          onSelected: (accountId) {
                            setState(() {
                              _selectedAccountId = accountId;
                              _showAccountPicker = false;
                            });
                          },
                          isDark: isDark,
                          palette: palette,
                        );
                      },
                    ),
                  const SizedBox(height: 18),
                  _Label('Kategori', isDark: isDark, palette: palette),
                  const SizedBox(height: 7),
                  _CategorySelector(
                    category: _category,
                    expanded: _showCategoryPicker,
                    onTap: () => setState(
                      () => _showCategoryPicker = !_showCategoryPicker,
                    ),
                    isDark: isDark,
                    palette: palette,
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
                      isDark: isDark,
                      palette: palette,
                    ),
                  const SizedBox(height: 18),
                  _Label('Judul Transaksi', isDark: isDark, palette: palette),
                  const SizedBox(height: 7),
                  _TextBox(
                    controller: _titleController,
                    hint: 'Contoh: Belanja mingguan',
                    onChanged: (_) => setState(() {}),
                    isDark: isDark,
                    palette: palette,
                  ),
                  const SizedBox(height: 18),
                  _Label(
                    'Detail / Keterangan (opsional)',
                    isDark: isDark,
                    palette: palette,
                  ),
                  const SizedBox(height: 7),
                  _TextBox(
                    controller: _detailController,
                    hint:
                        'Tambahkan detail pengeluaran, nama toko, atau catatan lainnya...',
                    maxLines: 4,
                    isDark: isDark,
                    palette: palette,
                  ),
                  const SizedBox(height: 18),
                  _Label('Tanggal', isDark: isDark, palette: palette),
                  const SizedBox(height: 7),
                  _DateSelector(
                    date: _selectedDate,
                    onTap: _selectDate,
                    isDark: isDark,
                    palette: palette,
                  ),
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

    final settings = context.read<SettingsProvider>();
    if (settings.txConfirmationEnabled) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          final themeProvider = context.read<ThemeProvider>();
          final isDark = themeProvider.isDarkMode;
          final palette = themeProvider.palette;
          final typeLabel = _type == 'income' ? 'Pemasukan' : 'Pengeluaran';
          return AlertDialog(
            backgroundColor: palette.cardColor(isDark),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              'Konfirmasi Transaksi',
              style: TextStyle(
                color: palette.text(isDark),
                fontWeight: FontWeight.w800,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Apakah sudah benar?',
                  style: TextStyle(
                    color: palette.secondaryText(isDark),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                _ConfirmationRow(
                  label: 'Jenis',
                  value: typeLabel,
                  isDark: isDark,
                  palette: palette,
                ),
                _ConfirmationRow(
                  label: 'Jumlah',
                  value: 'Rp${_amountController.text}',
                  isDark: isDark,
                  palette: palette,
                ),
                _ConfirmationRow(
                  label: 'Kategori',
                  value: _category,
                  isDark: isDark,
                  palette: palette,
                ),
                _ConfirmationRow(
                  label: 'Judul',
                  value: _titleController.text.trim(),
                  isDark: isDark,
                  palette: palette,
                ),
                if (_detailController.text.trim().isNotEmpty)
                  _ConfirmationRow(
                    label: 'Detail',
                    value: _detailController.text.trim(),
                    isDark: isDark,
                    palette: palette,
                  ),
                _ConfirmationRow(
                  label: 'Tanggal',
                  value: _selectedDate
                      .toIso8601String()
                      .split('T')
                      .first,
                  isDark: isDark,
                  palette: palette,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Batal',
                  style: TextStyle(color: palette.secondaryText(isDark)),
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text('Ya, Simpan'),
              ),
            ],
          );
        },
      );
      if (confirmed != true) return;
      if (!mounted) return;
    }

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
            accountId: _selectedAccountId,
          )
        : await provider.addTransaction(
            type: _type,
            category: _category,
            amount: double.parse(_amountRaw),
            title: _titleController.text.trim(),
            detail: _detailController.text.trim(),
            date: _selectedDate,
            accountId: _selectedAccountId,
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
  final bool isDark;
  final AppPalette palette;

  const _Header({
    required this.type,
    required this.isEditing,
    required this.onBack,
    required this.onTypeChanged,
    required this.isDark,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = palette.headerGradient(isDark);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
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
  final bool isDark;
  final AppPalette palette;

  const _AmountInput({
    required this.controller,
    required this.type,
    required this.onChanged,
    required this.isDark,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final color = type == 'income'
        ? const Color(0xFF00C48C)
        : const Color(0xFF6C63FF);
    return Container(
      width: double.infinity,
      color: palette.cardColor(isDark),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Column(
        children: [
          Text(
            'Jumlah',
            style: TextStyle(
              color: palette.secondaryText(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Rp',
                style: TextStyle(
                  color: palette.secondaryText(isDark),
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
                      style: TextStyle(
                        color: palette.text(isDark),
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: palette.secondaryText(isDark),
                        ),
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
  final bool isDark;
  final AppPalette palette;

  const _CategorySelector({
    required this.category,
    required this.expanded,
    required this.onTap,
    required this.isDark,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final color = categoryColors[category] ?? const Color(0xFF94A3B8);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _fieldDecoration(isDark, palette),
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
                style: TextStyle(
                  color: palette.text(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 180),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: palette.secondaryText(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountSelector extends StatelessWidget {
  final String? selectedAccountId;
  final bool expanded;
  final VoidCallback onTap;
  final ValueChanged<String> onSelected;
  final bool isDark;
  final AppPalette palette;

  const _AccountSelector({
    required this.selectedAccountId,
    required this.expanded,
    required this.onTap,
    required this.onSelected,
    required this.isDark,
    required this.palette,
  });

  String _getAccountName(BuildContext context, String? id) {
    final provider = context.watch<TransactionProvider>();
    if (id == null || provider.accounts.isEmpty) return 'Pilih Rekening';
    final account = provider.accounts.firstWhere(
      (a) => a['id'] == id,
      orElse: () => provider.accounts.first,
    );
    return account['name']?.toString() ?? 'Pilih Rekening';
  }

  IconData _getAccountIcon(BuildContext context, String? id) {
    final provider = context.watch<TransactionProvider>();
    if (id == null || provider.accounts.isEmpty) return Icons.account_balance_wallet_rounded;
    final account = provider.accounts.firstWhere(
      (a) => a['id'] == id,
      orElse: () => provider.accounts.first,
    );
    final type = (account['type'] as String? ?? '').toLowerCase();
    switch (type) {
      case 'cash':
      case 'dompet':
        return Icons.wallet_rounded;
      case 'debit card':
      case 'debit':
        return Icons.credit_card_rounded;
      case 'credit card':
      case 'credit':
        return Icons.credit_card_outlined;
      case 'e-wallet':
      case 'ewallet':
        return Icons.account_balance_wallet_rounded;
      case 'bank account':
      case 'bank':
        return Icons.account_balance_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final accountName = _getAccountName(context, selectedAccountId);
          final icon = _getAccountIcon(context, selectedAccountId);
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: _fieldDecoration(isDark, palette),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    accountName,
                    style: TextStyle(
                      color: palette.text(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: palette.secondaryText(isDark),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AccountDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> accounts;
  final String? selectedAccountId;
  final ValueChanged<String> onSelected;
  final bool isDark;
  final AppPalette palette;

  const _AccountDropdown({
    required this.accounts,
    required this.selectedAccountId,
    required this.onSelected,
    required this.isDark,
    required this.palette,
  });

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
      case 'dompet':
        return Icons.wallet_rounded;
      case 'debit card':
      case 'debit':
        return Icons.credit_card_rounded;
      case 'credit card':
      case 'credit':
        return Icons.credit_card_outlined;
      case 'e-wallet':
      case 'ewallet':
        return Icons.account_balance_wallet_rounded;
      case 'bank account':
      case 'bank':
        return Icons.account_balance_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: _fieldDecoration(isDark, palette),
      child: Column(
        children: [
          for (final account in accounts)
            ListTile(
              onTap: () => onSelected(account['id'] as String),
              leading: Icon(
                _getTypeIcon(account['type']?.toString() ?? ''),
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                account['name']?.toString() ?? '',
                style: TextStyle(
                  color: palette.text(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                (account['type']?.toString() ?? '').replaceFirstMapped(
                  RegExp(r'^\w'),
                  (m) => m.group(0)!.toUpperCase(),
                ),
                style: TextStyle(
                  fontSize: 11,
                  color: palette.secondaryText(isDark),
                ),
              ),
              trailing: selectedAccountId == account['id']
                  ? const Icon(Icons.check_rounded, color: Color(0xFF6C63FF))
                  : null,
            ),
        ],
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;
  final bool isDark;
  final AppPalette palette;

  const _CategoryDropdown({
    required this.categories,
    required this.selected,
    required this.onSelected,
    required this.isDark,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: _fieldDecoration(isDark, palette),
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
                style: TextStyle(
                  color: palette.text(isDark),
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
  final bool isDark;
  final AppPalette palette;

  const _TextBox({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.onChanged,
    required this.isDark,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(color: palette.text(isDark), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: palette.secondaryText(isDark),
          fontSize: 14,
        ),
        filled: true,
        fillColor: palette.cardColor(isDark),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: _inputBorder(palette.dividerColor(isDark)),
        enabledBorder: _inputBorder(palette.dividerColor(isDark)),
        focusedBorder: _inputBorder(const Color(0xFFC4B5FD)),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;
  final bool isDark;
  final AppPalette palette;

  const _DateSelector({
    required this.date,
    required this.onTap,
    required this.isDark,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final value = date.toIso8601String().split('T').first;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: _fieldDecoration(isDark, palette),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: palette.text(isDark),
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
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final palette = themeProvider.palette;
    return Scaffold(
      backgroundColor: palette.scaffoldBackground(isDark),
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
            Text(
              'Transaksi Disimpan!',
              style: TextStyle(
                color: palette.text(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Kembali ke halaman sebelumnya...',
              style: TextStyle(
                color: palette.secondaryText(isDark),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final bool isDark;
  final AppPalette palette;

  const _Label(this.text, {required this.isDark, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: palette.secondaryText(isDark),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ConfirmationRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final AppPalette palette;

  const _ConfirmationRow({
    required this.label,
    required this.value,
    required this.isDark,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: TextStyle(
                color: palette.secondaryText(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: palette.text(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _fieldDecoration(bool isDark, AppPalette palette) {
  return BoxDecoration(
    color: palette.cardColor(isDark),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: palette.dividerColor(isDark)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
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
    'Transfer' => Icons.swap_horiz_rounded,
    'Belanja' => Icons.shopping_bag_rounded,
    'Tagihan' => Icons.receipt_long_rounded,
    'Tabungan' => Icons.savings_rounded,
    'Makanan' => Icons.restaurant_rounded,
    'Transportasi' => Icons.directions_car_rounded,
    'Hiburan' => Icons.movie_rounded,
    _ => Icons.inventory_2_rounded,
  };
}
