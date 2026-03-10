import 'package:flutter/material.dart';

class OptionTile extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final String icon;
  final bool showPrefix;
  final Color backgroundColor;
  final double verticalSpace;
  final Color borderColor;
  final double borderRadius;
  final double titleFontSize;
  final double descriptionFontSize;
  final Color titleColor;
  final Color descriptionColor;
  final bool showSuffixIcon;
  final String suffixIcon;
  final FontWeight titleFontWeight;
  final double? verticalPadding;

  const OptionTile({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.icon,
    required this.description,
    this.showPrefix = true,
    this.backgroundColor = Colors.transparent,
    this.verticalSpace = 0,
    this.borderColor = const Color(0xff6B7680),
    this.borderRadius = 25,
    this.titleFontSize = 18,
    this.titleColor = const Color(0xffEAF2F5),
    this.descriptionColor = const Color(0xffA8B3BA),
    this.descriptionFontSize = 11,
    this.showSuffixIcon = false,
    this.suffixIcon = "assets/icons/maki_arrow.png",
    this.titleFontWeight = FontWeight.w500, this.verticalPadding
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:  EdgeInsets.symmetric(horizontal: 16, vertical: verticalPadding ?? 0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isSelected ? const Color(0xFFC084FC) : borderColor,
            width: 1.8,
          ),
        ),
        child: Row(
          children: [
            showPrefix
                ? Container(
                    width: 37.93,
                    height: 37.93,
                    margin: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFC084FC)
                          : const Color(0xFF26313A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      icon,
                      color: isSelected ? Color(0xff151B20) : Color(0xffC084FC),
                    ),
                  )
                : SizedBox.shrink(),
            SizedBox(width: showPrefix ? 15 : 0),

            /// Text Label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: "HelveticaNeue",
                      fontSize: titleFontSize,
                      fontWeight: titleFontWeight,
                      color: titleColor,
                    ),
                  ),
                  SizedBox(height: verticalSpace),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: "HelveticaNeue",
                      fontSize: descriptionFontSize,
                      fontWeight: FontWeight.w500,
                      color: descriptionColor,
                    ),
                  ),
                ],
              ),
            ),

            /// Custom Checkbox
            showSuffixIcon
                ? Image.asset(suffixIcon)
                : Container(
                    width: 28.73,
                    height: 28.73,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFC084FC)
                            : const Color(0xFF6B7680),
                        width: 2,
                      ),
                      color: isSelected
                          ? const Color(0xFFC084FC)
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : null,
                  ),
          ],
        ),
      ),
    );
  }
}
