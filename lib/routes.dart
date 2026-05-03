import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import routes dan screens
import 'providers/auth_provider.dart';
import 'screens/main_layout.dart';
import 'screens/login_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/couple_debt_screen.dart';

class AppRoutes {
  // Konstanta Nama Rute
  static const String root = '/';
  static const String login = '/login';
  static const String addTransaction = '/add';
  static const String analytics = '/analytics';
  static const String coupleDebt = '/couple';
  static const String transactions = '/transactions';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // FIX: root now points to _AuthGate instead of MainLayout directly.
      // _AuthGate checks isInitialized + isAuthenticated before rendering.
      root: (context) => const _AuthGate(),

      // Kept for direct deep-link use, but login flow goes via _AuthGate
      login: (context) => const LoginScreen(),

      transactions: (context) => const TransactionsScreen(),
      addTransaction: (context) => const AddTransactionScreen(),
      analytics: (context) => const AnalyticsScreen(),
      coupleDebt: (context) => const CoupleDebtScreen(),
    };
  }
}

/// Private auth gate — self-contained in routes.dart.
/// Listens to AuthProvider and decides which screen to show:
///   1. Not initialized yet  → loading spinner
///   2. Initialized + authed → MainLayout
///   3. Initialized + not authed → LoginScreen
///
/// Because this uses context.watch, it rebuilds automatically
/// whenever isInitialized or isAuthenticated changes —
/// no manual Navigator calls needed anywhere in the app.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Still reading PIN from SharedPreferences
    if (!auth.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // PIN loaded — route based on auth state
    return auth.isAuthenticated ? const MainLayout() : const LoginScreen();
  }
}
