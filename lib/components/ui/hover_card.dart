import 'package:flutter/material.dart';

class AppHoverCard extends StatefulWidget {
  final Widget trigger;
  final Widget content;
  final double width;

  const AppHoverCard({
    super.key,
    required this.trigger,
    required this.content,
    this.width = 256, // setara w-64
  });

  @override
  State<AppHoverCard> createState() => _AppHoverCardState();
}

class _AppHoverCardState extends State<AppHoverCard> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isVisible = false;

  void _showOverlay() {
    if (_isVisible) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isVisible = true);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isVisible = false);
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Background transparan untuk mendeteksi tap di luar agar menutup (Mobile)
          GestureDetector(
            onTap: _hideOverlay,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            width: widget.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomCenter,
              followerAnchor: Alignment.topCenter,
              offset: const Offset(0, 8), // sideOffset = 4
              child: Material(
                color: Colors.transparent,
                child: MouseRegion(
                  onEnter: (_) => _showOverlay(),
                  onExit: (_) => _hideOverlay(),
                  child: Container(
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
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: widget.content,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => _showOverlay(),
        onExit: (_) => _hideOverlay(),
        child: GestureDetector(
          onLongPress: _showOverlay, // Support mobile via long press
          child: widget.trigger,
        ),
      ),
    );
  }
}
