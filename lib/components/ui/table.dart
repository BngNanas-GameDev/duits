import 'package:flutter/material.dart';

class AppTable extends StatelessWidget {
  final List<Widget> children;
  final Widget? caption;

  const AppTable({super.key, required this.children, this.caption});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Table Container (overflow-x-auto) ---
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 32,
            ),
            child: Column(children: children),
          ),
        ),
        if (caption != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: DefaultTextStyle(
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B), // text-muted-foreground
              ),
              child: caption!,
            ),
          ),
      ],
    );
  }
}

class AppTableHeader extends StatelessWidget {
  final List<Widget> children;

  const AppTableHeader({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(children: children),
    );
  }
}

class AppTableRow extends StatelessWidget {
  final List<Widget> children;
  final bool isHeader;
  final bool isFooter;
  final VoidCallback? onTap;

  const AppTableRow({
    super.key,
    required this.children,
    this.isHeader = false,
    this.isFooter = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isFooter ? const Color(0xFFF1F5F9).withOpacity(0.5) : null,
          border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: Row(children: children),
      ),
    );
  }
}

class AppTableCell extends StatelessWidget {
  final Widget child;
  final bool isHeader;
  final double? width;

  const AppTableCell({
    super.key,
    required this.child,
    this.isHeader = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12.0), // p-2 di Shadcn (8px) disesuaikan
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: 14,
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
          color: const Color(0xFF1F2937),
        ),
        child: child,
      ),
    );
  }
}
