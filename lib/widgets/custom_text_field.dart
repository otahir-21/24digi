import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final Color borderColor;
  final Color backgroundColor;
  final double borderRadius;
  final int? maxLines;
  final int? minLines;
  final double? height;
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
    final s = UIScale.of(context);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius * s),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        minLines: minLines,
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.white, fontSize: 14 * s),
        decoration: InputDecoration(
          isDense: true,
          contentPadding:  EdgeInsets.symmetric(horizontal: 20 * s, vertical: 15 * s),
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: "HelveticaNeue",
            fontSize: 14 * s,
            color: Color(0xFF6B7680),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius * s) ,
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius* s),
            borderSide: BorderSide(color: borderColor.withOpacity(0.8), width: 1.5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius* s),
            borderSide: BorderSide(width: 1)
          ),
        ),
      ),
    );
  }
}
