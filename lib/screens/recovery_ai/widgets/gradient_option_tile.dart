import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/widgets/gradient_border_wrapper.dart';

class GradientOptionTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const GradientOptionTile({
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
      child: GradientBorderWrapper(
        borderRadius: 16* s,
        height: 68* s,
        // 1. If selected, we hide the gradient by making borderWidth 0
        borderWidth: isSelected ? 0 : 2,
        // 2. If selected, the whole wrapper takes the purple background color
        innerColor:  const Color(0xff000304),
        child: Container(
          padding:   EdgeInsets.symmetric(horizontal: 16* s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16* s),
            // 3. Apply the Solid Purple Border here ONLY when selected
            border: Border.all(
              color: isSelected ? const Color(0xFFC084FC) : Colors.transparent,
              width: isSelected ? 1.5 : 0,
            ),
          ),
          child: Row(
            children: [
              /// Static Prefix Container
              Container(
                width: 37.93* s,
                height: 37.93* s,
                decoration: BoxDecoration(
                  color: const Color(0xFF26313A),
                  borderRadius: BorderRadius.circular(10* s),
                ),
              ),
                SizedBox(width: 15* s),
              /// Text Label
              Expanded(
                child: Text(
                  title,
                  style:  TextStyle(
                    fontFamily: "HelveticaNeue",
                    fontSize: 18* s,
                    fontWeight: FontWeight.w500,
                    color: Color(0xffEAF2F5),
                  ),
                ),
              ),
              /// Custom Checkbox
              Container(
                width: 28.73* s,
                height: 28.73* s,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10* s),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFC084FC) : const Color(0xFF6B7680),
                    width: 2,
                  ),
                  color: isSelected ? const Color(0xFFC084FC) : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
