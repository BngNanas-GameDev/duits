import 'package:flutter/material.dart';

class AppSidebarGroup extends StatelessWidget {
  final String? label;
  final List<Widget> items;
  final bool isCollapsed;

  const AppSidebarGroup({
    super.key,
    this.label,
    required this.items,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: isCollapsed
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (label != null && !isCollapsed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                label!.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8), // text-muted-foreground
                  letterSpacing: 1.2,
                ),
              ),
            ),
          // Jika collapsed dan ada label, tampilkan separator tipis sebagai pengganti teks
          if (label != null && isCollapsed)
            const Divider(height: 20, thickness: 1, indent: 20, endIndent: 20),

          Column(children: items),
        ],
      ),
    );
  }
}
