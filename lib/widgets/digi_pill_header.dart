import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../core/app_constants.dart';
import '../auth/auth_provider.dart';
import '../screens/profile/profile_screen.dart';

/// A reusable pill-shaped top header used consistently across all screens
/// (after the home screen).
///
/// Shows:
///  - A back-arrow on the left (calls [Navigator.maybePop] by default,
///    or [onBack] if provided).
///  - The 24-DIGI logo in the centre.
///  - The user's profile avatar on the right (taps to go to ProfileScreen).
///
/// Layout matches the pill header on the home screen but uses a subtle
/// cyan-to-purple gradient border (same as ProfileTopBar) for distinction.
class DigiPillHeader extends StatelessWidget {
  /// Override the back-tap behaviour. Defaults to [Navigator.maybePop].
  final VoidCallback? onBack;

  /// Whether to hide the back arrow (e.g. on root-level screens).
  final bool showBack;

  const DigiPillHeader({super.key, this.onBack, this.showBack = true});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 10 * s),
      // Gradient border wrapper
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(31 * s),
        gradient: const LinearGradient(
          colors: [Color(0xFF00F0FF), Color(0xFFB161FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        height: 60 * s,
        decoration: BoxDecoration(
          color: const Color(0xFF0D1519),
          borderRadius: BorderRadius.circular(30 * s),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F0FF).withOpacity(0.08),
              blurRadius: 15 * s,
              spreadRadius: -2 * s,
            ),
          ],
        ),
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
              SizedBox(width: 28 * s), // placeholder to keep logo centred
            // ── Logo ─────────────────────────────────────────────────────
            Image.asset(
              'assets/fonts/male.png',
              height: 44 * s,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/24 logo.png',
                height: 28 * s,
                fit: BoxFit.contain,
              ),
            ),

            // ── Profile avatar ───────────────────────────────────────────
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
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
                  child:
                      profile?.profileImage != null &&
                          profile!.profileImage!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: profile.profileImage!,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          placeholder: (_, __) =>
                              const CircularProgressIndicator(strokeWidth: 2),
                          errorWidget: (_, __, ___) => Image.asset(
                            profile.gender?.toLowerCase() == 'female'
                                ? 'assets/fonts/female.png'
                                : 'assets/fonts/male.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        )
                      : Image.asset(
                          profile?.gender?.toLowerCase() == 'female'
                              ? 'assets/fonts/female.png'
                              : 'assets/fonts/male.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
