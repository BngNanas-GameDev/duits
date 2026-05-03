import 'package:flutter/material.dart';

class AppSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? child;

  const AppSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.child,
  });

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Kecepatan pulse
    )..repeat(reverse: true); // Animasi bolak-balik (pulse)

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Warna dasar skeleton (bg-accent/muted)
    const Color skeletonColor = Color(0xFFF1F5F9);

    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: skeletonColor,
          borderRadius:
              widget.borderRadius ?? BorderRadius.circular(8), // rounded-md
        ),
        child: widget.child,
      ),
    );
  }
}
