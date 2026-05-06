import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final palette = themeProvider.palette;

    return SafeArea(
      top: false,
      child: Container(
        height: 86,
        decoration: BoxDecoration(
          color: palette.surfaceColor(isDark),
          border: Border(top: BorderSide(color: palette.dividerColor(isDark))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _NavItem(
                    index: 0,
                    currentIndex: currentIndex,
                    icon: Icons.home_rounded,
                    label: 'Beranda',
                    onTap: onTap,
                    isDark: isDark,
                  ),
                  _NavItem(
                    index: 1,
                    currentIndex: currentIndex,
                    icon: Icons.list_alt_rounded,
                    label: 'Riwayat',
                    onTap: onTap,
                    isDark: isDark,
                  ),
                  _MainNavItem(onTap: () => onTap(2), isDark: isDark),
                  _NavItem(
                    index: 3,
                    currentIndex: currentIndex,
                    icon: Icons.favorite_rounded,
                    label: 'Pasangan',
                    activeColor: const Color(0xFFEC4899),
                    onTap: onTap,
                    isDark: isDark,
                  ),
                  _NavItem(
                    index: 4,
                    currentIndex: currentIndex,
                    icon: Icons.person_rounded,
                    label: 'Profil',
                    onTap: onTap,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final String label;
  final Color activeColor;
  final ValueChanged<int> onTap;
  final bool isDark;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
    this.activeColor = const Color(0xFF6C63FF),
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;
    final inactiveColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final color = isActive ? activeColor : inactiveColor;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 23),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainNavItem extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _MainNavItem({required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final inactiveColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: const Offset(0, -16),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7C6FF7), Color(0xFF5B4FF5)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.45),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -10),
              child: Text(
                'Tambah',
                style: TextStyle(
                  color: inactiveColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
