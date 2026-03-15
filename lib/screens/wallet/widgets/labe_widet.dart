import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class LabelWidget extends StatelessWidget {
  final String? title;
  final String? option;
  final VoidCallback? optionOnTap;
  final Color? optionColor;


  const LabelWidget({
    super.key,
    this.title,
    this.option,
    this.optionOnTap,
    this.optionColor,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0 * s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title ?? "",
            style: TextStyle(
              fontFamily: "HelveticaNeue",
              fontSize: 14 * s,
              fontWeight: FontWeight.w500,
              color: Color(0xffFFFFFF),
            ),
          ),
          GestureDetector(
            onTap: optionOnTap,
            child: Text(
              option ?? "",
              style: TextStyle(
                fontFamily: "HelveticaNeue",
                fontSize: 12 * s,
                fontWeight: FontWeight.w500,
                color: optionColor ?? Color(0xff00D4AA),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
