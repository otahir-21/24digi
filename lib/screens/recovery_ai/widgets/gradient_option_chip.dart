import 'package:flutter/material.dart';
import 'package:kivi_24/widgets/gradient_border_wrapper.dart';

class GradientOptionChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const GradientOptionChip({
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
        child: isSelected
            ? Container(
                height: 43,
                padding: EdgeInsets.symmetric(horizontal: 22),
                decoration: BoxDecoration(
                  color: Color(0xff0c201d).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Color(0xff6FFFE9)),
                ),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: "HelveticaNeue",
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff6FFFE9),
                    ),
                  ),
                ),
              )
            : GradientBorderWrapper(
                borderRadius: 40,
                height: 43,
                borderWidth: 2,
                innerColor: const Color(0xff000300),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xffA8B3BA),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
