import 'package:flutter/material.dart';

class AppSelectItem<T> {
  final T value;
  final String label;
  final Widget? icon;
  final bool isDisabled;

  AppSelectItem({
    required this.value,
    required this.label,
    this.icon,
    this.isDisabled = false,
  });
}

class AppSelect<T> extends StatelessWidget {
  final T? value;
  final List<AppSelectItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String placeholder;
  final bool isDisabled;
  final String? label;
  final double? width;

  const AppSelect({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.placeholder = "Pilih opsi...",
    this.isDisabled = false,
    this.label,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    const Color borderColor = Color(0xFFE2E8F0);
    const Color primaryColor = Color(0xFF6C63FF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: width ?? double.infinity,
          child: PopupMenuButton<T>(
            enabled: !isDisabled,
            initialValue: value,
            onSelected: onChanged,
            offset: const Offset(0, 45), // sideOffset = 4
            elevation: 4,
            surfaceTintColor: Colors.transparent,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: borderColor),
            ),
            // --- SelectTrigger ---
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDisabled ? const Color(0xFFF8FAFC) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _getSelectedLabel(),
                      style: TextStyle(
                        fontSize: 14,
                        color: value == null
                            ? const Color(0xFF94A3B8) // text-muted-foreground
                            : const Color(0xFF1F2937),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons
                        .unfold_more_rounded, // Mirip ChevronDown tapi lebih netral
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
            // --- SelectContent / SelectItem ---
            itemBuilder: (context) => items.map((item) {
              final bool isSelected = item.value == value;

              return PopupMenuItem<T>(
                value: item.value,
                enabled: !item.isDisabled,
                height: 40,
                child: Row(
                  children: [
                    if (item.icon != null) ...[
                      item.icon!,
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check, // SelectItem Indicator
                        size: 16,
                        color: primaryColor,
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getSelectedLabel() {
    if (value == null) return placeholder;
    try {
      return items.firstWhere((element) => element.value == value).label;
    } catch (_) {
      return placeholder;
    }
  }
}
