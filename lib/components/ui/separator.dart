import 'package:flutter/material.dart';

enum SeparatorOrientation { horizontal, vertical }

class AppSeparator extends StatelessWidget {
  final SeparatorOrientation orientation;
  final double? thickness;
  final Color? color;
  final double? length;

  const AppSeparator({
    super.key,
    this.orientation = SeparatorOrientation.horizontal,
    this.thickness = 1.0, // h-px atau w-px
    this.color,
    this.length,
  });

  @override
  Widget build(BuildContext context) {
    // --- Warna Shadcn Style (bg-border) ---
    final Color borderColor = color ?? const Color(0xFFE2E8F0);

    return Container(
      width: orientation == SeparatorOrientation.horizontal
          ? (length ?? double.infinity)
          : thickness,
      height: orientation == SeparatorOrientation.horizontal
          ? thickness
          : (length ?? double.infinity),
      color: borderColor,
    );
  }
}
