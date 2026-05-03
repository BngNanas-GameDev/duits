import 'package:flutter/material.dart';

/// Breakpoint yang sama dengan versi React kamu
const int mobileBreakpoint = 768;

extension ResponsiveContext on BuildContext {
  /// Mengecek apakah layar saat ini dikategorikan sebagai Mobile.
  /// Penggunaan: if (context.isMobile) { ... }
  bool get isMobile {
    final double width = MediaQuery.of(this).size.width;
    return width < mobileBreakpoint;
  }

  /// Bonus: Tambahan untuk Tablet jika nanti dibutuhkan di "Duits"
  bool get isTablet {
    final double width = MediaQuery.of(this).size.width;
    return width >= mobileBreakpoint && width < 1024;
  }

  /// Bonus: Tambahan untuk Desktop
  bool get isDesktop => !isMobile && !isTablet;
}
