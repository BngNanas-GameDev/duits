import 'package:flutter/material.dart';

class AppFormItem extends StatelessWidget {
  final Widget label;
  final Widget child;
  final Widget? description;
  final String? errorMessage;

  const AppFormItem({
    super.key,
    required this.label,
    required this.child,
    this.description,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- FormLabel ---
        DefaultTextStyle(
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: errorMessage != null
                ? const Color(0xFFEF4444) // destructive
                : const Color(0xFF1F2937), // foreground
          ),
          child: label,
        ),
        const SizedBox(height: 8),

        // --- FormControl ---
        child,

        // --- FormDescription ---
        if (description != null && errorMessage == null) ...[
          const SizedBox(height: 8),
          DefaultTextStyle(
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B), // muted-foreground
            ),
            child: description!,
          ),
        ],

        // --- FormMessage ---
        if (errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFEF4444), // destructive
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}

// Helper untuk styling Input (Shadcn Style)
class AppInputDecoration {
  static InputDecoration get({String? hintText, bool hasError = false}) {
    const Color borderColor = Color(0xFFE2E8F0);
    const Color primaryColor = Color(0xFF6C63FF);
    const Color errorColor = Color(0xFFEF4444);

    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      // Hilangkan error text default Flutter karena kita pakai FormMessage kustom
      errorStyle: const TextStyle(height: 0, fontSize: 0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: hasError ? errorColor : borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: hasError ? errorColor : borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: hasError ? errorColor : primaryColor,
          width: 2,
        ),
      ),
    );
  }
}
