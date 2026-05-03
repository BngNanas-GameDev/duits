import 'package:flutter/material.dart';

enum AlertVariant { standard, destructive }

class AppAlert extends StatelessWidget {
  final String title;
  final String? description;
  final IconData? icon;
  final AlertVariant variant;

  const AppAlert({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.variant = AlertVariant.standard,
  });

  @override
  Widget build(BuildContext context) {
    // Penentuan warna berdasarkan varian (Indigo untuk standar, Red untuk destructive)
    final bool isDestructive = variant == AlertVariant.destructive;

    final Color bgColor = isDestructive
        ? const Color(0xFFFEF2F2)
        : const Color(0xFFF8F7FF);
    final Color borderColor = isDestructive
        ? const Color(0xFFFCA5A5)
        : const Color(0xFFE0E7FF);
    final Color iconTextColor = isDestructive
        ? const Color(0xFFEF4444)
        : const Color(0xFF6C63FF);
    final Color titleColor = isDestructive
        ? const Color(0xFF991B1B)
        : const Color(0xFF1F2937);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: iconTextColor),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // AlertTitle
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                // AlertDescription
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: TextStyle(
                      color: isDestructive
                          ? iconTextColor.withOpacity(0.8)
                          : const Color(0xFF6B7280),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
