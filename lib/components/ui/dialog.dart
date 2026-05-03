import 'package:flutter/material.dart';

class AppDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? description,
    Widget? content,
    Widget? footer,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.5), // DialogOverlay
      builder: (BuildContext context) {
        return Center(
          child: Container(
            // Membatasi lebar agar mirip max-w-lg di React
            constraints: const BoxConstraints(maxWidth: 430),
            margin: const EdgeInsets.all(16),
            child: Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              insetPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // rounded-lg
                side: const BorderSide(color: Color(0xFFE2E8F0)), // border
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0), // p-6
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- DialogHeader ---
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // DialogTitle
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                                height: 1.2,
                              ),
                            ),
                            if (description != null) ...[
                              const SizedBox(height: 8),
                              // DialogDescription
                              Text(
                                description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(
                                    0xFF64748B,
                                  ), // text-muted-foreground
                                ),
                              ),
                            ],
                          ],
                        ),

                        // --- DialogContent ---
                        if (content != null) ...[
                          const SizedBox(height: 24),
                          content,
                        ],

                        // --- DialogFooter ---
                        if (footer != null) ...[
                          const SizedBox(height: 24),
                          footer,
                        ],
                      ],
                    ),
                  ),

                  // --- DialogClose (X Icon) ---
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
