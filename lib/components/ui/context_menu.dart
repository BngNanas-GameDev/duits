import 'package:flutter/material.dart';

class ContextMenuItemData {
  final String label;
  final IconData? icon;
  final String? shortcut;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isSelected;

  ContextMenuItemData({
    required this.label,
    required this.onTap,
    this.icon,
    this.shortcut,
    this.isDestructive = false,
    this.isSelected = false,
  });
}

class AppContextMenu {
  static void show({
    required BuildContext context,
    required Offset tapPosition,
    required List<dynamic>
    items, // Bisa berupa ContextMenuItemData atau String (untuk Label/Separator)
  }) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        tapPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      color: Colors.white,
      items: items.map<PopupMenuEntry<dynamic>>((item) {
        if (item is String) {
          if (item == "---") {
            // ContextMenuSeparator
            return const PopupMenuDivider(height: 1);
          }
          // ContextMenuLabel
          return PopupMenuItem(
            enabled: false,
            height: 32,
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
              ),
            ),
          );
        } else if (item is ContextMenuItemData) {
          // ContextMenuItem
          return PopupMenuItem(
            onTap: item.onTap,
            height: 40,
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    size: 16,
                    color: item.isDestructive
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 10),
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
        }
        return const PopupMenuItem(child: SizedBox.shrink());
      }).toList(),
    );
  }
}
