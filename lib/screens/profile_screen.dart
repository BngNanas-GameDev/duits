import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
        items: const [
          _MenuItem(
            Icons.person_outline_rounded,
            'Edit Profil',
            'Ubah nama & foto profil',
          ),
          _MenuItem(
            Icons.credit_card_rounded,
            'Kelola Rekening',
            'Tambah atau edit rekening',
          ),
        ],
      ),
      _MenuSection(
        title: 'Preferensi',
        items: const [
          _MenuItem(
            Icons.notifications_none_rounded,
            'Notifikasi',
            'Atur pengingat & notifikasi',
          ),
          _MenuItem(
            Icons.dark_mode_outlined,
            'Tema Gelap',
            'Aktifkan mode gelap',
          ),
          _MenuItem(
            Icons.download_rounded,
            'Ekspor Data',
            'Unduh riwayat transaksi',
          ),
        ],
      ),
      _MenuSection(
        title: 'Lainnya',
        items: const [
          _MenuItem(
            Icons.shield_outlined,
            'Privasi & Keamanan',
            'PIN, biometrik & privasi',
          ),
          _MenuItem(
            Icons.help_outline_rounded,
            'Bantuan',
            'FAQ & hubungi kami',
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
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
            child: const Icon(
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
          style: const TextStyle(
            color: Color(0xFF1F2937),
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
      onTap: () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFF0EEFF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(item.icon, color: const Color(0xFF6C63FF), size: 20),
      ),
      title: Text(
        item.label,
        style: const TextStyle(
          color: Color(0xFF1F2937),
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
        color: Colors.white,
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

  const _MenuSection({required this.title, required this.items});
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String description;

  const _MenuItem(this.icon, this.label, this.description);
}
