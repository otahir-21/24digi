import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../core/app_constants.dart';
import '../../../auth/auth_provider.dart';

/// A reusable shop-specific top header based on the latest design
/// (translucent background, gradient border, cyan back button).
class ShopTopBar extends StatelessWidget {
  /// Override the back-tap behaviour. Defaults to [Navigator.maybePop].
  final VoidCallback? onBack;

  /// Whether to hide the back arrow (e.g. on root-level screens).
  final bool showBack;

  const ShopTopBar({super.key, this.onBack, this.showBack = true});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;

    return Container(
      margin: EdgeInsets.fromLTRB(16 * s, 10 * s, 16 * s, 5 * s),
      height: 60 * s,
      child: Stack(
        children: [
          // ── Glassmorphism effect ─────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(30 * s),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(30 * s),
                  border: Border.all(
                    color: Colors.transparent, // Replaced by gradient border wrapper
                  ),
                ),
              ),
            ),
          ),
          // ── Gradient Border Wrapper ─────────────────────────────────
          _GradientBorder(
            borderRadius: BorderRadius.circular(30 * s),
            gradient: const LinearGradient(
              colors: [Color(0xFF00F0FF), Color(0xFFB161FF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            child: Container(
              height: 60 * s,
              padding: EdgeInsets.symmetric(horizontal: 16 * s),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ── Back button ──────────────────────────────────────────────
                  if (showBack)
                    GestureDetector(
                      onTap: onBack ?? () => Navigator.maybePop(context),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(4 * s),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: const Color(0xFF00F0FF),
                          size: 20 * s,
                        ),
                      ),
                    )
                  else
                    SizedBox(width: 28 * s), // placeholder

                  // ── Logo ─────────────────────────────────────────────────────
                  Image.asset(
                    'assets/images/digi_logo.png',
                    height: 48 * s,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/24 logo.png',
                      height: 32 * s,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // ── Profile avatar ───────────────────────────────────────────
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () => Scaffold.of(context).openEndDrawer(),
                      child: Container(
                      width: 38 * s,
                      height: 38 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00F0FF),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: profile?.profileImage != null &&
                                profile!.profileImage!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: profile.profileImage!,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                placeholder: (_, __) =>
                                    const CircularProgressIndicator(strokeWidth: 2),
                                errorWidget: (_, __, ___) => Image.asset(
                                  profile.gender?.toLowerCase() == 'female'
                                      ? 'assets/shop/female_avatar.png'
                                      : 'assets/shop/male_avatar.png',
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                ),
                              )
                            : Image.asset(
                                profile?.gender?.toLowerCase() == 'female'
                                    ? 'assets/shop/female_avatar.png'
                                    : 'assets/shop/male_avatar.png',
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                              ),
                      ),
                    ),
                  ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientBorder extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final BorderRadius borderRadius;
  final double strokeWidth;

  const _GradientBorder({
    required this.child,
    required this.gradient,
    required this.borderRadius,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GradientPainter(
        gradient: gradient,
        borderRadius: borderRadius,
        strokeWidth: strokeWidth,
      ),
      child: child,
    );
  }
}

class _GradientPainter extends CustomPainter {
  final Gradient gradient;
  final BorderRadius borderRadius;
  final double strokeWidth;

  _GradientPainter({
    required this.gradient,
    required this.borderRadius,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final RRect rrect = borderRadius.toRRect(rect);
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
