import 'package:flutter/material.dart';

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
    this.descriptionList, this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: showDescription
          ? padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 10)
          : const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? const Color(0xffA8B3BA),
          width: 0.2,
        ),
        borderRadius: BorderRadius.circular(25),
        color: backgroundColor ?? const Color(0xff151B20).withOpacity(0.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: showDescription
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          if (prefixIcon != null) ...[
            prefixIcon!,
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(
              title,
              textAlign: showDescription ? TextAlign.start : TextAlign.center,
              style: TextStyle(
                fontFamily: "HelveticaNeueLight",
                fontSize: titleFontSize,
                fontWeight: titleFontWeight,
                color: fontColor ?? const Color(0xffA8B3BA),
              ),
            ),
          ),
          if(trailing != null) trailing!,
          if (showDescription) ...[
            const SizedBox(height: 8),
            if (descriptionList != null)
              ...descriptionList!.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• ", style: TextStyle(color: Color(0xffC084FC), fontSize: 18)),
                    SizedBox(width: 10,),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontFamily: "HelveticaNeueLight",
                          fontSize: descriptionFontSize ?? 14,
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
                  fontSize: descriptionFontSize ?? 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xffA8B3BA),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
