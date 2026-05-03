import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart'; // ← your home screen
import 'login_screen.dart'; // ← your PIN entry screen

/// Drop this widget as your initialRoute target.
/// It waits for AuthProvider to finish loading before
/// deciding which screen to show.
class LoginGuard extends StatelessWidget {
  const LoginGuard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // 1. Still loading PIN from SharedPreferences → show splash
    if (!auth.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. Already authenticated (e.g. biometric succeeded) → home
    if (auth.isAuthenticated) {
      return const HomeScreen();
    }

    // 3. Not authenticated → PIN entry
    return const LoginScreen();
  }
}
