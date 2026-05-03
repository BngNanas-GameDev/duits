import 'package:flutter/material.dart';

class SidebarController extends ChangeNotifier {
  bool _isOpen = false;

  bool get isOpen => _isOpen;

  void open() {
    _isOpen = true;
    notifyListeners();
  }

  void close() {
    _isOpen = false;
    notifyListeners();
  }

  void toggle() {
    _isOpen = !_isOpen;
    notifyListeners();
  }
}

class AppSidebar extends StatelessWidget {
  final Widget child;
  final Widget? header;
  final Widget? footer;
  final SidebarController controller;

  const AppSidebar({
    super.key,
    required this.child,
    required this.controller,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          return const SizedBox.shrink(); // Mobile menggunakan Drawer standar Scaffold
        }

        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: controller.isOpen
                  ? 260
                  : 80, // SIDEBAR_WIDTH vs ICON_WIDTH
              curve: Curves.easeInOut,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Column(
                children: [
                  ?header,
                  Expanded(child: child),
                  ?footer,
                ],
              ),
            );
          },
        );
      },
    );
  }
}
