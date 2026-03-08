import 'package:flutter/material.dart';
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
    return GestureDetector(
      onTap: onTap,
      child: GradientBorderWrapper(
        borderRadius: 16,
        height: 68,
        // 1. If selected, we hide the gradient by making borderWidth 0
        borderWidth: isSelected ? 0 : 2,
        // 2. If selected, the whole wrapper takes the purple background color
        innerColor:  const Color(0xff000304),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
                width: 37.93,
                height: 37.93,
                decoration: BoxDecoration(
                  color: const Color(0xFF26313A),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 15),
              /// Text Label
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: "HelveticaNeue",
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xffEAF2F5),
                  ),
                ),
              ),
              /// Custom Checkbox
              Container(
                width: 28.73,
                height: 28.73,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
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
