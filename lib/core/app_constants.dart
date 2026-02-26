import 'package:flutter/material.dart';

// ── Scale factor ──────────────────────────────────────────────────────────────
// All Figma values were designed at 394 px wide.
// Multiply any Figma measurement by `s` to get the correct size at runtime.
// Usage: MediaQuery.of(context).size.width / AppConstants.figmaW
// ─────────────────────────────────────────────────────────────────────────────
abstract class AppConstants {
  /// Figma design canvas width (px)
  static const double figmaW = 394.0;

  /// Card height as a fraction of screen height
  static const double cardHeightRatio = 0.85;

  /// Horizontal distance from screen edge to card left edge (Figma units)
  static const double cardLeft = 17.0;

  /// Card width in Figma units
  static const double cardWidth = 360.0;

  /// Card corner radius in Figma units
  static const double cardRadius = 40.0;

  /// Card border stroke width in Figma units
  static const double cardBorderWidth = 2.0;

  /// Card backdrop blur sigma
  static const double cardBlurSigma = 80.0;

  /// Default horizontal padding inside card (Figma units)
  static const double cardPaddingH = 22.0;

  /// Default vertical padding inside card (Figma units)
  static const double cardPaddingV = 22.0;
}

// ── App-wide colours ──────────────────────────────────────────────────────────
abstract class AppColors {
  static const Color black = Color(0xFF000000);
  static const Color cyan = Color(0xFF00F0FF);
  static const Color purple = Color(0xFFCE6AFF);

  static const Color trackInactive = Color(0xFF2C3E4A);
  static const Color divider = Color(0xFF1E2E3A);
  static const Color tileDark = Color.fromRGBO(10, 18, 26, 0.85);

  static const Color labelDim = Color(0xFF7A8A94);
  static const Color labelDimmer = Color(0xFF5A6A74);
  static const Color textLight = Color(0xFFB0BEC5);
  static const Color textMid = Color(0xFFD0DCE4);

  static const Color cyanGlow44 = Color(0x4400F0FF);
  static const Color cyanGlow33 = Color(0x3300F0FF);
  static const Color cyanGlow22 = Color(0x2200F0FF);
  static const Color cyanTint8 = Color.fromRGBO(0, 240, 255, 0.08);
  static const Color cyanTint6 = Color.fromRGBO(0, 240, 255, 0.06);
  static const Color cyanTint10 = Color.fromRGBO(0, 240, 255, 0.10);
  static const Color cyanTint18 = Color.fromRGBO(0, 240, 255, 0.18);

  static const Color surfaceCard = Color.fromRGBO(255, 255, 255, 0.04);
  static const Color surfaceBorder = Color.fromRGBO(255, 255, 255, 0.08);
}

// ── Shared gradient definitions ───────────────────────────────────────────────
abstract class AppGradients {
  /// The 7-stop cyan→purple smooth fade used on all tile/card borders
  static const List<Color> smoothBorderColors = [
    Color(0xFF00F0FF),
    Color(0x8800F0FF),
    Color(0x00000000),
    Color(0x00000000),
    Color(0x88CE6AFF),
    Color(0xFFCE6AFF),
    Color(0x00CE6AFF),
  ];
  static const List<double> smoothBorderStops = [
    0.0, 0.18, 0.38, 0.55, 0.72, 0.88, 1.0
  ];

  /// Cyan → Purple linear gradient (used on button text, etc.)
  static const LinearGradient cyanPurple = LinearGradient(
    colors: [AppColors.cyan, AppColors.purple],
  );
}
