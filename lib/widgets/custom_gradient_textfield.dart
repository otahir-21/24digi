import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';

class CustomGradientTextField extends StatelessWidget {
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;

  const CustomGradientTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: GradientOutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          gradient: RadialGradient(
              radius: 8,
              center: AlignmentGeometry.centerLeft,
              stops: [0.0,0.3,0.7,1],
              colors: [
            Color(0xFF00F0FF).withOpacity(0.5),
            Color(0xffFFFFFF).withValues(alpha: 0.1),
            Color(0xFFCE6AFF).withOpacity(0.8),
            Color(0xFF8726B7).withValues(alpha: 0.0)
          ]),
          width: 2,
        ),
        hintText: hintText,
        hintStyle: const TextStyle(
          fontFamily: "HelveticaNeue",
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Color(0xFF6B7680),
          height: 1.0, // line-height 100%
        ),
        prefixIcon: prefixIcon != null
            ? Padding(padding: const EdgeInsets.all(12), child: prefixIcon)
            : null,
        suffixIcon: suffixIcon != null
            ? Padding(padding: const EdgeInsets.all(12), child: suffixIcon)
            : null,
      ),
    );
  }
}
