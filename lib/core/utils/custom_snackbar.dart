import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_constants.dart';

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    bool isAdventure = false,
  }) {
    final s = AppConstants.scale(context);
    final themeColor = isAdventure ? const Color(0xFFE0A10A) : const Color(0xFF00FF88);
    final bgColor = const Color(0xFF13181D);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(
              color: isError ? Colors.redAccent.withValues(alpha: 0.5) : themeColor.withValues(alpha: 0.5),
              width: 1.5 * s,
            ),
            boxShadow: [
              BoxShadow(
                color: (isError ? Colors.redAccent : themeColor).withValues(alpha: 0.1),
                blurRadius: 10 * s,
                spreadRadius: 2 * s,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: isError ? Colors.redAccent : themeColor,
                size: 20 * s,
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
