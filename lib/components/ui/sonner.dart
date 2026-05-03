import 'package:flutter/material.dart';

enum ToastType { normal, success, error, info }

class AppToaster {
  static void show(
    BuildContext context, {
    required String message,
    String? description,
    ToastType type = ToastType.normal,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);

    // --- Warna Shadcn Style ---
    Color backgroundColor = Colors.white;
    Color textColor = const Color(0xFF1F2937); // popover-foreground
    Color borderColor = const Color(0xFFE2E8F0); // border
    IconData? icon;

    switch (type) {
      case ToastType.success:
        icon = Icons.check_circle_outline;
        break;
      case ToastType.error:
        icon = Icons.error_outline;
        break;
      case ToastType.info:
        icon = Icons.info_outline;
        break;
      default:
        icon = null;
    }

    final entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        left: 20,
        right: 20,
        child: _ToastWidget(
          message: message,
          description: description,
          backgroundColor: backgroundColor,
          textColor: textColor,
          borderColor: borderColor,
          icon: icon,
          onDismiss: () {},
        ),
      ),
    );

    overlay.insert(entry);

    // Otomatis hapus setelah durasi selesai
    Future.delayed(duration, () {
      if (entry.mounted) entry.remove();
    });
  }
}

class _ToastWidget extends StatelessWidget {
  final String message;
  final String? description;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData? icon;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    this.description,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    this.icon,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: textColor),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
