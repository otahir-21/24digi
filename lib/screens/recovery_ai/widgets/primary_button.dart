import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? fontColor;
  final double borderRadius;
  final double height;
  final Color? buttonColor;
  final bool isGradient;
  final List<Color>? gradientColorList;
  final Color? borderColor;


  const PrimaryButton({
    super.key,
    required this.title,
    this.onTap,
    this.borderRadius = 25,
    this.fontSize,
    this.height = 58,
    this.buttonColor,
    this.isGradient = false,
    this.gradientColorList,
    this.fontWeight,
    this.fontColor, this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 8* s, vertical: 4* s),
        height: height* s,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: buttonColor ?? const Color(0xFFC084FC),
          borderRadius: BorderRadius.circular(borderRadius * s),
          border: Border.all(color: borderColor  ?? const Color(0xFF26313A), width: 2),
          gradient: isGradient
              ? LinearGradient(
                  begin: AlignmentGeometry.topCenter,
                  end: AlignmentGeometry.bottomCenter,
                  colors: gradientColorList ?? [Colors.white, Colors.black],
                )
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: "HelveticaNeue",
            color: fontColor?? Color(0xFF151B20),
            fontSize: fontSize ?? 26 * s ,
            fontWeight: fontWeight ?? FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
