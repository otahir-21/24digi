import 'package:flutter/material.dart';

/// The animated cyan-border gradient-text button used as the primary CTA on
/// every setup screen. Manages its own pressed/hovered state internally so
/// screens don't need extra `bool` state variables for it.
///
/// ```dart
/// PrimaryButton(s: s, label: 'CONTINUE', onTap: () { ... }),
/// PrimaryButton(s: s, label: 'FINISH SETUP', onTap: () { ... }, width: 230),
/// ```
class PrimaryButton extends StatefulWidget {
  final double s;
  final String label;
  final VoidCallback onTap;

  /// Button width in Figma units. Defaults to 182.
  final double width;

  /// Button height in Figma units. Defaults to 42.
  final double height;

  const PrimaryButton({
    super.key,
    required this.s,
    required this.label,
    required this.onTap,
    this.width = 182,
    this.height = 42,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;
  bool _hovered = false;

  double get s => widget.s;

  void _handleTap() {
    setState(() => _pressed = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() => _pressed = false);
        widget.onTap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width * s,
          height: widget.height * s,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100 * s),
            border: Border.all(
              color: const Color(0xFF6FFFE9),
              width: 2.0,
            ),
            color: _pressed
                ? const Color(0xFF1A2A30)
                : const Color(0xFF0E1215),
            boxShadow: (_hovered || _pressed)
                ? [
                    BoxShadow(
                      color: const Color(0x446FFFE9),
                      blurRadius: _pressed ? 20 : 12,
                      spreadRadius: 1,
                    ),
                  ]
                : const [],
          ),
          alignment: Alignment.center,
          child: AnimatedScale(
            scale: _pressed ? 0.94 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'LemonMilk',
                fontSize: 22 * s,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6FFFE9),
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
