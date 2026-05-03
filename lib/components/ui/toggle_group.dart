import 'package:flutter/material.dart';

enum AppToggleGroupVariant { defaultVariant, outline }

enum AppToggleGroupSize { sm, defaultSize, lg }

class AppToggleGroup<T> extends StatelessWidget {
  final List<T> values;
  final T selectedValue;
  final List<Widget> icons;
  final List<String>? labels;
  final ValueChanged<T> onChanged;
  final AppToggleGroupVariant variant;
  final AppToggleGroupSize size;

  const AppToggleGroup({
    super.key,
    required this.values,
    required this.selectedValue,
    required this.icons,
    required this.onChanged,
    this.labels,
    this.variant = AppToggleGroupVariant.defaultVariant,
    this.size = AppToggleGroupSize.defaultSize,
  }) : assert(values.length == icons.length);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: variant == AppToggleGroupVariant.outline
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(values.length, (index) {
          final bool isSelected = values[index] == selectedValue;
          final bool isFirst = index == 0;
          final bool isLast = index == values.length - 1;

          return _ToggleItem(
            isSelected: isSelected,
            isFirst: isFirst,
            isLast: isLast,
            variant: variant,
            size: size,
            icon: icons[index],
            label: labels != null ? labels![index] : null,
            onPressed: () => onChanged(values[index]),
          );
        }),
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final bool isSelected;
  final bool isFirst;
  final bool isLast;
  final AppToggleGroupVariant variant;
  final AppToggleGroupSize size;
  final Widget icon;
  final String? label;
  final VoidCallback onPressed;

  const _ToggleItem({
    required this.isSelected,
    required this.isFirst,
    required this.isLast,
    required this.variant,
    required this.size,
    required this.icon,
    this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6C63FF);
    const Color borderColor = Color(0xFFE2E8F0);

    // Menentukan Border Radius (first:rounded-l-md last:rounded-r-md)
    BorderRadius borderRadius = BorderRadius.zero;
    if (isFirst && isLast) {
      borderRadius = BorderRadius.circular(8);
    } else if (isFirst) {
      borderRadius = const BorderRadius.horizontal(left: Radius.circular(8));
    } else if (isLast) {
      borderRadius = const BorderRadius.horizontal(right: Radius.circular(8));
    }

    // Menentukan Ukuran (Size)
    double height = 36;
    double padding = 12;
    double fontSize = 14;
    if (size == AppToggleGroupSize.sm) {
      height = 32;
      padding = 8;
      fontSize = 12;
    } else if (size == AppToggleGroupSize.lg) {
      height = 44;
      padding = 16;
      fontSize = 16;
    }

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: padding),
        decoration: BoxDecoration(
          color: isSelected
              ? (variant == AppToggleGroupVariant.outline
                    ? const Color(0xFFF1F5F9)
                    : primaryColor.withOpacity(0.1))
              : Colors.white,
          borderRadius: borderRadius,
          border: variant == AppToggleGroupVariant.outline
              ? Border(
                  top: const BorderSide(color: borderColor),
                  bottom: const BorderSide(color: borderColor),
                  right: isLast
                      ? const BorderSide(color: borderColor)
                      : BorderSide.none,
                  left: isFirst
                      ? const BorderSide(color: borderColor)
                      : const BorderSide(color: borderColor),
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(
              data: IconThemeData(
                size: 16,
                color: isSelected ? primaryColor : const Color(0xFF64748B),
              ),
              child: icon,
            ),
            if (label != null) ...[
              const SizedBox(width: 8),
              Text(
                label!,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? primaryColor : const Color(0xFF1F2937),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
