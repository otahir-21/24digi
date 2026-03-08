import 'package:flutter/material.dart';

class DescriptionWidget extends StatelessWidget {
  final String text;
  final Color? borderColor;
  final Color? backgroundColor;
  final Widget? prefixIcon;
  final Color? fontColor;

  const DescriptionWidget({
    super.key,
    required this.text,
    this.borderColor, // Dynamic border
    this.backgroundColor, // Dynamic background
    this.prefixIcon, this.fontColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      decoration: BoxDecoration(
        // Use provided color or fallback to your default
        border: Border.all(
          color: borderColor ?? const Color(0xffA8B3BA),
          width: 0.2,
        ),
        borderRadius: BorderRadius.circular(25),
        color: backgroundColor ?? const Color(0xff151B20).withOpacity(0.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Shrinks to fit content
        mainAxisAlignment: MainAxisAlignment.center, // Centers the content
        crossAxisAlignment: CrossAxisAlignment.center, // Vertically aligns icon & text
        children: [
          if (prefixIcon != null) ...[
            prefixIcon!,
            const SizedBox(width: 10), // Space between icon and text
          ],
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style:  TextStyle(
                fontFamily: "HelveticaNeueLight",
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: fontColor?? Color(0xffA8B3BA),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
