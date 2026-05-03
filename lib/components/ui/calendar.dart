import 'package:flutter/material.dart';

class AppCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const AppCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)), // border-input
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          // --- CUSTOM STYLING SHADCN STYLE ---
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF6C63FF), // day_selected (Indigo)
            onPrimary: Colors.white,
            onSurface: Color(0xFF1F2937), // text-foreground
            secondary: Color(0xFFF1F5F9), // day_today (Accent)
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ),
        child: SizedBox(
          width: 300, // Menyesuaikan lebar agar pas di layar mobile
          height: 350,
          child: CalendarDatePicker(
            initialDate: selectedDate,
            firstDate: firstDate ?? DateTime(2000),
            lastDate: lastDate ?? DateTime(2100),
            onDateChanged: onDateChanged,
          ),
        ),
      ),
    );
  }
}
