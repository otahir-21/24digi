import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final Color borderColor;
  final Color backgroundColor;
  final double borderRadius;
  final int? maxLines;
  final int? minLines;
  final double? height; // To fix height for note areas
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.borderColor = const Color(0xffC084FC),
    this.backgroundColor = Colors.transparent,
    this.borderRadius = 16,
    this.maxLines = 1,
    this.minLines = 1,
    this.height,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        minLines: minLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: "HelveticaNeue",
            fontSize: 14,
            color: Color(0xFF6B7680),
          ),
          // Enabled Border
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          // Focused Border (changes color when user clicks)
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor.withOpacity(0.8), width: 1.5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(width: 1)
          ),
        ),
      ),
    );
  }
}
