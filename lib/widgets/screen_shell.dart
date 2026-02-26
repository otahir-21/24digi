import 'package:flutter/material.dart';
import '../core/app_constants.dart';
import 'digi_background.dart';
import 'glass_card.dart';

/// Provides the shared screen scaffold used by every screen in the app:
///
///   Scaffold → DigiBackground → centered GlassCard → [optional scroll] → content
///
/// **Usage — scrollable setup screen:**
/// ```dart
/// return ScreenShell(
///   builder: (s) => Column(children: [...]),
/// );
/// ```
///
/// **Usage — non-scrollable screen (Stack-based card content):**
/// ```dart
/// return ScreenShell(
///   scrollable: false,
///   builder: (s) => Stack(children: [...]),
/// );
/// ```
///
/// The [builder] callback receives the computed scale factor `s`
/// (`screenWidth / 394`). Use it exactly as before: `16 * s`, `40 * s`, etc.
class ScreenShell extends StatelessWidget {
  /// Builds the card's inner content. Receives the scale factor [s].
  final Widget Function(double s) builder;

  /// When true the card content is wrapped in a
  /// [SingleChildScrollView] with [contentPadding].
  /// Defaults to false — enable only for screens whose content can overflow.
  final bool scrollable;

  /// Override the default content padding
  /// (`horizontal: 22*s, vertical: 12*s`).
  /// Only used when [scrollable] is true.
  final EdgeInsets Function(double s)? contentPadding;

  /// Passed directly to [Scaffold.resizeToAvoidBottomInset].
  final bool resizeToAvoidBottomInset;

  const ScreenShell({
    super.key,
    required this.builder,
    this.scrollable = false,
    this.contentPadding,
    this.resizeToAvoidBottomInset = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / AppConstants.figmaW;

    // ── Card inner content ──────────────────────────────────────────────────
    final EdgeInsets padding = contentPadding?.call(s) ??
        EdgeInsets.symmetric(
          horizontal: AppConstants.cardPaddingH * s,
          vertical: AppConstants.cardPaddingV * s,
        );

    final Widget cardContent = scrollable
        ? SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: padding,
            child: builder(s),
          )
        : Padding(
            padding: padding,
            child: builder(s),
          );

    return Scaffold(
      backgroundColor: AppColors.black,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: DigiBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Use actual body height (excludes status bar & bottom nav bar)
            // so the card is truly vertically centred in the visible area.
            final bodyHeight = constraints.maxHeight;
            final cardHeight = bodyHeight * AppConstants.cardHeightRatio;
            final cardTop = (bodyHeight - cardHeight) / 2;

            return Stack(
              children: [
                Positioned(
                  top: cardTop,
                  left: AppConstants.cardLeft * s,
                  child: GlassCard(
                    width: AppConstants.cardWidth * s,
                    height: cardHeight,
                    radius: AppConstants.cardRadius * s,
                    borderWidth: AppConstants.cardBorderWidth * s,
                    blurSigma: AppConstants.cardBlurSigma,
                    child: cardContent,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
