import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/palette.dart';
import '../routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final palette = themeProvider.palette;
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
            onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
          ),
          _MenuItem(
            Icons.credit_card_rounded,
            'Kelola Rekening',
            'Tambah atau edit rekening',
            onTap: () => Navigator.pushNamed(context, AppRoutes.manageAccounts),
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
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur ini akan segera hadir.'),
                ),
              );
            },
          ),
          _MenuItem(
            Icons.dark_mode_outlined,
            'Tema Gelap',
            isDark ? 'Mode gelap aktif' : 'Aktifkan mode gelap',
            onTap: () => Navigator.pushNamed(context, AppRoutes.theme),
          ),
          _MenuItem(
            Icons.download_rounded,
            'Ekspor Data',
            'Unduh riwayat transaksi',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur ini akan segera hadir.'),
                ),
              );
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
            onTap: () => Navigator.pushNamed(context, AppRoutes.changePin),
          ),
          _MenuItem(
            Icons.help_outline_rounded,
            'Bantuan',
            'FAQ & hubungi kami',
            onTap: () => Navigator.pushNamed(context, AppRoutes.help),
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: palette.scaffoldBackground(isDark),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 104),
        child: Column(
          children: [
            _ProfileHeader(),
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
                        backgroundColor: palette.accentColor(isDark).withValues(alpha: 0.08),
                        foregroundColor: palette.accentColor(isDark),
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: palette.text(isDark),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Duits v1.0.0',
                    style: TextStyle(
                      color: palette.secondaryText(isDark),
                      fontSize: 12,
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
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final palette = themeProvider.palette;
    final name = auth.user?.userMetadata?['name']?.toString() ?? 'Pengguna';
    final email = auth.email ?? '-';
    final gradientColors = palette.headerGradient(isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
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
            ),
            child: Icon(
              Icons.business_center_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
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
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
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
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final palette = themeProvider.palette;

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
      palette: palette,
      isDark: isDark,
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
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: isDark ? themeProvider.palette.textDark : themeProvider.palette.textLight,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? themeProvider.palette.secondaryTextDark
                : themeProvider.palette.secondaryTextLight,
            fontSize: 12,
          ),
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
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final palette = themeProvider.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            section.title.toUpperCase(),
            style: TextStyle(
              color: palette.secondaryText(isDark),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(
                      height: 1,
                      color: palette.dividerColor(isDark),
                    ),
                  ),
              ],
            ],
          ),
          palette: palette,
          isDark: isDark,
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
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final palette = themeProvider.palette;

    return ListTile(
      onTap: item.onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: palette.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(item.icon, color: palette.primary, size: 20),
      ),
      title: Text(
        item.label,
        style: TextStyle(
          color: palette.text(isDark),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        item.description,
        style: TextStyle(
          color: palette.secondaryText(isDark),
          fontSize: 11,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: palette.secondaryText(isDark),
        size: 20,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final AppPalette palette;
  final bool isDark;

  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.palette = AppPalette.defaultTheme,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: palette.cardColor(isDark),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
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

  const _MenuSection({required this.title, required this.items});
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback? onTap;

  const _MenuItem(this.icon, this.label, this.description, {this.onTap});
}
