import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import '../../widgets/digi_background.dart';
import '../../painters/smooth_gradient_border.dart';

class BraceletScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final bool scrollable;
  /// When non-null, back button pops with this value so the previous route can use it (e.g. HRV from inner screen).
  final Object? popResult;

  const BraceletScaffold({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.scrollable = true,
    this.popResult,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final hPad = 16.0 * s;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: DigiBackground(
        logoOpacity: 0,
        showLanguageSlider: false,
        showCircuit: false,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.maxContentWidth,
              ),
              child: Column(
                children: [
                  // Custom Top Bar
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: hPad,
                      vertical: 10 * s,
                    ),
                    child: _TopBar(s: s, title: title, actions: actions, popResult: popResult),
                  ),
                  Expanded(
                    child: scrollable
                        ? SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: hPad),
                            child: child,
                          )
                        : Padding(
                            padding: EdgeInsets.symmetric(horizontal: hPad),
                            child: child,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final double s;
  final String? title;
  final List<Widget>? actions;
  final Object? popResult;

  const _TopBar({required this.s, this.title, this.actions, this.popResult});

  @override
  Widget build(BuildContext context) {
    final pillH = 60.0 * s;
    final radius = pillH / 2;

    return CustomPaint(
      painter: SmoothGradientBorder(radius: radius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: ColoredBox(
          color: const Color(0xFF060E16).withOpacity(0.8),
          child: SizedBox(
            height: pillH,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18 * s),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (popResult != null) {
                        Navigator.of(context).pop(popResult);
                      } else {
                        Navigator.maybePop(context);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(8 * s),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20 * s,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (title != null)
                    Text(
                      title!,
                      style: GoogleFonts.inter(
                        fontSize: 18 * s,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFC0C0C0),
                      ),
                    )
                  else
                    Image.asset(
                      'assets/24 logo.png',
                      height: 35 * s,
                      fit: BoxFit.contain,
                    ),
                  const Spacer(),
                  if (actions != null)
                    ...actions!
                  else
                    CustomPaint(
                      painter: SmoothGradientBorder(radius: 20 * s),
                      child: ClipOval(
                        child: SizedBox(
                          width: 40 * s,
                          height: 40 * s,
                          child: Image.asset(
                            'assets/fonts/male.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
