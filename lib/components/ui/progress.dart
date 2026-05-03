import 'package:flutter/material.dart';

class AppProgress extends StatelessWidget {
  /// Nilai antara 0.0 hingga 1.0
  final double value;
  final double height;
  final Color? color;
  final Color? backgroundColor;

  const AppProgress({
    super.key,
    required this.value,
    this.height = 8.0, // Setara dengan h-2 di Tailwind
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // --- Warna Shadcn Style (Indigo Duits) ---
    final Color primaryColor = color ?? const Color(0xFF6C63FF);
    final Color bgPrimary = backgroundColor ?? primaryColor.withOpacity(0.2);

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2), // rounded-full
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          value: value.clamp(0.0, 1.0),
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          backgroundColor: bgPrimary,
          // Flutter secara otomatis menangani animasi transisi
          // jika nilai 'value' berubah dalam StatefulWidget
        ),
      ),
    );
  }
}
