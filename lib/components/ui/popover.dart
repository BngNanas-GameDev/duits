import 'package:flutter/material.dart';

class AppPopover extends StatefulWidget {
  final Widget trigger;
  final Widget content;
  final double width;
  final Alignment targetAnchor;
  final Alignment followerAnchor;

  const AppPopover({
    super.key,
    required this.trigger,
    required this.content,
    this.width = 280, // w-72 (288px) disesuaikan ke 280 agar aman di mobile
    this.targetAnchor = Alignment.bottomCenter,
    this.followerAnchor = Alignment.topCenter,
  });

  @override
  State<AppPopover> createState() => _AppPopoverState();
}

class _AppPopoverState extends State<AppPopover> {
  final OverlayPortalController _controller = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: OverlayPortal(
        controller: _controller,
        overlayChildBuilder: (context) {
          return Stack(
            children: [
              // Detector untuk menutup popover saat tap di luar (ModalBarrier style)
              GestureDetector(
                onTap: _controller.hide,
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                targetAnchor: widget.targetAnchor,
                followerAnchor: widget.followerAnchor,
                offset: const Offset(0, 4), // sideOffset = 4
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: widget.width,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16), // p-4
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8), // rounded-md
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ), // border
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: widget.content,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        child: GestureDetector(
          onTap: _controller.toggle,
          child: widget.trigger,
        ),
      ),
    );
  }
}
