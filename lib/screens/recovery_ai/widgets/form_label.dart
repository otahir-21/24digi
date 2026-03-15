import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class FormLabel extends StatelessWidget {
  final String label;
  const FormLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final s =UIScale.of(context);
    return Padding(
      padding:   EdgeInsets.only(bottom: 8.0 * s),
      child: Text(
        label,
        style:   TextStyle(
          fontFamily: "HelveticaNeue",
          fontSize: 18* s,
          fontWeight: FontWeight.w700,
          color: Color(0xffC084FC),
        ),
      ),
    );
  }
}
