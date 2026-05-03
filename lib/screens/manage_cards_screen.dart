import 'package:flutter/material.dart';

class ManageCardsScreen extends StatefulWidget {
  const ManageCardsScreen({super.key});

  @override
  State<ManageCardsScreen> createState() => _ManageCardsScreenState();
}

class _ManageCardsScreenState extends State<ManageCardsScreen> {
  final List<Map<String, String>> _cards = [
    {'bank': 'BCA', 'number': '**** **** 1234', 'type': 'Debit'},
    {'bank': 'Mandiri', 'number': '**** **** 5678', 'type': 'Debit'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Rekening'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._cards.map((card) => Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.credit_card, color: Colors.blue),
              ),
              title: Text(card['bank']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(card['number']!),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _cards.remove(card);
                  });
                },
              ),
            ),
          )),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddCardDialog,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Rekening Baru'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Koneksi Otomatis',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Rekening yang terhubung akan secara otomatis melacak pemasukan dan pengeluaran Anda.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Pelacakan Otomatis'),
            subtitle: const Text('Aktifkan pelacakan transaksi otomatis'),
            value: true,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  void _showAddCardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Rekening'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: 'Nama Bank')),
            TextField(decoration: InputDecoration(labelText: 'Nomor Rekening')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              // Add card logic
              Navigator.pop(context);
            },
            child: const Text('Hubungkan'),
          ),
        ],
      ),
    );
  }
}
