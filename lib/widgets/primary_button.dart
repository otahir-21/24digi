import 'package:flutter/material.dart';
import '../core/app_constants.dart';

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

  /// Button width in Figma units. Defaults to 220.
  final double width;

  /// Button height in Figma units. Defaults to 46.
  final double height;

  const PrimaryButton({
    super.key,
    required this.s,
    required this.label,
    required this.onTap,
    this.width = 220,
    this.height = 46,
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
            borderRadius: BorderRadius.circular(30 * s),
            border: Border.all(
              color: AppColors.cyan,
              width: 1.5,
            ),
            color: _pressed
                ? AppColors.cyanTint18
                : _hovered
                    ? AppColors.cyanTint10
                    : Colors.transparent,
            boxShadow: (_hovered || _pressed)
                ? [
                    BoxShadow(
                      color: AppColors.cyanGlow44,
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
            child: ShaderMask(
              shaderCallback: (bounds) =>
                  AppGradients.cyanPurple.createShader(bounds),
              child: Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'LemonMilk',
                  fontSize: 15 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
