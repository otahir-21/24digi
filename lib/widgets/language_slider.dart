import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/language_provider.dart';

class LanguageSlider extends StatelessWidget {
  const LanguageSlider({super.key});

  @override
  Widget build(BuildContext context) {
    // scale factor based on 394 Figma width
    final s = MediaQuery.of(context).size.width / 394.0;
    final langProvider = context.watch<LanguageProvider>();
    final isArabic = langProvider.isArabic;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'EN',
          style: GoogleFonts.inter(
            fontSize: 10 * s,
            fontWeight: isArabic ? FontWeight.w400 : FontWeight.w700,
            color: isArabic ? const Color(0xFF6B7680) : Colors.white,
          ),
        ),
        SizedBox(width: 8 * s),
        GestureDetector(
          onTap: () {
            langProvider.setLanguage(isArabic ? 'EN' : 'AR');
          },
          child: Container(
            width: 48 * s,
            height: 24 * s,
            decoration: BoxDecoration(
              color: const Color(0xFF334C5D).withValues(alpha: .5),
              borderRadius: BorderRadius.circular(20 * s),
              border: Border.all(
                color: Colors.white.withValues(alpha: .1),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  left: isArabic ? 24 * s : 2 * s,
                  top: 2 * s,
                  child: Container(
                    width: 20 * s,
                    height: 20 * s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: isArabic
                        ? Container(
                            color: const Color(
                              0xFF006C35,
                            ), // Saudi flag green-ish
                            child: const Center(
                              child: Text(
                                '🇸🇦',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                        : Container(
                            color: const Color(0xFF00247D), // UK flag blue
                            child: const Center(
                              child: Text(
                                '🇬🇧',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8 * s),
        Text(
          'AR',
          style: GoogleFonts.inter(
            fontSize: 10 * s,
            fontWeight: isArabic ? FontWeight.w700 : FontWeight.w400,
            color: isArabic ? Colors.white : const Color(0xFF6B7680),
          ),
        ),
      ],
    );
  }
}
