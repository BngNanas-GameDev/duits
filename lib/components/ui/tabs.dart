import 'package:flutter/material.dart';

class AppTabs extends StatelessWidget {
  final int length;
  final List<String> triggers;
  final List<Widget> contents;
  final ValueChanged<int>? onIndexChanged;

  const AppTabs({
    super.key,
    required this.length,
    required this.triggers,
    required this.contents,
    this.onIndexChanged,
  }) : assert(triggers.length == length && contents.length == length);

  @override
  Widget build(BuildContext context) {
    // --- Warna Shadcn Style ---
    const Color mutedBg = Color(0xFFF1F5F9); // bg-muted
    const Color mutedText = Color(0xFF64748B); // text-muted-foreground
    const Color activeText = Color(0xFF0F172A); // text-foreground
    const Color activeBg = Colors.white; // bg-card

    return DefaultTabController(
      length: length,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- TabsList ---
          Container(
            height: 40, // h-9 + padding
            padding: const EdgeInsets.all(4), // p-[3px]
            decoration: BoxDecoration(
              color: mutedBg,
              borderRadius: BorderRadius.circular(12), // rounded-xl
            ),
            child: TabBar(
              onTap: onIndexChanged,
              splashFactory:
                  NoSplash.splashFactory, // Hilangkan efek ripple Material
              dividerColor: Colors.transparent, // Hilangkan garis bawah default
              indicatorSize: TabBarIndicatorSize.tab,
              // --- TabsTrigger (Active State) ---
              indicator: BoxDecoration(
                color: activeBg,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              labelColor: activeText,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelColor: mutedText,
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: triggers.map((title) => Tab(text: title)).toList(),
            ),
          ),
          const SizedBox(height: 12), // gap-2
          // --- TabsContent ---
          Flexible(
            child: SizedBox(
              height:
                  400, // Sesuaikan atau gunakan Expanded jika di dalam Column utama
              child: TabBarView(children: contents),
            ),
          ),
        ],
      ),
    );
  }
}
