import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/transactions.dart';

class TransactionProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  StreamSubscription<AuthState>? _authSubscription;
  bool _isLoading = false;
  String? _errorMessage;
  List<Transaction> _transactions = [];
  List<Map<String, dynamic>> _accounts = [];

  TransactionProvider() {
    _authSubscription = _supabase.auth.onAuthStateChange.listen((_) {
      loadTransactions();
      loadAccounts();
    });
    loadTransactions();
    loadAccounts();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<Map<String, dynamic>> get accounts => List.unmodifiable(_accounts);

  /// Get the first (default) account for quick operations.
  Map<String, dynamic>? get defaultAccount {
    if (_accounts.isEmpty) return null;
    return _accounts.first;
  }

  double get totalIncome => _transactions
      .where((tx) => tx.type == 'income')
      .fold<double>(0, (sum, tx) => sum + tx.amount);

  double get totalExpense => _transactions
      .where((tx) => tx.type == 'expense')
      .fold<double>(0, (sum, tx) => sum + tx.amount);

  double get totalSavings => _transactions
      .where((tx) => tx.category == 'Tabungan')
      .fold<double>(0, (sum, tx) => sum + tx.amount);

  double get totalSpendingExpense => _transactions
      .where((tx) => tx.type == 'expense' && tx.category != 'Tabungan')
      .fold<double>(0, (sum, tx) => sum + tx.amount);

  double get balance => totalIncome - totalSpendingExpense - totalSavings;

  /// Get the account-based balance for a specific account.
  /// opening_balance + income - expense for accounts with account_id linkage.
  double getAccountBalance(String accountId) {
    final account = _accounts.firstWhere(
      (a) => a['id'] == accountId,
      orElse: () => {},
    );
    if (account.isEmpty) return 0.0;

    final openingBalance =
        (account['opening_balance'] as num?)?.toDouble() ?? 0.0;

    final accountTransactions = _transactions.where(
      (tx) => tx.accountId == accountId,
    );

    final income = accountTransactions
        .where((tx) => tx.type == 'income')
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    final expense = accountTransactions
        .where((tx) => tx.type == 'expense')
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    return openingBalance + income - expense;
  }

  /// Sum all account balances (opening_balance + income - expense per account).
  double getAccountBalanceTotal() {
    return _accounts.fold<double>(
      0,
      (sum, account) => sum + getAccountBalance(account['id'] as String),
    );
  }

  List<Transaction> get sortedTransactions {
    final sorted = [..._transactions]
      ..sort((a, b) => '${b.date} ${b.time}'.compareTo('${a.date} ${a.time}'));
    return sorted;
  }

  List<Map<String, dynamic>> get weeklyData {
    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    const dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return List.generate(7, (index) {
      final date = start.add(Duration(days: index));
      final dateKey = _dateKey(date);
      final dayTransactions = _transactions.where((tx) => tx.date == dateKey);
      return {
        'day': dayLabels[index],
        'income': dayTransactions
            .where((tx) => tx.type == 'income')
            .fold<double>(0, (sum, tx) => sum + tx.amount),
        'expense': dayTransactions
            .where((tx) => tx.type == 'expense' && tx.category != 'Tabungan')
            .fold<double>(0, (sum, tx) => sum + tx.amount),
      };
    });
  }

  List<MonthlyPoint> get monthlyData {
    final now = DateTime.now();
    final months = List.generate(5, (index) {
      return DateTime(now.year, now.month - (4 - index), 1);
    });

    return months.map((month) {
      final monthKey =
          '${month.year}-${month.month.toString().padLeft(2, '0')}';
      final monthTransactions = _transactions.where(
        (tx) => tx.date.startsWith(monthKey),
      );
      return MonthlyPoint(
        shortMonthName(month.month),
        monthTransactions
            .where((tx) => tx.type == 'income')
            .fold<double>(0, (sum, tx) => sum + tx.amount),
        monthTransactions
            .where((tx) => tx.type == 'expense' && tx.category != 'Tabungan')
            .fold<double>(0, (sum, tx) => sum + tx.amount),
      );
    }).toList();
  }

  Future<void> loadTransactions() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      _transactions = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final rows = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .filter('deleted_at', 'is', null)
          .order('transaction_date', ascending: false)
          .order('transaction_time', ascending: false);

      _transactions = rows
          .map<Transaction>((row) => Transaction.fromSupabase(row))
          .toList();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat transaksi: $e';
      debugPrint(_errorMessage);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addTransaction({
    required String type,
    required String category,
    required double amount,
    required String title,
    required String detail,
    required DateTime date,
    String? accountId,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      _errorMessage = 'Login dulu sebelum menyimpan transaksi.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      final now = DateTime.now();
      final row = await _supabase
          .from('transactions')
          .insert({
            'user_id': userId,
            'type': type,
            'category_name': category,
            'amount': amount,
            'title': title,
            'detail': detail,
            'transaction_date': _dateKey(date),
            'transaction_time':
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
            'account_id': ?accountId,
          })
          .select()
          .single();

      _transactions = [Transaction.fromSupabase(row), ..._transactions];
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menyimpan transaksi: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateTransaction({
    required String id,
    required String type,
    required String category,
    required double amount,
    required String title,
    required String detail,
    required DateTime date,
    String? accountId,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      _errorMessage = 'Login dulu sebelum mengubah transaksi.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      final row = await _supabase
          .from('transactions')
          .update({
            'type': type,
            'category_name': category,
            'amount': amount,
            'title': title,
            'detail': detail,
            'transaction_date': _dateKey(date),
            'account_id': ?accountId,
          })
          .eq('id', id)
          .eq('user_id', userId)
          .select()
          .single();

      final updated = Transaction.fromSupabase(row);
      _transactions = _transactions
          .map((tx) => tx.id == id ? updated : tx)
          .toList();
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengubah transaksi: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelTransaction(String id) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      _errorMessage = 'Login dulu sebelum membatalkan transaksi.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      await _supabase
          .from('transactions')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', id)
          .eq('user_id', userId);

      _transactions = _transactions.where((tx) => tx.id != id).toList();
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal membatalkan transaksi: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ===== ACCOUNT MANAGEMENT =====

  /// Load all accounts for the current user.
  Future<void> loadAccounts() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      _accounts = [];
      notifyListeners();
      return;
    }

    try {
      final rows = await _supabase
          .from('accounts')
          .select()
          .eq('user_id', userId)
          .filter('archived_at', 'is', null)
          .order('created_at', ascending: false);

      _accounts = List<Map<String, dynamic>>.from(rows);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load accounts: $e');
    }
  }

  /// Add a new account for the current user.
  Future<bool> addAccount({
    required String name,
    required String type,
    double openingBalance = 0.0,
    String currency = 'IDR',
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      _errorMessage = 'Login dulu sebelum menambahkan rekening.';
      notifyListeners();
      return false;
    }

    try {
      await _supabase.from('accounts').insert({
        'user_id': userId,
        'name': name,
        'type': type,
        'opening_balance': openingBalance,
        'currency': currency,
      });
      await loadAccounts();
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambahkan rekening: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  /// Update an existing account's name or opening_balance.
  Future<bool> updateAccount({
    required String id,
    String? name,
    String? type,
    double? openingBalance,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      _errorMessage = 'Login dulu sebelum mengubah rekening.';
      notifyListeners();
      return false;
    }

    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (type != null) updates['type'] = type;
      if (openingBalance != null) updates['opening_balance'] = openingBalance;

      if (updates.isEmpty) return true;

      await _supabase
          .from('accounts')
          .update(updates)
          .eq('id', id)
          .eq('user_id', userId);

      await loadAccounts();
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengubah rekening: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  /// Soft-delete an account via archived_at timestamp.
  Future<bool> archiveAccount(String id) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      _errorMessage = 'Login dulu sebelum menghapus rekening.';
      notifyListeners();
      return false;
    }

    try {
      await _supabase
          .from('accounts')
          .update({'archived_at': DateTime.now().toIso8601String()})
          .eq('id', id)
          .eq('user_id', userId);

      await loadAccounts();
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus rekening: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
