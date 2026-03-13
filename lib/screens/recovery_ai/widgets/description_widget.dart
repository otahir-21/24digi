import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final double titleFontSize;
  final FontWeight titleFontWeight;
  final Color? borderColor;
  final Color? backgroundColor;
  final Widget? prefixIcon;
  final Color? fontColor;
  final bool showDescription;
  final String description;
  final EdgeInsetsGeometry? padding;
  final double? descriptionFontSize;
  final List<String>? descriptionList;
  final Widget? trailing;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.title,
    this.titleFontSize = 14,
    this.titleFontWeight = FontWeight.w400,
    this.borderColor,
    this.backgroundColor,
    this.prefixIcon,
    this.fontColor,
    this.showDescription = false,
    this.description = "",
    this.padding,
    this. descriptionFontSize,
    this.descriptionList, this.trailing, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: showDescription
            ? padding ??   EdgeInsets.symmetric(horizontal: 10* s, vertical: 10* s)
            :   EdgeInsets.symmetric(horizontal: 30* s, vertical: 30* s),
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor ?? const Color(0xffA8B3BA),
            width: 0.2,
          ),
          borderRadius: BorderRadius.circular(25* s),
          color: backgroundColor ?? const Color(0xff151B20).withOpacity(0.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: showDescription
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                if (prefixIcon != null) ...[
                  prefixIcon!,
                  SizedBox(width: 10* s),
                ],
                Flexible(
                  child: Text(
                    title,
                    textAlign: showDescription ? TextAlign.start : TextAlign.center,
                    style: TextStyle(
                      fontFamily: "HelveticaNeueLight",
                      fontSize: titleFontSize * s,
                      fontWeight: titleFontWeight,
                      color: fontColor ?? const Color(0xffA8B3BA),
                    ),
                  ),
                ),
              ],
            ),
            if(trailing != null) trailing!,
            if (showDescription) ...[
                SizedBox(height: 8* s),
              if (descriptionList != null)
                ...descriptionList!.map((item) => Padding(
                  padding:   EdgeInsets.only(bottom: 4* s),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text("• ", style: TextStyle(color: Color(0xffC084FC), fontSize: 18* s)),
                      SizedBox(width: 10* s,),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontFamily: "HelveticaNeueLight",
                            fontSize: descriptionFontSize ?? 14* s,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xffA8B3BA),
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
              else if (description.isNotEmpty)
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: "HelveticaNeueLight",
                    fontSize: descriptionFontSize ?? 14* s,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xffA8B3BA),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
