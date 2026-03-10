import 'package:flutter/material.dart';

class TitledActionCard extends StatelessWidget {
  final String title;
  final double titleFontSize;
  final FontWeight titleFontWeight;
  final Color? fontColor;
  final Color? borderColor;
  final Color? backgroundColor;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const TitledActionCard({
    super.key,
    required this.title,
    required this.child,
    this.titleFontSize = 24,
    this.titleFontWeight = FontWeight.w700,
    this.fontColor,
    this.borderColor,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? const Color(0xffA8B3BA).withOpacity(0.2),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(25),
        color: backgroundColor ?? const Color(0xff151B20).withOpacity(0.4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: "HelveticaNeueLight",
              fontSize: titleFontSize,
              fontWeight: titleFontWeight,
              color: fontColor ?? const Color(0xffC084FC),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Color(0xffC084FC), thickness: 1, height: 1),
          ),
          child,
        ],
      ),
    );
  }
}
