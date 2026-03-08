import 'package:flutter/material.dart';
import 'package:kivi_24/widgets/gradient_border_wrapper.dart';

class ActivityOptionChip extends StatelessWidget {
  final String icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const ActivityOptionChip({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicWidth(
        child: Container(
          height: 49,
          padding: EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            color: Color(0xff000300),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: isSelected ? Color(0xffC084FC) : Color(0xff6B7680)),
          ),
          child: Row(
            spacing: 12,
            children: [
              Image.asset(icon, color: isSelected ? Color(0xffC084FC) : Color(0xff6B7680),),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: "HelveticaNeue",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff6B7680),
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
