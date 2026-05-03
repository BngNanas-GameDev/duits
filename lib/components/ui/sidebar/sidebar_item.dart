import 'package:flutter/material.dart';

class AppSidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isCollapsed;
  final VoidCallback onTap;
  final Widget? trailing; // Bisa dipakai untuk Badge (misal: jumlah notif)

  const AppSidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.isCollapsed = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    // --- Warna Shadcn Style (Indigo Duits) ---
    const Color primaryIndigo = Color(0xFF6C63FF);
    const Color textMuted = Color(0xFF64748B);
    const Color textForeground = Color(0xFF1F2937);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 0 : 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? primaryIndigo.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: isActive ? primaryIndigo : textMuted),
              if (!isCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? textForeground : textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ?trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
