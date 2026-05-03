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

  TransactionProvider() {
    _authSubscription = _supabase.auth.onAuthStateChange.listen((_) {
      loadTransactions();
    });
    loadTransactions();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Transaction> get transactions => List.unmodifiable(_transactions);

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
