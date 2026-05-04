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
import 'screens/edit_profile_screen.dart';
import 'screens/manage_accounts_screen.dart';
import 'screens/add_account_screen.dart';
import 'screens/change_pin_screen.dart';
import 'screens/theme_screen.dart';
import 'screens/help_screen.dart';

class AppRoutes {
  // Konstanta Nama Rute
  static const String root = '/';
  static const String login = '/login';
  static const String addTransaction = '/add';
  static const String analytics = '/analytics';
  static const String coupleDebt = '/couple';
  static const String transactions = '/transactions';
  static const String editProfile = '/edit-profile';
  static const String manageAccounts = '/manage-accounts';
  static const String addAccount = '/add-account';
  static const String changePin = '/change-pin';
  static const String theme = '/theme';
  static const String help = '/help';

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

      // New screens
      editProfile: (context) => const EditProfileScreen(),
      manageAccounts: (context) => const ManageAccountsScreen(),
      addAccount: (context) => const AddAccountScreen(),
      changePin: (context) => const ChangePinScreen(),
      theme: (context) => const ThemeScreen(),
      help: (context) => const HelpScreen(),
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
