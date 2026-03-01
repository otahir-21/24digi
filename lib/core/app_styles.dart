import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {
  // ── Inter Regular ──────────────────────────────────────────────────────────
  static TextStyle reg8(double s) => GoogleFonts.inter(
    fontSize: 8 * s,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );
  static TextStyle reg10(double s) => GoogleFonts.inter(
    fontSize: 10 * s,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );
  static TextStyle reg12(double s) => GoogleFonts.inter(
    fontSize: 12 * s,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );
  static TextStyle reg14(double s) => GoogleFonts.inter(
    fontSize: 14 * s,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  // ── Inter Medium/SemiBold ─────────────────────────────────────────────────
  static TextStyle semi10(double s) => GoogleFonts.inter(
    fontSize: 10 * s,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static TextStyle semi12(double s) => GoogleFonts.inter(
    fontSize: 12 * s,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static TextStyle semi14(double s) => GoogleFonts.inter(
    fontSize: 14 * s,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // ── Inter Bold ─────────────────────────────────────────────────────────────
  static TextStyle bold10(double s) => GoogleFonts.inter(
    fontSize: 10 * s,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  static TextStyle bold12(double s) => GoogleFonts.inter(
    fontSize: 12 * s,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  static TextStyle bold14(double s) => GoogleFonts.inter(
    fontSize: 14 * s,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  static TextStyle bold16(double s) => GoogleFonts.inter(
    fontSize: 16 * s,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  static TextStyle bold18(double s) => GoogleFonts.inter(
    fontSize: 18 * s,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  static TextStyle bold20(double s) => GoogleFonts.inter(
    fontSize: 20 * s,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  static TextStyle bold22(double s) => GoogleFonts.inter(
    fontSize: 22 * s,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  // ── LemonMilk ──────────────────────────────────────────────────────────────
  static TextStyle lemon10(double s) => TextStyle(
    fontFamily: 'LemonMilk',
    fontSize: 10 * s,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  static TextStyle lemon12(double s) => TextStyle(
    fontFamily: 'LemonMilk',
    fontSize: 12 * s,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  static TextStyle lemon14(double s) => TextStyle(
    fontFamily: 'LemonMilk',
    fontSize: 14 * s,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  static TextStyle lemon16(double s) => TextStyle(
    fontFamily: 'LemonMilk',
    fontSize: 16 * s,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}
