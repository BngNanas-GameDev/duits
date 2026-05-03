import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import routes dan providers
import 'routes.dart';
import 'providers/auth_provider.dart';
import 'providers/couple_provider.dart';
import 'providers/transaction_provider.dart';

void main() async {
  // 1. Inisialisasi wajib untuk aplikasi async
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Inisialisasi Supabase
    await Supabase.initialize(
      url: 'https://jnullwnvudzvnvgriobi.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpudWxsd252dWR6dm52Z3Jpb2JpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc2ODAzOTEsImV4cCI6MjA5MzI1NjM5MX0.r30kcSGcuUfu7iM83Pa27suc2XaF2tCRRkLKXAW_GLQ',
    );
  } catch (e) {
    // Menangkap error jika koneksi internet mati atau URL salah saat inisialisasi
    debugPrint("Supabase Error: $e");
  }

  runApp(
    // 3. Membungkus seluruh aplikasi dengan MultiProvider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => CoupleProvider()),
      ],
      child: const DuitsApp(),
    ),
  );
}

class DuitsApp extends StatelessWidget {
  const DuitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Duits',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          primary: const Color(0xFF6C63FF),
          secondary: const Color(0xFFEC4899),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      // Menggunakan rute dari file routes.dart
      initialRoute: AppRoutes.root,
      routes: AppRoutes.getRoutes(),
    );
  }
}
