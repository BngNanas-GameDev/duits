import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _autoTrack = true;
  bool _coupleInvite = true;
  bool _incomeAlert = true;
  bool _expenseAlert = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _SectionHeader(title: 'Pelacakan Otomatis'),
          SwitchListTile(
            title: const Text('Notifikasi Transaksi'),
            subtitle: const Text('Beritahu jika ada transaksi otomatis terdeteksi'),
            value: _autoTrack,
            onChanged: (v) => setState(() => _autoTrack = v),
          ),
          const Divider(),
          _SectionHeader(title: 'Pasangan (Couple)'),
          SwitchListTile(
            title: const Text('Undangan Pasangan'),
            subtitle: const Text('Beritahu jika ada undangan dari pasangan'),
            value: _coupleInvite,
            onChanged: (v) => setState(() => _coupleInvite = v),
          ),
          const Divider(),
          _SectionHeader(title: 'Lansiran Keuangan'),
          SwitchListTile(
            title: const Text('Pemasukan Baru'),
            value: _incomeAlert,
            onChanged: (v) => setState(() => _incomeAlert = v),
          ),
          SwitchListTile(
            title: const Text('Pengeluaran Baru'),
            value: _expenseAlert,
            onChanged: (v) => setState(() => _expenseAlert = v),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
