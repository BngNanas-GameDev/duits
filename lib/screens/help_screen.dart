import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pusat Bantuan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Temukan jawaban atau hubungi kami',
                        style: TextStyle(
                          color: Color(0xFFC7D2FE),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // FAQ Section title
          const Text(
            'Pertanyaan Umum (FAQ)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          // FAQ Items
          Container(
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
            child: Column(
              children: const [
                _FaqTile(
                  question: 'Bagaimana cara menambahkan transaksi?',
                  answer:
                      'Tekan tombol "+" di navigasi bawah, lalu isi detail pemasukan atau pengeluaran Anda.',
                ),
                _Divider(),
                _FaqTile(
                  question: 'Bagaimana cara mengganti PIN?',
                  answer:
                      'Buka Profil > Privasi & Keamanan > Ubah PIN. Anda perlu memverifikasi PIN lama terlebih dahulu.',
                ),
                _Divider(),
                _FaqTile(
                  question: 'Bagaimana cara menambahkan rekening baru?',
                  answer:
                      'Buka Profil > Kelola Rekening, lalu tekan tombol "+" di pojok kanan atas.',
                ),
                _Divider(),
                _FaqTile(
                  question: 'Apakah data saya aman?',
                  answer:
                      'Ya, semua data disimpan dengan aman di Supabase dengan enkripsi. PIN Anda disimpan secara lokal di perangkat dengan enkripsi secure storage.',
                ),
                _Divider(),
                _FaqTile(
                  question: 'Bagaimana cara mengubah tema warna?',
                  answer:
                      'Buka Profil > Tema Gelap untuk mengubah ke mode gelap, dan kelola palet warna di pengaturan tema.',
                ),
                _Divider(),
                _FaqTile(
                  question: 'Bisa pakai fitur pasangan?',
                  answer:
                      'Ya, fitur Pasangan (Couple Debt) memungkinkan Anda dan pasangan berbagi tagihan dan hutang. Tersedia di tab ketiga navigasi bawah.',
                ),
                _Divider(),
                _FaqTile(
                  question: 'Bagaimana cara ekspor data transaksi?',
                  answer:
                      'Fitur ekspor data akan segera hadir di versi berikutnya. Nantikan update terbaru dari Duits.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Contact Us section
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hubungi Kami',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Butuh bantuan lebih lanjut? Kami siap membantu!',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 16),
                // WhatsApp button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openWhatsApp(context),
                    icon: const Icon(Icons.chat_rounded, size: 20),
                    label: const Text(
                      'Chat via WhatsApp',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Phone number display
                Center(
                  child: Text(
                    '0858-4938-7949',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _openWhatsApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return _WhatsAppDialog(
          onDismiss: () => Navigator.pop(ctx),
        );
      },
    );
  }
}

class _WhatsAppDialog extends StatelessWidget {
  final VoidCallback onDismiss;

  const _WhatsAppDialog({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF25D366),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.chat_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Buka WhatsApp'),
        ],
      ),
      content: const Text(
        'Untuk menghubungi tim support Duits, silakan buka WhatsApp dan chat ke nomor:\n\n'
        '• WhatsApp: 0858-4938-7949\n'
        '• Link: https://wa.me/6285849387949\n\n'
        'Anda bisa membuka link tersebut secara manual di browser.',
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() => _isExpanded = !_isExpanded);
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF94A3B8),
                    size: 22,
                  ),
                ),
              ],
            ),
            if (_isExpanded)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(top: 8),
                child: Text(
                  widget.answer,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
    );
  }
}
