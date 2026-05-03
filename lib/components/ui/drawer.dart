import 'package:flutter/material.dart';

class AppDrawer {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? description,
    Widget? content,
    Widget? footer,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled:
          true, // Memungkinkan drawer mengambil tinggi sesuai konten
      backgroundColor:
          Colors.transparent, // Agar kita bisa custom border radius
      barrierColor: Colors.black.withOpacity(0.5), // DrawerOverlay
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Padding(
              // Menangani padding keyboard jika ada input di dalam drawer
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Drawer Handle (Vaul Style) ---
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0), // bg-muted
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // --- DrawerHeader ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // DrawerTitle
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        if (description != null) ...[
                          const SizedBox(height: 4),
                          // DrawerDescription
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // --- DrawerContent ---
                  if (content != null)
                    Padding(padding: const EdgeInsets.all(24), child: content),

                  // --- DrawerFooter ---
                  if (footer != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: footer,
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
