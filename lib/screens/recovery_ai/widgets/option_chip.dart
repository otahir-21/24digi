import 'package:flutter/material.dart';

class OptionChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionChip({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicWidth(
        child:Container(
          height: 53,
          padding: EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            color: Color(0xff000300),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isSelected ? Color(0xffC084FC) : Color(0xff26313A)),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: "HelveticaNeue",
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xffEAF2F5),
              ),
            ),
          ),
        )
      ),
    );
  }
}
