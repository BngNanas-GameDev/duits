import 'package:flutter/material.dart';

class DropdownItemData {
  final String label;
  final IconData? icon;
  final String? shortcut;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool isHeader;
  final bool isSeparator;

  DropdownItemData({
    required this.label,
    this.onTap,
    this.icon,
    this.shortcut,
    this.isDestructive = false,
    this.isHeader = false,
    this.isSeparator = false,
  });

  // Helper untuk membuat separator (DropdownMenuSeparator)
  factory DropdownItemData.separator() =>
      DropdownItemData(label: "", isSeparator: true);

  // Helper untuk membuat label (DropdownMenuLabel)
  factory DropdownItemData.label(String title) =>
      DropdownItemData(label: title, isHeader: true);
}

class AppDropdownMenu extends StatelessWidget {
  final Widget trigger;
  final List<DropdownItemData> items;
  final Offset offset;

  const AppDropdownMenu({
    super.key,
    required this.trigger,
    required this.items,
    this.offset = const Offset(0, 40), // sideOffset = 4 di React
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      offset: offset,
      surfaceTintColor: Colors.transparent,
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      // --- DropdownMenuTrigger ---
      child: trigger,
      onSelected: (index) {
        items[index].onTap?.call();
      },
      itemBuilder: (context) =>
          items.asMap().entries.map<PopupMenuEntry<int>>((entry) {
            int idx = entry.key;
            DropdownItemData item = entry.value;

            if (item.isSeparator) {
              return const PopupMenuDivider(height: 1) as PopupMenuEntry<int>;
            }

            return PopupMenuItem<int>(
              value: idx,
              enabled: !item.isHeader && item.onTap != null,
              height: item.isHeader ? 32 : 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: item.isHeader
                  ? Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                    )
                  : Row(
                      children: [
                        if (item.icon != null) ...[
                          Icon(
                            item.icon,
                            size: 16,
                            color: item.isDestructive
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 14,
                              color: item.isDestructive
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        if (item.shortcut != null)
                          // DropdownMenuShortcut
                          Text(
                            item.shortcut!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 1.2,
                            ),
                          ),
                      ],
                    ),
            );
          }).toList(),
    );
  }
}
