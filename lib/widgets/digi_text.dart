import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DigiText {
  // "Welcome to": Helvetica Neue (Inter), weight 200, 32px, letterSpacing 1, centered
  static Text welcomeTo(double sizeScale) => Text(
    'Welcome to',
    textAlign: TextAlign.center,
    style: GoogleFonts.inter(
      fontSize: 32 * sizeScale,
      fontWeight: FontWeight.w200,
      height: 1.0,
      letterSpacing: 0.5 * sizeScale,
      color: const Color(0xFFFFFFFF),
    ),
  );

  // Subtitle: rgba(168, 179, 186, 1) — exact Figma value
  static Text subtitle(double sizeScale) => Text(
    'The first complete ecosystem for\nhealth, fitness, and lifestyle.',
    textAlign: TextAlign.center,
    style: GoogleFonts.inter(
      fontSize: 14 * sizeScale,
      fontWeight: FontWeight.w400,
      height: 1.3,
      letterSpacing: 0.2 * sizeScale,
      color: const Color(0xFFA8B3BA),
    ),
  );

  // "GET STARTED": Lemon/Milk, weight 700, 24px, letterSpacing 1, white
  static Text getStarted(double sizeScale) => Text(
    'GET STARTED',
    textAlign: TextAlign.center,
    style: TextStyle(
      fontFamily: 'LemonMilk',
      fontSize: 22 * sizeScale,
      fontWeight: FontWeight.w700,
      height: 1.0,
      letterSpacing: 1.2 * sizeScale,
      color: const Color(0xFFFFFFFF),
    ),
  );
}
