import 'package:flutter/material.dart';

class AppInput extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final bool isDisabled;
  final bool hasError;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const AppInput({
    super.key,
    this.controller,
    this.label = "",
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.isDisabled = false,
    this.hasError = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    // --- Warna Shadcn Style ---
    const Color borderColor = Color(0xFFE2E8F0);
    const Color primaryIndigo = Color(0xFF6C63FF);
    const Color errorRed = Color(0xFFEF4444);
    const Color placeholderColor = Color(0xFF94A3B8);

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      enabled: !isDisabled,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF1F2937), // text-foreground
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: placeholderColor, fontSize: 14),
        filled: true,
        fillColor: isDisabled ? const Color(0xFFF8FAFC) : Colors.white,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),

        // --- Border States (Replikasi transition-[color,box-shadow]) ---
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: hasError ? errorRed : borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: hasError ? errorRed : borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: hasError ? errorRed : primaryIndigo,
            width: 2, // Efek fokus yang lebih tegas
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
        ),
      ),
    );
  }
}
