import 'package:flutter/material.dart';
import '../../core/app_constants.dart';
import '../../widgets/digi_background.dart';
import '../../painters/smooth_gradient_border.dart';

class BraceletScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;

  const BraceletScaffold({
    super.key,
    required this.child,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final s = mq.size.width / AppConstants.figmaW;
    final hPad = 16.0 * s;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: DigiBackground(
        logoOpacity: 0,
        showCircuit: false,
        child: SafeArea(
          child: Column(
            children: [
              // Custom Top Bar
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: hPad,
                  vertical: 10 * s,
                ),
                child: _TopBar(s: s),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final double s;
  const _TopBar({required this.s});

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
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      padding: EdgeInsets.all(8 * s),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.cyan,
                        size: 20 * s,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Image.asset(
                    'assets/24 logo.png', // Assuming this is the logo from screenshot
                    height: 35 * s,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),
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
