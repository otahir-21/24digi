import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class OptionChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final double? borderRadius;
  final double? height;
  final double? width;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? horizontalPadding;
  final Color? fontColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? isSelectedBorderColor;

  const OptionChip({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.borderRadius,
    this.height,
    this.width,
    this.fontSize,
    this.fontWeight,
    this.horizontalPadding,
    this.fontColor,
    this.backgroundColor, this.borderColor, this.isSelectedBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicWidth(
        child: Container(
          height: height ?? 53 * s,
          width: width ?? double.infinity,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? 22 * s),
          decoration: BoxDecoration(
            color: backgroundColor ??Color(0xff000300),
            borderRadius: BorderRadius.circular(borderRadius ?? 15 * s),
            border: Border.all(
              color:  isSelected ? isSelectedBorderColor ?? Color(0xffC084FC) : borderColor ?? Color(0xff26313A),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: "HelveticaNeue",
                fontSize: fontSize ?? 18 * s,
                fontWeight: fontWeight ?? FontWeight.w500,
                color: fontColor ?? Color(0xffEAF2F5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
