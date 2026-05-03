import 'package:flutter/material.dart';

class AppRadioGroup<T> extends StatelessWidget {
  final T value;
  final List<AppRadioGroupItem<T>> items;
  final ValueChanged<T?> onChanged;
  final double gap;

  const AppRadioGroup({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.gap = 12.0, // grid gap-3
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: EdgeInsets.only(bottom: item == items.last ? 0 : gap),
          child: _buildItem(item),
        );
      }).toList(),
    );
  }

  Widget _buildItem(AppRadioGroupItem<T> item) {
    const Color primaryColor = Color(0xFF6C63FF);
    const Color borderColor = Color(0xFFE2E8F0);

    return InkWell(
      onTap: item.isDisabled ? null : () => onChanged(item.value),
      borderRadius: BorderRadius.circular(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16, // size-4
            height: 16,
            child: Radio<T>(
              value: item.value,
              groupValue: value,
              onChanged: item.isDisabled ? null : onChanged,
              activeColor: primaryColor,
              // Menghilangkan padding bawaan Material agar ukurannya presisi
              visualDensity: const VisualDensity(
                horizontal: VisualDensity.minimumDensity,
                vertical: VisualDensity.minimumDensity,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return primaryColor;
                return borderColor;
              }),
            ),
          ),
          if (item.label != null) ...[
            const SizedBox(width: 10),
            Text(
              item.label!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: item.isDisabled ? Colors.grey : const Color(0xFF1F2937),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AppRadioGroupItem<T> {
  final T value;
  final String? label;
  final bool isDisabled;

  AppRadioGroupItem({required this.value, this.label, this.isDisabled = false});
}
