import 'package:flutter/material.dart';

class AppTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  final bool waitTap; // Untuk mobile, tooltip muncul saat long press atau tap

  const AppTooltip({
    super.key,
    required this.message,
    required this.child,
    this.waitTap = false,
  });

  @override
  Widget build(BuildContext context) {
    // --- Warna Shadcn Style (Indigo Duits) ---
    const Color primaryIndigo = Color(0xFF6C63FF);
    const Color foregroundColor = Colors.white;

    return Tooltip(
      message: message,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(top: 8),
      verticalOffset: 24, // Jarak dari trigger ke content
      preferBelow: true, // Muncul di bawah trigger (bisa diubah)
      // Kecepatan animasi
      waitDuration: waitTap ? Duration.zero : const Duration(milliseconds: 500),
      showDuration: const Duration(seconds: 2),

      // --- TooltipContent Styling ---
      decoration: BoxDecoration(
        color: primaryIndigo,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      textStyle: const TextStyle(
        color: foregroundColor,
        fontSize: 12, // text-xs
        fontWeight: FontWeight.w500,
      ),

      child: child,
    );
  }
}
