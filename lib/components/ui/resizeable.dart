import 'package:flutter/material.dart';

enum ResizableDirection { horizontal, vertical }

class AppResizableGroup extends StatefulWidget {
  final List<Widget> children;
  final ResizableDirection direction;
  final List<double> initialWeights;

  const AppResizableGroup({
    super.key,
    required this.children,
    this.direction = ResizableDirection.horizontal,
    required this.initialWeights,
  }) : assert(children.length == initialWeights.length);

  @override
  State<AppResizableGroup> createState() => _AppResizableGroupState();
}

class _AppResizableGroupState extends State<AppResizableGroup> {
  late List<double> _weights;

  @override
  void initState() {
    super.initState();
    _weights = List.from(widget.initialWeights);
  }

  void _updateWeights(int index, double delta, double totalSize) {
    setState(() {
      double deltaWeight = delta / totalSize;

      // Memastikan panel tidak menjadi terlalu kecil (min-size logic)
      if (_weights[index] + deltaWeight > 0.1 &&
          _weights[index + 1] - deltaWeight > 0.1) {
        _weights[index] += deltaWeight;
        _weights[index + 1] -= deltaWeight;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double totalSize = widget.direction == ResizableDirection.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;

        List<Widget> childrenWithHandles = [];

        for (int i = 0; i < widget.children.length; i++) {
          childrenWithHandles.add(
            Expanded(
              flex: (_weights[i] * 1000).toInt(),
              child: widget.children[i],
            ),
          );

          // Tambahkan Handle di antara panel
          if (i < widget.children.length - 1) {
            childrenWithHandles.add(
              _AppResizableHandle(
                direction: widget.direction,
                onDrag: (delta) => _updateWeights(i, delta, totalSize),
                withHandle: true,
              ),
            );
          }
        }

        return widget.direction == ResizableDirection.horizontal
            ? Row(children: childrenWithHandles)
            : Column(children: childrenWithHandles);
      },
    );
  }
}

class _AppResizableHandle extends StatelessWidget {
  final ResizableDirection direction;
  final Function(double) onDrag;
  final bool withHandle;

  const _AppResizableHandle({
    required this.direction,
    required this.onDrag,
    this.withHandle = false,
  });

  @override
  Widget build(BuildContext context) {
    const Color borderColor = Color(0xFFE2E8F0);

    return GestureDetector(
      onPanUpdate: (details) {
        onDrag(
          direction == ResizableDirection.horizontal
              ? details.delta.dx
              : details.delta.dy,
        );
      },
      child: MouseRegion(
        cursor: direction == ResizableDirection.horizontal
            ? SystemMouseCursors.resizeLeftRight
            : SystemMouseCursors.resizeUpDown,
        child: Container(
          width: direction == ResizableDirection.horizontal
              ? 8
              : double.infinity,
          height: direction == ResizableDirection.horizontal
              ? double.infinity
              : 8,
          color: Colors.transparent, // Area hit-test yang lebih luas
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Garis pemisah (bg-border)
              Container(
                width: direction == ResizableDirection.horizontal
                    ? 1
                    : double.infinity,
                height: direction == ResizableDirection.horizontal
                    ? double.infinity
                    : 1,
                color: borderColor,
              ),
              // Grip Icon (withHandle logic)
              if (withHandle)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: RotatedBox(
                    quarterTurns: direction == ResizableDirection.horizontal
                        ? 0
                        : 1,
                    child: const Icon(
                      Icons.drag_indicator,
                      size: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
