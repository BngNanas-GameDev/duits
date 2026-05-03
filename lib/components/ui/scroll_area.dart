import 'package:flutter/material.dart';

enum ScrollOrientation { vertical, horizontal }

class AppScrollArea extends StatelessWidget {
  final Widget child;
  final ScrollOrientation orientation;
  final double? maxHeight;
  final double? maxWidth;
  final EdgeInsets padding;

  const AppScrollArea({
    super.key,
    required this.child,
    this.orientation = ScrollOrientation.vertical,
    this.maxHeight,
    this.maxWidth,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final ScrollController controller = ScrollController();

    return Theme(
      data: Theme.of(context).copyWith(
        scrollbarTheme: ScrollbarThemeData(
          // Menyamakan warna dengan bg-border (#E2E8F0)
          thumbColor: WidgetStateProperty.all(const Color(0xFFE2E8F0)),
          thickness: WidgetStateProperty.all(6.0),
          radius: const Radius.circular(100), // rounded-full
          minThumbLength: 40,
          // Mengatur agar scrollbar muncul saat ada interaksi
          interactive: true,
        ),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: maxHeight ?? double.infinity,
          maxWidth: maxWidth ?? double.infinity,
        ),
        child: Scrollbar(
          controller: controller,
          thumbVisibility: false, // Set true jika ingin scrollbar selalu muncul
          child: SingleChildScrollView(
            controller: controller,
            scrollDirection: orientation == ScrollOrientation.vertical
                ? Axis.vertical
                : Axis.horizontal,
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
