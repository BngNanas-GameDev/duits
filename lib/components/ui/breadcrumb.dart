import 'package:flutter/material.dart';

class BreadcrumbItemData {
  final String label;
  final VoidCallback? onTap;

  BreadcrumbItemData({required this.label, this.onTap});
}

class AppBreadcrumb extends StatelessWidget {
  final List<BreadcrumbItemData> items;
  final Widget? separator;

  const AppBreadcrumb({super.key, required this.items, this.separator});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8, // Gap antara item
      runSpacing: 4, // Gap antar baris jika wrap
      children: _buildItems(),
    );
  }

  List<Widget> _buildItems() {
    List<Widget> children = [];

    for (int i = 0; i < items.length; i++) {
      final isLast = i == items.length - 1;
      final item = items[i];

      // BreadcrumbItem + BreadcrumbLink/Page
      children.add(
        GestureDetector(
          onTap: isLast ? null : item.onTap,
          child: Text(
            item.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isLast ? FontWeight.w500 : FontWeight.normal,
              color: isLast
                  ? const Color(0xFF1F2937) // BreadcrumbPage (Foreground)
                  : const Color(0xFF64748B), // BreadcrumbLink (Muted)
            ),
          ),
        ),
      );

      // BreadcrumbSeparator
      if (!isLast) {
        children.add(
          separator ??
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
        );
      }
    }

    return children;
  }
}

// Komponen Tambahan untuk Ellipsis (Jika dibutuhkan manual)
class BreadcrumbEllipsis extends StatelessWidget {
  const BreadcrumbEllipsis({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.more_horiz_rounded,
      size: 18,
      color: Color(0xFF94A3B8),
    );
  }
}
