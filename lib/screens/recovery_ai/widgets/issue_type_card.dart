import 'package:flutter/material.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Color(0xffC084FC) : Color(0xff26313A),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
          color: Color(0xff151b20).withValues(alpha: 0.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(icon, width: 20, height: 20),
                Image.asset(
                  "assets/icons/check_point.png",
                  width: 24,
                  height: 24,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              issue,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                fontFamily: "HelveticaNeue",
                fontSize: 18,
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
