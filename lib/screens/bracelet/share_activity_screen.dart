import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import 'bracelet_scaffold.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShareActivityScreen
// ─────────────────────────────────────────────────────────────────────────────
class ShareActivityScreen extends StatefulWidget {
  const ShareActivityScreen({super.key});

  @override
  State<ShareActivityScreen> createState() => _ShareActivityScreenState();
}

class _ShareActivityScreenState extends State<ShareActivityScreen> {
  GoogleMapController? _mapController;

  static const _routePoints = [
    LatLng(51.5074, -0.1278),
    LatLng(51.5082, -0.1265),
    LatLng(51.5095, -0.1250),
    LatLng(51.5105, -0.1240),
    LatLng(51.5112, -0.1220),
    LatLng(51.5108, -0.1200),
    LatLng(51.5098, -0.1188),
    LatLng(51.5085, -0.1195),
    LatLng(51.5075, -0.1210),
    LatLng(51.5068, -0.1235),
    LatLng(51.5070, -0.1258),
    LatLng(51.5074, -0.1278),
  ];

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return BraceletScaffold(
      title: 'Share Activities',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── HI, USER ──────────────────────────────────────────
          Center(
            child: Text(
              'HI, USER',
              style: TextStyle(
                fontFamily: 'LemonMilk',
                fontSize: 11 * s,
                fontWeight: FontWeight.w300,
                color: AppColors.labelDim,
                letterSpacing: 2.0,
              ),
            ),
          ),
          SizedBox(height: 14 * s),

          // ── Activity snapshot card ────────────────────────────
          _BorderCard(
            s: s,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title row
                Padding(
                  padding: EdgeInsets.fromLTRB(16 * s, 14 * s, 16 * s, 10 * s),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hiking Trip',
                            style: GoogleFonts.inter(
                              fontSize: 16 * s,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Sat, Oct 12 • 09:40 AM',
                            style: GoogleFonts.inter(
                              fontSize: 10 * s,
                              color: AppColors.labelDim,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10 * s,
                          vertical: 4 * s,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withAlpha(40),
                          borderRadius: BorderRadius.circular(6 * s),
                        ),
                        child: Text(
                          'COMPLETED',
                          style: GoogleFonts.inter(
                            fontSize: 9 * s,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Map area
                SizedBox(
                  height: 220 * s,
                  child: ClipRRect(
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(51.509, -0.1235),
                        zoom: 14.5,
                      ),
                      polylines: {
                        Polyline(
                          polylineId: const PolylineId('route'),
                          points: _routePoints,
                          color: AppColors.cyan,
                          width: 4,
                        ),
                      },
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      myLocationButtonEnabled: false,
                      onMapCreated: (c) => _mapController = c,
                    ),
                  ),
                ),

                // Stats row
                Padding(
                  padding: EdgeInsets.all(16 * s),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatCell(
                        s: s,
                        icon: Icons.timer_outlined,
                        iconColor: const Color(0xFFCE6AFF),
                        label: 'DURATION',
                        value: '01:45:22',
                      ),
                      _StatCell(
                        s: s,
                        icon: Icons.directions_walk_rounded,
                        iconColor: AppColors.cyan,
                        label: 'DISTANCE',
                        value: '8.4 km',
                      ),
                      _StatCell(
                        s: s,
                        icon: Icons.local_fire_department_rounded,
                        iconColor: const Color(0xFFFFB300),
                        label: 'CALORIES',
                        value: '450 kcal',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24 * s),

          // ── Share with Friends header ─────────────────────────
          Text(
            'Share with friends',
            style: TextStyle(
              fontFamily: 'LemonMilk',
              fontSize: 13 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12 * s),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: List.generate(
                6,
                (i) => Padding(
                  padding: EdgeInsets.only(right: 14 * s),
                  child: _FriendAvatar(s: s, index: i),
                ),
              ),
            ),
          ),
          SizedBox(height: 28 * s),

          // ── Share on Social ───────────────────────────────────
          Text(
            'Share on social media',
            style: TextStyle(
              fontFamily: 'LemonMilk',
              fontSize: 13 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16 * s),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SharePlatform(
                s: 1.0,
                assetPath: 'assets/fb.png',
                label: 'Facebook',
              ),
              _SharePlatform(
                s: 1.0,
                assetPath: 'assets/insta.png',
                label: 'Instagram',
              ),
              _SharePlatform(
                s: 1.0,
                assetPath: 'assets/x.png',
                label: 'X (Twitter)',
              ),
              _SharePlatform(
                s: 1.0,
                assetPath: 'assets/wa.png',
                label: 'WhatsApp',
              ),
            ],
          ),
          SizedBox(height: 32 * s),

          // ── Action Buttons ────────────────────────────────────
          _PillButton(
            s: s,
            label: 'Copy Activity Link',
            leadingIcon: Icons.link_rounded,
            isPrimary: true,
            onTap: () {},
          ),
          SizedBox(height: 12 * s),
          _PillButton(
            s: s,
            label: 'Save to Gallery',
            leadingIcon: Icons.download_rounded,
            isPrimary: false,
            onTap: () {},
          ),
          SizedBox(height: 24 * s),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient-border card
// ─────────────────────────────────────────────────────────────────────────────
class _BorderCard extends StatelessWidget {
  final double s;
  final Widget child;
  const _BorderCard({required this.s, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SmoothGradientBorder(radius: 16 * s),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * s),
        child: ColoredBox(color: const Color(0xFF060E16), child: child),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat cell (icon + label + value)
// ─────────────────────────────────────────────────────────────────────────────
class _StatCell extends StatelessWidget {
  final double s;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  const _StatCell({
    required this.s,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 14 * s),
            SizedBox(width: 5 * s),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9 * s,
                color: AppColors.labelDim,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 3 * s),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16 * s,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Friend avatar circle
// ─────────────────────────────────────────────────────────────────────────────
class _FriendAvatar extends StatelessWidget {
  final double s;
  final int index;
  const _FriendAvatar({required this.s, required this.index});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 54 * s,
          height: 54 * s,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF8E99A6),
          ),
          child: Icon(
            Icons.person,
            color: Colors.white.withAlpha(240),
            size: 32 * s,
          ),
        ),
        SizedBox(height: 5 * s),
        Text(
          'Name #${index + 1}',
          style: GoogleFonts.inter(fontSize: 10 * s, color: AppColors.labelDim),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Social platform icon button
// ─────────────────────────────────────────────────────────────────────────────
class _SharePlatform extends StatelessWidget {
  final double s;
  final String assetPath;
  final String label;
  const _SharePlatform({
    required this.s,
    required this.assetPath,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final scale = s != 1.0 ? s : AppConstants.scale(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 58 * scale,
            height: 58 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0F1923),
              border: Border.all(
                color: const Color(0xFF2D1625),
                width: 1.2 * scale,
              ),
            ),
            child: ClipOval(
              child: Padding(
                padding: EdgeInsets.all(14 * scale),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.share_rounded,
                    color: const Color(0xFFE8344A),
                    size: 26 * scale,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 6 * scale),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10 * scale,
            color: AppColors.labelDim,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pill buttons (Copy / Save)
// ─────────────────────────────────────────────────────────────────────────────
class _PillButton extends StatelessWidget {
  final double s;
  final String label;
  final IconData? leadingIcon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _PillButton({
    required this.s,
    required this.label,
    required this.onTap,
    required this.isPrimary,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: 30 * s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30 * s),
          child: Container(
            height: 54 * s,
            decoration: BoxDecoration(
              color: isPrimary
                  ? AppColors.cyan.withAlpha(30)
                  : const Color(0xFF060E16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon, color: AppColors.labelDim, size: 20 * s),
                  SizedBox(width: 10 * s),
                ],
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
