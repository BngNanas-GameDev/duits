import 'package:flutter/material.dart';
import 'button.dart'; // Mengimport AppButton yang sudah dibuat sebelumnya

class AppPagination extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment alignment;

  const AppPagination({
    super.key,
    required this.children,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: alignment, children: children);
  }
}

class AppPaginationLink extends StatelessWidget {
  final bool isActive;
  final VoidCallback? onPressed;
  final Widget child;

  const AppPaginationLink({
    super.key,
    this.isActive = false,
    this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: AppButton(
        onPressed: onPressed,
        // Jika aktif gunakan variant outline, jika tidak gunakan ghost
        variant: isActive ? AppButtonVariant.outline : AppButtonVariant.ghost,
        size: AppButtonSize.icon,
        child: child,
      ),
    );
  }
}

class AppPaginationPrevious extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isDisabled;

  const AppPaginationPrevious({
    super.key,
    this.onPressed,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onPressed: isDisabled ? null : onPressed,
      variant: AppButtonVariant.ghost,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chevron_left, size: 18),
          SizedBox(width: 4),
          Text("Previous"),
        ],
      ),
    );
  }
}

class AppPaginationNext extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isDisabled;

  const AppPaginationNext({super.key, this.onPressed, this.isDisabled = false});

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onPressed: isDisabled ? null : onPressed,
      variant: AppButtonVariant.ghost,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Next"),
          SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 18),
        ],
      ),
    );
  }
}

class AppPaginationEllipsis extends StatelessWidget {
  const AppPaginationEllipsis({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 40,
      height: 40,
      child: Icon(Icons.more_horiz, color: Color(0xFF64748B), size: 20),
    );
  }
}
