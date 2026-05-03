import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- IMPORT PROVIDERS ---
import '../providers/auth_provider.dart';

// --- IMPORT COMPONENTS ---
import '../components/bottom_nav.dart';
import '../components/ui/skeleton.dart'; // Gunakan skeleton saat loading auth

// --- IMPORT SCREENS ---
import 'home_screen.dart';
import 'transactions_screen.dart';
import 'couple_debt_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  /// Memastikan user sudah login sebelum merender konten
  void _checkAuth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (!auth.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  /// List halaman dengan PageStorageKey agar posisi scroll tidak reset
  final List<Widget> _pages = [
    const HomeScreen(key: PageStorageKey('home')),
    const TransactionsScreen(key: PageStorageKey('transactions')),
    const SizedBox.shrink(), // Placeholder untuk tombol '+'
    const CoupleDebtScreen(key: PageStorageKey('debt')),
    const ProfileScreen(key: PageStorageKey('profile')),
  ];

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = Provider.of<AuthProvider>(context).isAuthenticated;

    // --- LOADING STATE (SHADCN STYLE) ---
    if (!isAuthenticated) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppSkeleton(
                width: 60,
                height: 60,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              SizedBox(height: 16),
              Text(
                "Memverifikasi Sesi...",
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      // Warna background konsisten dengan UI Kit Duits (Slate 50)
      backgroundColor: const Color(0xFFF8FAFC),

      // IndexedStack: Menjaga state widget tetap hidup di background
      body: IndexedStack(index: _currentIndex, children: _pages),

      // Navigasi bawah kustom
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Logika tombol tengah (Add Transaction)
          if (index == 2) {
            _openAddTransaction();
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }

  /// Membuka layar tambah transaksi dengan animasi full-screen modal
  void _openAddTransaction() {
    // Di Flutter, pushNamed bisa diatur agar muncul sebagai modal atau page biasa
    Navigator.pushNamed(context, '/add').then((_) {
      // Callback setelah selesai tambah data jika perlu refresh sesuatu
    });
  }
}
