import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment crossAxisAlignment;

  const AppCard({
    super.key,
    required this.children,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // rounded-xl
        border: Border.all(color: const Color(0xFFE2E8F0)), // border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );
  }
}

class AppCardHeader extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? action; // CardAction di React

  const AppCardHeader({
    super.key,
    required this.title,
    this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0), // px-6 pt-6
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CardTitle
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    height: 1.2,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  // CardDescription
                  Text(
                    description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B), // text-muted-foreground
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

class AppCardContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppCardContent({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24), // px-6
      child: child,
    );
  }
}

class AppCardFooter extends StatelessWidget {
  final Widget child;
  final bool borderTop;

  const AppCardFooter({super.key, required this.child, this.borderTop = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24), // px-6 pb-6
      decoration: BoxDecoration(
        border: borderTop
            ? const Border(top: BorderSide(color: Color(0xFFF1F5F9)))
            : null,
      ),
      child: child,
    );
  }
}
