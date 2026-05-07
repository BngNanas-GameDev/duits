import 'package:flutter/material.dart';

class AppSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final bool isDisabled;

  const AppSlider({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 100.0,
    this.onChanged,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    // --- Warna Shadcn Style ---
    const Color primaryIndigo = Color(0xFF6C63FF);
    const Color mutedColor = Color(0xFFF1F5F9);

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight:
              4.0, // Setara data-[orientation=horizontal]:h-4 (visual height)
          activeTrackColor: primaryIndigo,
          inactiveTrackColor: mutedColor,

          // --- Custom Thumb (Slider-Thumb) ---
          thumbColor: Colors.white,
          thumbShape: const RoundSliderThumbShape(
            enabledThumbRadius: 8.0, // size-4 (16px diameter)
            elevation: 2,
            pressedElevation: 4,
          ),

          // Efek ring/halo saat fokus/hover
          overlayColor: primaryIndigo.withOpacity(0.1),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),

          // Track styling
          trackShape: const RoundedRectSliderTrackShape(),
        ),
        child: Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: isDisabled ? null : onChanged,
        ),
      ),
    );
  }
}

// --- Varian Range Slider (Jika butuh multi-thumb seperti di React) ---
class AppRangeSlider extends StatelessWidget {
  final RangeValues values;
  final double min;
  final double max;
  final ValueChanged<RangeValues>? onChanged;

  const AppRangeSlider({
    super.key,
    required this.values,
    this.min = 0.0,
    this.max = 100.0,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryIndigo = Color(0xFF6C63FF);

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: primaryIndigo,
        inactiveTrackColor: const Color(0xFFF1F5F9),
        thumbColor: Colors.white,
        rangeThumbShape: const RoundRangeSliderThumbShape(
          enabledThumbRadius: 8,
          elevation: 2,
        ),
      ),
      child: RangeSlider(
        values: values,
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    );
  }
}
