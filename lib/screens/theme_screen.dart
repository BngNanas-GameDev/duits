import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../theme/palette.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  ThemeMode _localThemeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    // Initialize local theme mode from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final themeProvider =
            Provider.of<ThemeProvider>(context, listen: false);
        setState(() {
          _localThemeMode = themeProvider.themeMode;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tema & Warna'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Theme mode selector
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mode Tampilan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pilih tampilan terang atau gelap',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ThemeModeOption(
                        icon: Icons.light_mode_rounded,
                        label: 'Terang',
                        selected:
                            themeProvider.themeMode == ThemeMode.light,
                        onTap: () {
                          setState(() => _localThemeMode = ThemeMode.light);
                          themeProvider.setThemeMode(ThemeMode.light);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ThemeModeOption(
                        icon: Icons.dark_mode_rounded,
                        label: 'Gelap',
                        selected: themeProvider.themeMode == ThemeMode.dark,
                        onTap: () {
                          setState(() => _localThemeMode = ThemeMode.dark);
                          themeProvider.setThemeMode(ThemeMode.dark);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ThemeModeOption(
                        icon: Icons.brightness_auto_rounded,
                        label: 'Sistem',
                        selected:
                            themeProvider.themeMode == ThemeMode.system,
                        onTap: () {
                          setState(() => _localThemeMode = ThemeMode.system);
                          themeProvider.setThemeMode(ThemeMode.system);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Palette selector
          const Text(
            'Warna Tema',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih palet warna favorit Anda',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          // Palette grid
          _PaletteGrid(),
        ],
      ),
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeModeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: selected
              ? Border.all(color: Theme.of(context).colorScheme.primary)
              : Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : Colors.grey.shade600,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaletteGrid extends StatelessWidget {
  const _PaletteGrid();

  @override
  Widget build(BuildContext context) {
    final palettes = AppPalette.values;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: palettes.length,
      itemBuilder: (context, index) {
        final palette = palettes[index];
        final themeProvider =
            Provider.of<ThemeProvider>(context, listen: false);
        final isSelected = themeProvider.palette == palette;

        return _PaletteCard(
          palette: palette,
          selected: isSelected,
          onTap: () {
            themeProvider.setPalette(palette);
          },
        );
      },
    );
  }
}

class _PaletteCard extends StatelessWidget {
  final AppPalette palette;
  final bool selected;
  final VoidCallback onTap;

  const _PaletteCard({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = palette.headerGradientLight;
    final isDark = palette == AppPalette.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: palette.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
          border: selected
              ? Border.all(color: palette.primary, width: 2.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Color swatch preview
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                ),
                child: Stack(
                  children: [
                    // Color dots showing the palette
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ColorDot(
                              color: palette.primary,
                              opacity: isDark ? 1.0 : 0.3),
                          const SizedBox(width: 4),
                          _ColorDot(color: palette.primary),
                          const SizedBox(width: 4),
                          _ColorDot(color: palette.secondary),
                        ],
                      ),
                    ),
                    // Checkmark if selected
                    if (selected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF22C55E),
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Label
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Text(
                palette.displayName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final double opacity;

  const _ColorDot({
    required this.color,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1),
      ),
    );
  }
}
