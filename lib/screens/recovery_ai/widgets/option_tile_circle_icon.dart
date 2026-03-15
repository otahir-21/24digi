import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class OptionTileCircleIcon extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionTileCircleIcon({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicWidth(
          child:Container(
            height: 53* s,
            padding: EdgeInsets.symmetric(horizontal: 15* s,),
            decoration: BoxDecoration(
              color: Color(0xff000300),
              borderRadius: BorderRadius.circular(15* s),
              border: Border.all(color: isSelected ? Color(0xffC084FC) : Color(0xff26313A)),
            ),
            child: Center(
              child: Row(
                spacing: 4* s,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontSize: 18* s,
                        fontWeight: FontWeight.w500,
                        color: Color(0xffEAF2F5),
                      ),
                    ),
                  ),
                  Image.asset("assets/icons/check_point.png")
                ],
              ),
            ),
          )
      ),
    );
  }
}
