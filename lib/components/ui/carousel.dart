import 'package:flutter/material.dart';

class AppCarousel extends StatefulWidget {
  final List<Widget> items;
  final Axis orientation;
  final double viewportFraction;
  final bool loop;

  const AppCarousel({
    super.key,
    required this.items,
    this.orientation = Axis.horizontal,
    this.viewportFraction = 1.0,
    this.loop = false,
  });

  @override
  State<AppCarousel> createState() => _AppCarouselState();
}

class _AppCarouselState extends State<AppCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  bool get canScrollPrev => _currentIndex > 0;
  bool get canScrollNext => _currentIndex < widget.items.length - 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: widget.viewportFraction);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void scrollPrev() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void scrollNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // CarouselContent
        SizedBox(
          height: 200, // Sesuaikan dengan kebutuhan UI kamu
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: _pageController,
                scrollDirection: widget.orientation,
                itemCount: widget.items.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  // CarouselItem
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: widget.items[index],
                  );
                },
              ),

              // CarouselPrevious (Navigasi Kiri)
              if (canScrollPrev)
                Positioned(
                  left: 10,
                  child: _buildNavButton(Icons.chevron_left, scrollPrev),
                ),

              // CarouselNext (Navigasi Kanan)
              if (canScrollNext)
                Positioned(
                  right: 10,
                  child: _buildNavButton(Icons.chevron_right, scrollNext),
                ),
            ],
          ),
        ),

        // Bonus: Dot Indicators (Sering dibutuhkan di Carousel)
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.items.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? const Color(0xFF6C63FF)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF1F2937)),
      ),
    );
  }
}
