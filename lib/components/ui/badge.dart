import 'package:flutter/material.dart';

enum BadgeVariant { defaultVariant, secondary, destructive, outline }

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final IconData? icon;
  final double? fontSize;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.defaultVariant,
    this.icon,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    // --- Konfigurasi Warna & Style berdasarkan Varian ---
    Color bgColor;
    Color textColor;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case BadgeVariant.secondary:
        bgColor = const Color(0xFFF1F5F9); // bg-secondary
        textColor = const Color(0xFF475569); // text-secondary-foreground
        break;
      case BadgeVariant.destructive:
        bgColor = const Color(0xFFFF6B6B); // bg-destructive
        textColor = Colors.white;
        break;
      case BadgeVariant.outline:
        bgColor = Colors.transparent;
        textColor = const Color(0xFF64748B); // text-muted-foreground
        border = const BorderSide(color: Color(0xFFE2E8F0)); // border
        break;
      case BadgeVariant.defaultVariant:
        bgColor = const Color(0xFF6C63FF); // bg-primary (Duits Indigo)
        textColor = Colors.white;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6), // rounded-md
        border: border != BorderSide.none
            ? Border.all(color: border.color)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // w-fit
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor), // [&>svg]:size-3
            const SizedBox(width: 4), // gap-1
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize ?? 11, // text-xs
              fontWeight: FontWeight.w600, // font-medium
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
