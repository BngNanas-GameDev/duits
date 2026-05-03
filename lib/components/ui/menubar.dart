import 'package:flutter/material.dart';

class MenubarItemData {
  final String label;
  final IconData? icon;
  final String? shortcut;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool isSelected;

  MenubarItemData({
    required this.label,
    this.onTap,
    this.icon,
    this.shortcut,
    this.isDestructive = false,
    this.isSelected = false,
  });
}

class AppMenubar extends StatelessWidget {
  final List<AppMenubarMenu> menus;

  const AppMenubar({super.key, required this.menus});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36, // h-9
      padding: const EdgeInsets.all(4), // p-1
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6), // rounded-md
        border: Border.all(color: const Color(0xFFE2E8F0)), // border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: menus),
    );
  }
}

class AppMenubarMenu extends StatelessWidget {
  final String trigger;
  final List<dynamic>
  items; // Bisa MenubarItemData atau String untuk separator/label

  const AppMenubarMenu({super.key, required this.trigger, required this.items});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<dynamic>(
      offset: const Offset(0, 32), // sideOffset = 8
      surfaceTintColor: Colors.transparent,
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      // --- MenubarTrigger ---
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
        child: Text(
          trigger,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2937),
          ),
        ),
      ),
      itemBuilder: (context) => items.map<PopupMenuEntry<dynamic>>((item) {
        if (item == "---") {
          return const PopupMenuDivider(height: 1);
        }

        if (item is String) {
          // MenubarLabel
          return PopupMenuItem<dynamic>(
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
        }

        final data = item as MenubarItemData;
        return PopupMenuItem<dynamic>(
          onTap: data.onTap,
          height: 38,
          child: Row(
            children: [
              if (data.isSelected) ...[
                const Icon(Icons.check, size: 16, color: Color(0xFF1F2937)),
                const SizedBox(width: 8),
              ] else if (data.icon != null) ...[
                Icon(
                  data.icon,
                  size: 16,
                  color: data.isDestructive
                      ? Colors.red
                      : const Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  data.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: data.isDestructive
                        ? Colors.red
                        : const Color(0xFF1F2937),
                  ),
                ),
              ),
              if (data.shortcut != null)
                Text(
                  data.shortcut!,
                  style: const TextStyle(
                    fontSize: 10,
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
