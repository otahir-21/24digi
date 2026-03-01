import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../widgets/digi_background.dart';

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

  static final _midLatLng = LatLng(
    (_routePoints.first.latitude + _routePoints.last.latitude) / 2 + 0.002,
    (_routePoints.first.longitude + _routePoints.last.longitude) / 2,
  );

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 14 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top bar ───────────────────────────────────────────
                _TopBar(s: s, title: 'Share Activites'),
                SizedBox(height: 8 * s),

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
                        padding: EdgeInsets.fromLTRB(
                            16 * s, 14 * s, 16 * s, 10 * s),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Share Activity',
                              style: TextStyle(
                                fontFamily: 'LemonMilk',
                                fontSize: 14 * s,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'today, 8:30 AM',
                              style: GoogleFonts.inter(
                                fontSize: 10 * s,
                                color: AppColors.labelDim,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Map snapshot
                      ClipRRect(
                        child: SizedBox(
                          height: 180 * s,
                          child: GoogleMap(
                            onMapCreated: (c) => _mapController = c,
                            initialCameraPosition: CameraPosition(
                              target: _midLatLng,
                              zoom: 14.5,
                            ),
                            mapType: MapType.normal,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            polylines: {
                              Polyline(
                                polylineId: const PolylineId('route'),
                                points: _routePoints,
                                color: const Color(0xFF00C8FF),
                                width: 4,
                              ),
                            },
                            markers: {
                              Marker(
                                markerId: const MarkerId('start'),
                                position: _routePoints.first,
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueGreen),
                              ),
                              Marker(
                                markerId: const MarkerId('end'),
                                position: _routePoints.last,
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueRed),
                              ),
                            },
                          ),
                        ),
                      ),

                      // Stats rows
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            16 * s, 12 * s, 16 * s, 14 * s),
                        child: Column(
                          children: [
                            // Row 1
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _StatCell(
                                  s: s,
                                  icon: Icons.timer_outlined,
                                  iconColor: const Color(0xFF00C8FF),
                                  label: 'Duration',
                                  value: '00:00',
                                ),
                                _StatCell(
                                  s: s,
                                  icon: Icons.route_rounded,
                                  iconColor: const Color(0xFFCE6AFF),
                                  label: 'Distance',
                                  value: '-1',
                                ),
                                _StatCell(
                                  s: s,
                                  icon: Icons.speed_rounded,
                                  iconColor: const Color(0xFF00FF9C),
                                  label: 'Avg Pace',
                                  value: '-1',
                                ),
                              ],
                            ),
                            SizedBox(height: 12 * s),
                            // Row 2
                            Row(
                              children: [
                                _StatCell(
                                  s: s,
                                  icon: Icons.local_fire_department_rounded,
                                  iconColor: const Color(0xFFFF6B35),
                                  label: 'Calories',
                                  value: '-1',
                                ),
                                SizedBox(width: 48 * s),
                                _StatCell(
                                  s: s,
                                  icon: Icons.favorite_rounded,
                                  iconColor: const Color(0xFFFF3D6B),
                                  label: 'Avg Heart Rate',
                                  value: '-1',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20 * s),

                // ── Send to Friends ───────────────────────────────────
                Text(
                  'Send to Friends',
                  style: GoogleFonts.inter(
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12 * s),
                SizedBox(
                  height: 80 * s,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: 5,
                    separatorBuilder: (_, __) => SizedBox(width: 14 * s),
                    itemBuilder: (context, i) => _FriendAvatar(s: s, index: i),
                  ),
                ),
                SizedBox(height: 22 * s),

                // ── Share Via ─────────────────────────────────────────
                Text(
                  'Share Via',
                  style: GoogleFonts.inter(
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 14 * s),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SharePlatform(
                      s: s,
                      assetPath: 'assets/fonts/insta.png',
                      label: 'Stories',
                    ),
                    _SharePlatform(
                      s: s,
                      assetPath: 'assets/fonts/facebook.png',
                      label: 'Facebook',
                    ),
                    _SharePlatform(
                      s: s,
                      assetPath: 'assets/fonts/whatsapp (1).png',
                      label: 'WhatsApp',
                    ),
                    _SharePlatform(
                      s: s,
                      assetPath: 'assets/fonts/share (1).png',
                      label: 'More',
                    ),
                  ],
                ),
                SizedBox(height: 28 * s),

                // ── Copy Link button ──────────────────────────────────
                _OutlineButton(
                  s: s,
                  label: 'Copy Link',
                  trailingIcon: Icons.content_copy_rounded,
                  onTap: () {},
                ),
                SizedBox(height: 12 * s),

                // ── Save to Gallery button ────────────────────────────
                _OutlineButton(
                  s: s,
                  label: 'Save to Gallery',
                  leadingIcon: Icons.download_rounded,
                  onTap: () {},
                ),
                SizedBox(height: 24 * s),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar with screen title in the top-left area above the pill nav
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final double s;
  final String title;
  const _TopBar({required this.s, required this.title});

  @override
  Widget build(BuildContext context) {
    final h = 60.0 * s;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Screen label above the bar
        Padding(
          padding: EdgeInsets.only(left: 2 * s, bottom: 6 * s),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11 * s,
              color: AppColors.labelDim,
            ),
          ),
        ),
        // Pill nav bar
        CustomPaint(
          painter: SmoothGradientBorder(radius: h / 2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(h / 2),
            child: ColoredBox(
              color: const Color(0xFF060E16),
              child: SizedBox(
                height: h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18 * s),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.maybePop(context),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppColors.cyan, size: 20 * s),
                      ),
                      const Spacer(),
                      Image.asset('assets/24 logo.png',
                          height: 40 * s, fit: BoxFit.contain),
                      const Spacer(),
                      CustomPaint(
                        painter: SmoothGradientBorder(radius: 22 * s),
                        child: ClipOval(
                          child: SizedBox(
                            width: 42 * s,
                            height: 42 * s,
                            child: Image.asset(
                              'assets/fonts/male.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFF1E2A3A),
                                child: Icon(Icons.person,
                                    color: AppColors.labelDim,
                                    size: 24 * s),
                              ),
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
        ),
      ],
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
        child: ColoredBox(
          color: const Color(0xFF060E16),
          child: child,
        ),
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
            Icon(icon, color: iconColor, size: 13 * s),
            SizedBox(width: 4 * s),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 9 * s, color: AppColors.labelDim)),
          ],
        ),
        SizedBox(height: 3 * s),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 16 * s,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
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
          width: 52 * s,
          height: 52 * s,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF1E2A3A),
          ),
          child: Icon(Icons.person, color: const Color(0xFF4A5568), size: 28 * s),
        ),
        SizedBox(height: 5 * s),
        Text(
          'Name #${index + 1}',
          style: GoogleFonts.inter(
            fontSize: 9 * s,
            color: AppColors.labelDim,
          ),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 58 * s,
            height: 58 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0F1923),
              border: Border.all(
                color: const Color(0xFF2A1520),
                width: 1.5 * s,
              ),
            ),
            child: ClipOval(
              child: Padding(
                padding: EdgeInsets.all(14 * s),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.share_rounded,
                    color: const Color(0xFFE8344A),
                    size: 26 * s,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 6 * s),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10 * s,
            color: AppColors.labelDim,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient-border outlined button
// ─────────────────────────────────────────────────────────────────────────────
class _OutlineButton extends StatelessWidget {
  final double s;
  final String label;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback onTap;
  const _OutlineButton({
    required this.s,
    required this.label,
    required this.onTap,
    this.leadingIcon,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: 30 * s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30 * s),
          child: ColoredBox(
            color: const Color(0xFF060E16),
            child: SizedBox(
              height: 52 * s,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leadingIcon != null) ...[
                    Icon(leadingIcon, color: AppColors.cyan, size: 18 * s),
                    SizedBox(width: 10 * s),
                  ],
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14 * s,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    SizedBox(width: 10 * s),
                    Icon(trailingIcon, color: AppColors.cyan, size: 18 * s),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
