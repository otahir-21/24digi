import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class StaticOptionChip extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const StaticOptionChip({
    super.key,
    required this.title,
    required this.onTap,
    this.description = "",
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicWidth(
        child: Container(
          height: 160 * s,
          width:  (MediaQuery.of(context).size.width / 3 )-19,
          padding: EdgeInsets.symmetric(horizontal: 17* s),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(15* s),
            border: Border.all(color: Color(0xffC084FC)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: "HelveticaNeue",
                  fontSize: 18* s,
                  fontWeight: FontWeight.w700,
                  color: Color(0xffEAF2F5),
                ),
              ),
              Text(
                description,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: "HelveticaNeue",
                  fontSize: 14* s,
                  fontWeight: FontWeight.w500,
                  color: Color(0xffA8B3BA),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
