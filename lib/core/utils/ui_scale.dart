import 'package:flutter/material.dart';

class UIScale {
  UIScale._();

  static const double figmaWidth = 440;
  static const double maxWidth = 600;

  static double of(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final effectiveWidth = width > maxWidth ? maxWidth : width;
    return effectiveWidth / figmaWidth;
  }
}