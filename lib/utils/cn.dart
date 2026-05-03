import 'package:flutter/material.dart';

class AppUtils {
  /// Pengganti cn() untuk TextStyle
  /// Menggabungkan banyak style, yang paling kanan akan menimpa yang kiri jika ada konflik.
  static TextStyle cnText(TextStyle base, [TextStyle? override]) {
    if (override == null) return base;
    return base.merge(override);
  }

  /// Pengganti cn() untuk List of Widgets
  /// Membersihkan null secara otomatis (seperti clsx)
  static List<Widget> cnWidgets(List<Widget?> inputs) {
    return inputs.whereType<Widget>().toList();
  }
}
