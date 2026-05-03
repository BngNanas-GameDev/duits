import 'package:flutter/material.dart';

class AccordionItem {
  final String title;
  final Widget content;

  AccordionItem({required this.title, required this.content});
}

class AppAccordion extends StatelessWidget {
  final List<AccordionItem> items;

  const AppAccordion({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Theme(
      // Menghilangkan garis border default ExpansionTile saat terbuka/tertutup
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Column(
        children: items.asMap().entries.map((entry) {
          int idx = entry.key;
          AccordionItem item = entry.value;
          bool isLast = idx == items.length - 1;

          return Container(
            // Border-b (garis bawah) kecuali item terakhir
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isLast ? Colors.transparent : const Color(0xFFF1F5F9),
                  width: 1,
                ),
              ),
            ),
            child: ExpansionTile(
              // Styling Trigger (Header)
              tilePadding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 0,
              ),
              title: Text(
                item.title,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // Konfigurasi Icon (Chevron)
              trailing: const Icon(
                Icons.expand_more_rounded,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
              iconColor: const Color(0xFF6C63FF), // Warna icon saat terbuka
              collapsedIconColor: const Color(0xFF94A3B8),

              // Styling Content
              childrenPadding: const EdgeInsets.only(bottom: 16),
              expandedAlignment: Alignment.topLeft,
              children: [
                DefaultTextStyle(
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  child: item.content,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
