import 'package:flutter/material.dart';

class ImageWithFallback extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const ImageWithFallback({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        // --- LOADING STATE (Opsional) ---
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: const Color(0xFFF3F4F6), // bg-gray-100
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF6C63FF),
              ),
            ),
          );
        },
        // --- ERROR STATE (Pengganti ImageWithFallback.tsx) ---
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: const Color(0xFFF3F4F6), // bg-gray-100
            child: Center(
              child: Opacity(
                opacity: 0.3,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: (width != null && width! < 50) ? 20 : 40,
                  color: Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
