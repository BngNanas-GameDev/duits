import 'package:flutter/material.dart';

class AppAlertDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String description,
    required String actionLabel,
    required VoidCallback onAction,
    String cancelLabel = "Batal",
    bool isDestructive = false,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          // --- AlertDialogHeader ---
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          // --- AlertDialogDescription ---
          content: Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          // --- AlertDialogFooter ---
          actionsPadding: const EdgeInsets.only(
            right: 16,
            bottom: 16,
            left: 16,
          ),
          actions: [
            // AlertDialogCancel
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF94A3B8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: Text(
                cancelLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            // AlertDialogAction
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                onAction(); // Jalankan aksi
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDestructive
                    ? const Color(0xFFFF6B6B)
                    : const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
