import 'package:flutter/material.dart';

class AppTextarea extends StatelessWidget {
  final String? hintText;
  final String? label;
  final TextEditingController? controller;
  final bool isDisabled;
  final int minLines;
  final int? maxLines;
  final ValueChanged<String>? onChanged;

  const AppTextarea({
    super.key,
    this.hintText,
    this.label,
    this.controller,
    this.isDisabled = false,
    this.minLines = 3, // Setara dengan min-h-16
    this.maxLines, // Set null agar bisa expand otomatis jika diperlukan
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // --- Warna Shadcn Style ---
    const Color borderColor = Color(0xFFE2E8F0);
    const Color focusBorderColor = Color(0xFF6C63FF); // Indigo Duits
    const Color placeholderColor = Color(0xFF94A3B8);
    const Color backgroundColor = Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: TextField(
            controller: controller,
            enabled: !isDisabled,
            onChanged: onChanged,
            minLines: minLines,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: placeholderColor, fontSize: 14),
              filled: true,
              fillColor: backgroundColor,
              contentPadding: const EdgeInsets.all(12),
              // --- Default Border ---
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: borderColor),
              ),
              // --- Focus Border ---
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: focusBorderColor, width: 2),
              ),
              // --- Disabled Border ---
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: borderColor),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
