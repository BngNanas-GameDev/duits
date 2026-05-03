import 'package:flutter/material.dart';

class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDisabled;

  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    // --- Warna Shadcn Style (Indigo Duits) ---
    const Color primaryColor = Color(0xFF6C63FF);
    const Color uncheckedBg = Color(0xFFE2E8F0); // switch-background
    const Color thumbColor = Colors.white;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: isDisabled ? null : () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36, // w-8 approx
          height: 20, // h-[1.15rem] approx
          padding: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: value ? primaryColor : uncheckedBg,
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 16, // size-4
              height: 16,
              decoration: const BoxDecoration(
                color: thumbColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 1,
                    spreadRadius: 0.5,
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
