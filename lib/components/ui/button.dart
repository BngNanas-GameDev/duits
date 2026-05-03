import 'package:flutter/material.dart';

// Definisi Enum untuk Varian dan Ukuran
enum AppButtonVariant {
  defaultVariant,
  outline,
  secondary,
  ghost,
  destructive,
  link,
}

enum AppButtonSize { defaultSize, sm, lg, icon }

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final double? width;
  final bool isDisabled;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = AppButtonVariant.defaultVariant,
    this.size = AppButtonSize.defaultSize,
    this.width,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    // --- Konfigurasi Warna Berdasarkan Varian ---
    Color bgColor = const Color(0xFF6C63FF); // Primary Indigo
    Color textColor = Colors.white;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.outline:
        bgColor = Colors.transparent;
        textColor = const Color(0xFF0F172A);
        border = const BorderSide(color: Color(0xFFE2E8F0));
        break;
      case AppButtonVariant.secondary:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF0F172A);
        break;
      case AppButtonVariant.ghost:
        bgColor = Colors.transparent;
        textColor = const Color(0xFF0F172A);
        break;
      case AppButtonVariant.destructive:
        bgColor = const Color(0xFFEF4444);
        textColor = Colors.white;
        break;
      case AppButtonVariant.link:
        bgColor = Colors.transparent;
        textColor = const Color(0xFF6C63FF);
        break;
      default:
        break;
    }

    // --- Konfigurasi Ukuran (Padding & Height) ---
    double height = 40;
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16);
    double fontSize = 14;

    if (size == AppButtonSize.sm) {
      height = 32;
      padding = const EdgeInsets.symmetric(horizontal: 12);
      fontSize = 12;
    } else if (size == AppButtonSize.lg) {
      height = 48;
      padding = const EdgeInsets.symmetric(horizontal: 24);
      fontSize = 16;
    } else if (size == AppButtonSize.icon) {
      height = 40;
      width ?? 40;
      padding = EdgeInsets.zero;
    }

    return SizedBox(
      width: width,
      height: height,
      child: Opacity(
        opacity: (onPressed == null || isDisabled) ? 0.5 : 1.0,
        child: ElevatedButton(
          onPressed: (isDisabled) ? null : onPressed,
          style:
              ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: textColor,
                elevation: 0,
                padding: padding,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: border,
                ),
                textStyle: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ).copyWith(
                // Efek hover/press sederhana untuk Ghost/Link
                overlayColor: WidgetStateProperty.all(
                  textColor.withOpacity(0.05),
                ),
              ),
          child: child,
        ),
      ),
    );
  }
}
