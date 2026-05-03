import 'package:flutter/material.dart';

class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final bool isDisabled;

  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    // --- Warna Utama (Indigo Duits) ---
    const Color primaryColor = Color(0xFF6C63FF);
    const Color borderColor = Color(0xFFE2E8F0);

    Widget checkbox = SizedBox(
      width: 18,
      height: 18,
      child: Checkbox(
        value: value,
        onChanged: isDisabled ? null : onChanged,
        // --- Styling: data-[state=checked] ---
        activeColor: primaryColor,
        checkColor: Colors.white, // CheckIcon
        side: const BorderSide(color: borderColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // rounded-[4px]
        ),
        // Efek transisi dan warna state
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryColor;
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey.shade200;
          }
          return Colors.transparent;
        }),
      ),
    );

    // Jika ada label, bungkus dengan Row agar klik label juga mencentang
    if (label != null) {
      return GestureDetector(
        onTap: isDisabled ? null : () => onChanged!(!value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            checkbox,
            const SizedBox(width: 8),
            Text(
              label!,
              style: TextStyle(
                fontSize: 14,
                color: isDisabled ? Colors.grey : const Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return checkbox;
  }
}
