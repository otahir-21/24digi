import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class BottomBorderChip extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final double? fontSize;
  final double? borderRadius;
  final Color? fontColor;

  const BottomBorderChip( {
    super.key,
    required this.title,
    required this.onTap,
    this.width,
    this.height,
    this.fontSize,
    this.borderRadius, this.fontColor,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicWidth(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: height ?? 70 * s,
          width: width ?? (Get.width / 2) - 22,
          // padding:   EdgeInsets.symmetric(horizontal: 22 * s),
          decoration: BoxDecoration(
            color: const Color(0xff000300),
            borderRadius: BorderRadius.circular(borderRadius ?? 15 * s),
            border: Border.all(color: const Color(0xff26313A), width: 1.0),
            boxShadow: [
              const BoxShadow(
                color: Color(0xFFC084FC),
                offset: Offset(0, 1.2),
                blurRadius: 0.5,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: "HelveticaNeue",
                fontSize: fontSize ?? 18 * s,
                fontWeight: FontWeight.w500,
                color: fontColor?? Color(0xffEAF2F5),
                // overflow: TextOverflow.ellipsis
              ),
            ),
          ),
        ),
      ),
    );
  }
}
