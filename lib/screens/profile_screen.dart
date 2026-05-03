import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/export_service.dart';
import 'edit_profile_screen.dart';
import 'security_privacy_screen.dart';
import 'manage_cards_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final themeProvider = context.watch<ThemeProvider>();
        return AlertDialog(
          title: const Text('Pilih Tema'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<AppTheme>(
                title: const Text('Default (Blue)'),
                value: AppTheme.defaultTheme,
                groupValue: themeProvider.currentTheme,
                onChanged: (v) {
                  themeProvider.setTheme(v!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<AppTheme>(
                title: const Text('Pink Blossom'),
                value: AppTheme.pinkBlossom,
                groupValue: themeProvider.currentTheme,
                onChanged: (v) {
                  themeProvider.setTheme(v!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<AppTheme>(
                title: const Text('Dark Mode'),
                value: AppTheme.darkMode,
                groupValue: themeProvider.currentTheme,
                onChanged: (v) {
                  themeProvider.setTheme(v!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<TransactionProvider>().transactions;
    final savingTotal = transactions
        .where((tx) => tx.category == 'Tabungan')
        .fold<double>(0, (sum, tx) => sum + tx.amount);
    final activeMonths = transactions
        .map((tx) {
          return tx.date.length >= 7 ? tx.date.substring(0, 7) : tx.date;
        })
        .toSet()
        .length;

    final menuSections = [
      _MenuSection(
        title: 'Akun',
        items: [
          _MenuItem(
            Icons.person_outline_rounded,
            'Edit Profil',
            'Ubah nama & foto profil',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          _MenuItem(
            Icons.credit_card_rounded,
            'Kelola Rekening',
            'Tambah atau edit rekening',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageCardsScreen()),
            ),
          ),
        ],
      ),
      _MenuSection(
        title: 'Preferensi',
        items: [
          _MenuItem(
            Icons.notifications_none_rounded,
            'Notifikasi',
            'Atur pengingat & notifikasi',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          _MenuItem(
            Icons.palette_outlined,
            'Tema Aplikasi',
            'Pilih tema warna favorit',
            onTap: () => _showThemeDialog(context),
          ),
          _MenuItem(
            Icons.download_rounded,
            'Ekspor Data',
            'Unduh riwayat transaksi',
            onTap: () async {
              final txProvider = context.read<TransactionProvider>();
              await ExportService.exportTransactionsToPdf(txProvider.transactions);
            },
          ),
        ],
      ),
      _MenuSection(
        title: 'Lainnya',
        items: [
          _MenuItem(
            Icons.shield_outlined,
            'Privasi & Keamanan',
            'PIN, biometrik & privasi',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SecurityPrivacyScreen()),
            ),
          ),
          _MenuItem(
            Icons.help_outline_rounded,
            'Bantuan',
            'FAQ & hubungi kami',
            onTap: () async {
              final whatsappUrl = Uri.parse("https://wa.me/6285849387949");
              if (await canLaunchUrl(whatsappUrl)) {
                await launchUrl(whatsappUrl,
                    mode: LaunchMode.externalApplication);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal membuka WhatsApp')),
                  );
                }
              }
            },
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 104),
        child: Column(
          children: [
            const _ProfileHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _StatsCard(
                    transactionCount: transactions.length,
                    activeMonths: activeMonths,
                    savingTotal: savingTotal,
                  ),
                  const SizedBox(height: 20),
                  for (final section in menuSections) ...[
                    _MenuSectionView(section: section),
                    const SizedBox(height: 20),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: TextButton.icon(
                      onPressed: () async {
                        await context.read<AuthProvider>().logout();
                        if (!context.mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout_rounded, size: 19),
                      label: const Text('Keluar'),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF0F0),
                        foregroundColor: const Color(0xFFFF6B6B),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Duits v1.0.0',
                    style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.user?.userMetadata?['name']?.toString() ?? 'Pengguna';
    final email = auth.email ?? '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.32),
                  Colors.white.withValues(alpha: 0.12),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 3,
              ),
              image: auth.user?.userMetadata?['avatar_url'] != null &&
                      File(auth.user?.userMetadata?['avatar_url']).existsSync()
                  ? DecorationImage(
                      image: FileImage(
                          File(auth.user?.userMetadata?['avatar_url'])),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: auth.user?.userMetadata?['avatar_url'] == null ||
                    !File(auth.user?.userMetadata?['avatar_url']).existsSync()
                ? const Icon(
                    Icons.business_center_rounded,
                    color: Colors.white,
                    size: 36,
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFC7D2FE), fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Premium Member',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final int transactionCount;
  final int activeMonths;
  final double savingTotal;

  const _StatsCard({
    required this.transactionCount,
    required this.activeMonths,
    required this.savingTotal,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Expanded(
            child: _StatItem(label: 'Transaksi', value: '$transactionCount'),
          ),
          Expanded(
            child: _StatItem(label: 'Bulan Aktif', value: '$activeMonths'),
          ),
          Expanded(
            child: _StatItem(
              label: 'Tabungan',
              value: _formatShortRupiah(savingTotal),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatShortRupiah(double amount) {
  if (amount >= 1000000) {
    return 'Rp${(amount / 1000000).toStringAsFixed(amount % 1000000 == 0 ? 0 : 1)}jt';
  }
  if (amount >= 1000) {
    return 'Rp${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}rb';
  }
  return 'Rp${amount.toInt()}';
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
        ),
      ],
    );
  }
}

class _MenuSectionView extends StatelessWidget {
  final _MenuSection section;

  const _MenuSectionView({required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            section.title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        _Card(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < section.items.length; i++) ...[
                _MenuTile(item: section.items[i]),
                if (i < section.items.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1, color: Color(0xFFF8FAFC)),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;

  const _MenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: item.onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(item.icon, color: Theme.of(context).primaryColor, size: 20),
      ),
      title: Text(
        item.label,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        item.description,
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFFCBD5E1),
        size: 20,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MenuSection {
  final String title;
  final List<_MenuItem> items;

  _MenuSection({required this.title, required this.items});
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback? onTap;

  _MenuItem(this.icon, this.label, this.description, {this.onTap});
}
