import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import 'bracelet_scaffold.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShareActivityScreen – shows real activity data when passed from activity detail
// ─────────────────────────────────────────────────────────────────────────────
class ShareActivityScreen extends StatefulWidget {
  const ShareActivityScreen({
    super.key,
    this.activityLabel,
    this.durationMinutes,
    this.distanceKm,
    this.calories,
    this.routePoints,
    this.dateTime,
  });

  final String? activityLabel;
  final int? durationMinutes;
  final double? distanceKm;
  final double? calories;
  final List<LatLng>? routePoints;
  final DateTime? dateTime;

  @override
  State<ShareActivityScreen> createState() => _ShareActivityScreenState();
}

class _ShareActivityScreenState extends State<ShareActivityScreen> {
  GoogleMapController? _mapController;
  final GlobalKey _activityCardKey = GlobalKey();

  List<LatLng> get _routePoints =>
      widget.routePoints != null && widget.routePoints!.isNotEmpty
          ? List<LatLng>.from(widget.routePoints!)
          : <LatLng>[];

  String get _activityTitle =>
      widget.activityLabel?.isNotEmpty == true
          ? widget.activityLabel!
          : 'Activity';

  String get _dateTimeStr {
    final d = widget.dateTime ?? DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final day = days[d.weekday - 1];
    final h = d.hour;
    final m = d.minute;
    final am = h < 12;
    final hour = h <= 12 ? (h == 0 ? 12 : h) : h - 12;
    return '$day, ${d.month}/${d.day} • ${hour.toString().padLeft(2)}:${m.toString().padLeft(2, '0')} ${am ? 'AM' : 'PM'}';
  }

  String get _durationStr {
    final m = widget.durationMinutes;
    if (m == null || m < 0) return '—';
    final h = m ~/ 60;
    final min = m % 60;
    if (h > 0) return '${h.toString().padLeft(2)}:${min.toString().padLeft(2, '0')}:00';
    return '00:${min.toString().padLeft(2, '0')}:00';
  }

  String get _distanceStr {
    final km = widget.distanceKm;
    if (km == null || km < 0) return '—';
    if (km >= 1) return '${km.toStringAsFixed(1)} km';
    return '${(km * 1000).round()} m';
  }

  String get _caloriesStr {
    final c = widget.calories;
    if (c == null || c < 0) return '—';
    return '${c.round()} kcal';
  }

  /// Build shareable text (and optional app link) for "Copy Activity Link".
  String get _shareableLinkText {
    final parts = <String>[
      'Just completed $_activityTitle on 24Digi!',
      if (widget.durationMinutes != null && widget.durationMinutes! > 0)
        'Duration: $_durationStr',
      if (widget.distanceKm != null && widget.distanceKm! >= 0)
        'Distance: $_distanceStr',
      if (widget.calories != null && widget.calories! >= 0)
        'Calories: $_caloriesStr',
    ];
    final line = parts.join(' • ');
    return '$line\n\nTrack your health with 24Digi.';
  }

  Future<void> _copyActivityLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _shareableLinkText));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Activity link copied to clipboard'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveToGallery(BuildContext context) async {
    try {
      final boundary = _activityCardKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not capture image'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not create image'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      final pngBytes = byteData.buffer.asUint8List();
      final result = await ImageGallerySaver.saveImage(pngBytes);
      if (context.mounted) {
        final success = result['isSuccess'] == true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Activity saved to gallery'
                  : 'Could not save to gallery. Check photo permission.',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _fitMapToRoute() {
    if (_routePoints.isEmpty || _mapController == null) return;
    double minLat = _routePoints.first.latitude;
    double maxLat = minLat;
    double minLng = _routePoints.first.longitude;
    double maxLng = minLng;
    for (final p in _routePoints) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 40));
  }

  Widget _buildMapPlaceholder(double s) {
    return Container(
      color: const Color(0xFF0F1923),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.route_rounded, size: 48 * s, color: AppColors.cyan.withAlpha(150)),
            SizedBox(height: 8 * s),
            Text(
              'No route recorded',
              style: GoogleFonts.inter(fontSize: 12 * s, color: AppColors.labelDim),
            ),
          ],
        ),
      ),
    );
  }

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
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              final name = auth.profile?.name?.trim();
              final greeting = (name != null && name.isNotEmpty)
                  ? 'HI, ${name.toUpperCase()}'
                  : 'HI';
              return Center(
                child: Text(
                  greeting,
                  style: TextStyle(
                    fontFamily: 'LemonMilk',
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w300,
                    color: AppColors.labelDim,
                    letterSpacing: 2.0,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 14 * s),

          // ── Activity snapshot card (wrapped for gallery capture) ─
          RepaintBoundary(
            key: _activityCardKey,
            child: _BorderCard(
              s: s,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title row (real activity name + date/time)
                Padding(
                  padding: EdgeInsets.fromLTRB(16 * s, 14 * s, 16 * s, 10 * s),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _activityTitle,
                            style: GoogleFonts.inter(
                              fontSize: 16 * s,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _dateTimeStr,
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

                // Map area (real route when routePoints provided, else placeholder)
                SizedBox(
                  height: 220 * s,
                  child: ClipRRect(
                    child: _routePoints.isEmpty
                        ? _buildMapPlaceholder(s)
                        : GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _routePoints.first,
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
                            onMapCreated: (c) {
                              _mapController = c;
                              if (_routePoints.length >= 2) {
                                _fitMapToRoute();
                              }
                            },
                          ),
                  ),
                ),

                // Stats row (real duration, distance, calories)
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
                        value: _durationStr,
                      ),
                      _StatCell(
                        s: s,
                        icon: Icons.directions_walk_rounded,
                        iconColor: AppColors.cyan,
                        label: 'DISTANCE',
                        value: _distanceStr,
                      ),
                      _StatCell(
                        s: s,
                        icon: Icons.local_fire_department_rounded,
                        iconColor: const Color(0xFFFFB300),
                        label: 'CALORIES',
                        value: _caloriesStr,
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
            onTap: () => _copyActivityLink(context),
          ),
          SizedBox(height: 12 * s),
          _PillButton(
            s: s,
            label: 'Save to Gallery',
            leadingIcon: Icons.download_rounded,
            isPrimary: false,
            onTap: () => _saveToGallery(context),
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
