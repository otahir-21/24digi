import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

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
    final s = UIScale.of(context);
    return Container(
      padding:
          padding ??  EdgeInsets.symmetric(horizontal: 30* s, vertical: 20* s),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? const Color(0xffA8B3BA).withOpacity(0.2),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(25* s),
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
              fontSize: titleFontSize* s,
              fontWeight: titleFontWeight,
              color: fontColor ?? const Color(0xffC084FC),
            ),
          ),
            Padding(
            padding: EdgeInsets.symmetric(vertical: 10* s),
            child: Divider(color: Color(0xffC084FC), thickness: 1, height: 1),
          ),
          child,
        ],
      ),
    );
  }
}
