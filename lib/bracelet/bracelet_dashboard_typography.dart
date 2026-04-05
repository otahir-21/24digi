import 'package:flutter/material.dart';

/// Typography for the bracelet module using bundled **Helvetica Neue** from
/// `assets/fonts/bracletFonts/` (family name `HelveticaNeue` in [pubspec.yaml]).
abstract class BraceletDashboardTypography {
  BraceletDashboardTypography._();

  /// Bundled font family registered in pubspec (all platforms).
  static const String fontFamily = 'HelveticaNeue';

  static TextStyle text({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }
}
