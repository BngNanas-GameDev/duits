import 'package:flutter/material.dart';

class AppLabel extends StatelessWidget {
  final String text;
  final bool isDisabled;
  final bool isRequired;
  final double? fontSize;
  final Color? color;

  const AppLabel({
    super.key,
    required this.text,
    this.isDisabled = false,
    this.isRequired = false,
    this.fontSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Warna teks utama (Foreground)
    final Color foregroundColor = color ?? const Color(0xFF1F2937);

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0, // peer-disabled:opacity-50
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 14, // text-sm
              fontWeight: FontWeight.w500, // font-medium
              color: foregroundColor,
              height: 1.0, // leading-none
              letterSpacing: 0.1,
            ),
          ),
          if (isRequired) ...[
            const SizedBox(width: 4), // gap-1
            const Text(
              "*",
              style: TextStyle(
                color: Color(0xFFEF4444), // destructive red
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
