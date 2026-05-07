import 'package:flutter/material.dart';

enum AppToggleVariant { defaultVariant, outline }

enum AppToggleSize { sm, defaultSize, lg }

class AppToggle extends StatelessWidget {
  final bool isActive;
  final ValueChanged<bool> onChanged;
  final Widget child;
  final AppToggleVariant variant;
  final AppToggleSize size;
  final bool isDisabled;

  const AppToggle({
    super.key,
    required this.isActive,
    required this.onChanged,
    required this.child,
    this.variant = AppToggleVariant.defaultVariant,
    this.size = AppToggleSize.defaultSize,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    // --- Warna Shadcn Style ---
    const Color primaryIndigo = Color(0xFF6C63FF);
    const Color textMuted = Color(0xFF64748B);
    const Color borderColor = Color(0xFFE2E8F0);

    // --- Sizing Logic (Mapping size variants) ---
    double height = 36; // h-9
    double padding = 8;
    double fontSize = 14;

    if (size == AppToggleSize.sm) {
      height = 32; // h-8
      padding = 6;
      fontSize = 12;
    } else if (size == AppToggleSize.lg) {
      height = 40; // h-10
      padding = 10;
      fontSize = 16;
    }

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: isDisabled ? null : () => onChanged(!isActive),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: height,
          padding: EdgeInsets.symmetric(horizontal: padding),
          decoration: BoxDecoration(
            color: isActive
                ? primaryIndigo.withOpacity(0.1)
                : (variant == AppToggleVariant.outline
                      ? Colors.transparent
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(6), // rounded-md
            border: variant == AppToggleVariant.outline
                ? Border.all(color: isActive ? primaryIndigo : borderColor)
                : null,
          ),
          child: Center(
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: isActive ? primaryIndigo : textMuted,
              ),
              child: IconTheme(
                data: IconThemeData(
                  size: fontSize + 2,
                  color: isActive ? primaryIndigo : textMuted,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
