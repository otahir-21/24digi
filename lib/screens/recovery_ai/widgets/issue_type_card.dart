import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class IssueTypeCard extends StatelessWidget {
  final String icon;
  final String issue;
  final VoidCallback? onTap;
  final bool isSelected;

  const IssueTypeCard({
    super.key,
    required this.icon,
    required this.issue,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 14* s),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Color(0xffC084FC) : Color(0xff26313A),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15 * s),
          color: Color(0xff151b20).withValues(alpha: 0.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(icon, width: 20 * s, height: 20 * s),
                Image.asset(
                  "assets/icons/check_point.png",
                  width: 24* s,
                  height: 24* s,
                ),
              ],
            ),
              SizedBox(height: 10* s),
            Text(
              issue,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontFamily: "HelveticaNeue",
                fontSize: 18 * s,
                fontWeight: FontWeight.w700,
                color: Color(0xffeaf2f5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
