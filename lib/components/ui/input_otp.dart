import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppInputOTP extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final bool isDisabled;

  const AppInputOTP({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.isDisabled = false,
  });

  @override
  State<AppInputOTP> createState() => _AppInputOTPState();
}

class _AppInputOTPState extends State<AppInputOTP> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _showCaret = true;
  Timer? _caretTimer;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
      if (_focusNode.hasFocus) _startCaretBlink();
    });
  }

  void _startCaretBlink() {
    _caretTimer?.cancel();
    _caretTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) setState(() => _showCaret = !_showCaret);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _caretTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Hidden TextField untuk menangani input asli
        Opacity(
          opacity: 0,
          child: SizedBox(
            width: 0,
            height: 0,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.length),
              ],
              onChanged: (val) {
                if (val.length == widget.length) {
                  widget.onCompleted(val);
                }
                setState(() {});
              },
            ),
          ),
        ),

        // Visual Slots (UI yang tampil)
        GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: Row(mainAxisSize: MainAxisSize.min, children: _buildSlots()),
        ),
      ],
    );
  }

  List<Widget> _buildSlots() {
    List<Widget> slots = [];
    for (int i = 0; i < widget.length; i++) {
      // Logic Separator (InputOTPSeparator) di tengah
      if (i == widget.length / 2) {
        slots.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.remove, size: 16, color: Color(0xFF94A3B8)),
          ),
        );
      }

      final String char = _controller.text.length > i
          ? _controller.text[i]
          : "";
      final bool isActive = _isFocused && _controller.text.length == i;

      slots.add(
        _AppOTPSlot(
          char: char,
          isActive: isActive,
          showCaret: _showCaret && isActive,
          isFirst: i == 0,
          isLast: i == widget.length - 1,
        ),
      );
    }
    return slots;
  }
}

class _AppOTPSlot extends StatelessWidget {
  final String char;
  final bool isActive;
  final bool showCaret;
  final bool isFirst;
  final bool isLast;

  const _AppOTPSlot({
    required this.char,
    required this.isActive,
    required this.showCaret,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isActive ? const Color(0xFF6C63FF) : const Color(0xFFE2E8F0),
          width: isActive ? 2 : 1,
        ),
        // Membuat efek rounded hanya di ujung grup (InputOTPGroup)
        borderRadius: BorderRadius.only(
          topLeft: isFirst ? const Radius.circular(8) : Radius.zero,
          bottomLeft: isFirst ? const Radius.circular(8) : Radius.zero,
          topRight: isLast ? const Radius.circular(8) : Radius.zero,
          bottomRight: isLast ? const Radius.circular(8) : Radius.zero,
        ),
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            char,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          if (showCaret)
            Container(width: 1.5, height: 20, color: const Color(0xFF6C63FF)),
        ],
      ),
    );
  }
}
