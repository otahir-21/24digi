import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const PrimaryButton({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFC084FC),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: const Color(0xFF26313A),
            width: 2,
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: "HelveticaNeue",
            color: Color(0xFF151B20),
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}