import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/auth_provider.dart';
import 'add_account_screen.dart';

class ManageAccountsScreen extends StatefulWidget {
  const ManageAccountsScreen({super.key});

  @override
  State<ManageAccountsScreen> createState() => _ManageAccountsScreenState();
}

class _ManageAccountsScreenState extends State<ManageAccountsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _accounts = [];
  String _error = '';

  // Track expanded account IDs for showing actions
  final Set<String> _expandedAccounts = {};

  // Store current balance cache: accountId -> computed balance
  final Map<String, double> _balances = {};

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  SupabaseClient get _supabase => Supabase.instance.client;

  Future<void> _loadAccounts() async {
    final auth = context.read<AuthProvider>();
    final userId = auth.userId;
    if (userId == null) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await _supabase
          .from('accounts')
          .select('id, name, type, opening_balance, created_at')
          .eq('user_id', userId)
          .isFilter('archived_at', null)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _accounts = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
        _computeBalances();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat rekening: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _computeBalances() async {
    final auth = context.read<AuthProvider>();
    final userId = auth.userId;
    if (userId == null) return;

    final balances = <String, double>{};

    for (final account in _accounts) {
      final accountId = account['id'] as String;
      final openingBalance =
          (account['opening_balance'] as num?)?.toDouble() ?? 0.0;

      try {
        final incomeResult = await _supabase
            .from('transactions')
            .select('amount')
            .eq('user_id', userId)
            .eq('account_id', accountId)
            .eq('type', 'income');
        
        final incomeSum = incomeResult.fold<double>(
            0,
            (sum, tx) => sum + ((tx['amount'] as num?)?.toDouble() ?? 0.0));

        final expenseResult = await _supabase
            .from('transactions')
            .select('amount')
            .eq('user_id', userId)
            .eq('account_id', accountId)
            .eq('type', 'expense');

        final expenseSum = expenseResult.fold<double>(
            0,
            (sum, tx) => sum + ((tx['amount'] as num?)?.toDouble() ?? 0.0));

        balances[accountId] = openingBalance + incomeSum - expenseSum;
      } catch (e) {
        balances[accountId] = openingBalance;
      }
    }

    if (mounted) {
      setState(() {
        _balances.addAll(balances);
      });
    }
  }

  Future<void> _deleteAccount(String accountName, String accountId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Rekening?'),
        content: Text('Apakah Anda yakin ingin menghapus "$accountName"?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Hapus'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _supabase
          .from('accounts')
          .update({'archived_at': DateTime.now().toIso8601String()})
          .eq('id', accountId);

      if (mounted) {
        setState(() {
          _accounts.removeWhere((a) => a['id'] == accountId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rekening berhasil dihapus.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Rekening'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Tambah Rekening',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddAccountScreen(),
                ),
              );
              if (mounted) {
                _loadAccounts();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          color: const Color(0xFFEF4444), size: 48),
                      const SizedBox(height: 12),
                      Text(
                        _error,
                        style: const TextStyle(color: Color(0xFF64748B)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _loadAccounts,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _accounts.isEmpty
                  ? _EmptyState(onAdd: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddAccountScreen(),
                        ),
                      );
                      if (mounted) _loadAccounts();
                    })
                  : RefreshIndicator(
                      onRefresh: () async => _loadAccounts(),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        itemCount: _accounts.length,
                        itemBuilder: (context, index) {
                          final account = _accounts[index];
                          final accountId = account['id'] as String;
                          final accountName = account['name'] as String;
                          final accountType = account['type'] as String;
                          final isExpanded =
                              _expandedAccounts.contains(accountId);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 2,
                            shadowColor: Colors.black.withValues(alpha: 0.06),
                            child: Column(
                              children: [
                                ListTile(
                                  onTap: () {
                                    setState(() {
                                      if (isExpanded) {
                                        _expandedAccounts.remove(accountId);
                                      } else {
                                        _expandedAccounts.add(accountId);
                                      }
                                    });
                                  },
                                  leading: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: _getTypeColor(accountType)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      _getTypeIcon(accountType),
                                      color: _getTypeColor(accountType),
                                      size: 22,
                                    ),
                                  ),
                                  title: Text(
                                    accountName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  subtitle: Text(
                                    _getTypeLabel(accountType),
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatRupiah(
                                            _balances[accountId] ?? 0.0),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Icon(
                                        isExpanded
                                            ? Icons
                                                .expand_less_rounded
                                            : Icons.chevron_right_rounded,
                                        size: 18,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isExpanded)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        72, 0, 16, 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.end,
                                      children: [
                                        OutlinedButton.icon(
                                          icon: const Icon(Icons.edit_rounded,
                                              size: 16),
                                          label:
                                              const Text('Edit'),
                                          onPressed: () {
                                            _showEditDialog(account);
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        FilledButton.icon(
                                          icon: const Icon(Icons.delete_rounded,
                                              size: 16),
                                          label: const Text('Hapus'),
                                          style: FilledButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFEF4444),
                                          ),
                                          onPressed: () => _deleteAccount(
                                              accountName, accountId),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  void _showEditDialog(Map<String, dynamic> account) {
    final nameController =
        TextEditingController(text: account['name'] as String);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Rekening'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Nama Rekening',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(ctx),
          ),
          FilledButton(
            child: const Text('Simpan'),
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) return;
              try {
                await _supabase
                    .from('accounts')
                    .update({'name': newName})
                    .eq('id', account['id'] as String);
                if (mounted) {
                  Navigator.pop(ctx);
                  _loadAccounts();
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal mengedit: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
      case 'dompet':
        return Icons.wallet_rounded;
      case 'debit':
      case 'debit card':
        return Icons.credit_card_rounded;
      case 'credit':
      case 'credit card':
        return Icons.credit_card_outlined;
      case 'e-wallet':
      case 'ewallet':
        return Icons.account_balance_wallet_rounded;
      case 'bank':
      case 'bank account':
        return Icons.account_balance_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
      case 'dompet':
        return const Color(0xFF6C63FF);
      case 'debit':
      case 'debit card':
        return const Color(0xFF009688);
      case 'credit':
      case 'credit card':
        return const Color(0xFFEF4444);
      case 'e-wallet':
      case 'ewallet':
        return const Color(0xFFFF6B9D);
      case 'bank':
      case 'bank account':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF6C63FF);
    }
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
        return 'Dompet / Cash';
      case 'debit card':
      case 'debit':
        return 'Kartu Debit';
      case 'credit card':
      case 'credit':
        return 'Kartu Kredit';
      case 'e-wallet':
      case 'ewallet':
        return 'E-Wallet';
      case 'bank account':
      case 'bank':
        return 'Rekening Bank';
      default:
        return type;
    }
  }

  String _formatRupiah(double amount) {
    if (amount < 0) {
      return '-Rp${(amount.abs()).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
    }
    return 'Rp${(amount.abs()).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_balance_wallet_rounded,
                size: 40, color: const Color(0xFF6C63FF)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum ada rekening.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan rekening untuk mengelola transaksi.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah Rekening'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
