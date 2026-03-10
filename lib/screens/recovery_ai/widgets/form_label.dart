import 'package:flutter/material.dart';

class FormLabel extends StatelessWidget {
  final String label;
  const FormLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: "HelveticaNeue",
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xffC084FC),
        ),
      ),
    );
  }
}
