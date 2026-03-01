import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../widgets/digi_background.dart';
import 'share_activity_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ActivitiesInfoScreen
// ─────────────────────────────────────────────────────────────────────────────
class ActivitiesInfoScreen extends StatefulWidget {
  const ActivitiesInfoScreen({super.key});

  @override
  State<ActivitiesInfoScreen> createState() => _ActivitiesInfoScreenState();
}

class _ActivitiesInfoScreenState extends State<ActivitiesInfoScreen> {
  GoogleMapController? _mapController;

  // New mock route data based on common running patterns
  static final List<LatLng> _routePoints = [
    const LatLng(25.1972, 55.2744),
    const LatLng(25.1985, 55.2760),
    const LatLng(25.2005, 55.2785),
    const LatLng(25.2020, 55.2810),
    const LatLng(25.2045, 55.2835),
    const LatLng(25.2060, 55.2820),
    const LatLng(25.2080, 55.2795),
    const LatLng(25.2095, 55.2765),
    const LatLng(25.2105, 55.2735),
    const LatLng(25.2085, 55.2715),
    const LatLng(25.2065, 55.2695),
    const LatLng(25.2045, 55.2685),
    const LatLng(25.2025, 55.2695),
    const LatLng(25.2010, 55.2715),
    const LatLng(25.1972, 55.2744),
  ];

  static final _startLatLng = _routePoints.first;
  static final _midLatLng = LatLng(
    (_routePoints.first.latitude + _routePoints.last.latitude) / 2 + 0.002,
    (_routePoints.first.longitude + _routePoints.last.longitude) / 2,
  );

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
                // ── Top bar ──────────────────────────────────────────
                _TopBar(s: s),
                SizedBox(height: 6 * s),

                // ── HI, USER ─────────────────────────────────────────
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

                // ── Map + Stats Overlay ──────────────────────────────
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Map Container
                    _BorderCard(
                      s: s,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30 * s),
                        child: SizedBox(
                          height: 480 * s,
                          child: GoogleMap(
                            onMapCreated: (c) => _mapController = c,
                            initialCameraPosition: CameraPosition(
                              target: _midLatLng,
                              zoom: 14.2,
                            ),
                            mapType: MapType.normal,
                            myLocationEnabled: false,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            compassEnabled: false,
                            polylines: {
                              Polyline(
                                polylineId: const PolylineId('route'),
                                points: _routePoints,
                                color: const Color(0xFF1E6FBD),
                                width: 5,
                                jointType: JointType.round,
                              ),
                            },
                            markers: {
                              Marker(
                                markerId: const MarkerId('start'),
                                position: _startLatLng,
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueAzure,
                                ),
                              ),
                              Marker(
                                markerId: const MarkerId('end'),
                                position:
                                    _routePoints[_routePoints.length ~/ 2],
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueRed,
                                ),
                              ),
                            },
                          ),
                        ),
                      ),
                    ),
                    // Expand Icon overlay
                    Positioned(
                      top: 260 * s,
                      right: 20 * s,
                      child: Container(
                        width: 54 * s,
                        height: 52 * s,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(240),
                          borderRadius: BorderRadius.circular(10 * s),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(50),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Transform.rotate(
                            angle: math.pi / 4,
                            child: Icon(
                              Icons.unfold_more_rounded,
                              color: const Color(0xFFEF5350),
                              size: 26 * s,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Statistics Overlay Card
                    Positioned(
                      bottom: -2 * s,
                      left: 0,
                      right: 0,
                      child: _StatsOverlayCard(s: s),
                    ),
                  ],
                ),
                SizedBox(height: 20 * s),

                // ── Performance Over Time ─────────────────────────────
                _BorderCard(
                  s: s,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      14 * s,
                      14 * s,
                      14 * s,
                      10 * s,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance Over Time',
                          style: GoogleFonts.inter(
                            fontSize: 13 * s,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12 * s),
                        SizedBox(
                          height: 130 * s,
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: _PerformancePainter(s: s),
                          ),
                        ),
                        SizedBox(height: 12 * s),
                        // Days X-Axis
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children:
                              ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                                  .map(
                                    (day) => Text(
                                      day,
                                      style: GoogleFonts.inter(
                                        fontSize: 8 * s,
                                        color: AppColors.labelDim,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 14 * s),

                // ── Heart Rate Zones ──────────────────────────────────
                _BorderCard(
                  s: s,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      14 * s,
                      14 * s,
                      14 * s,
                      10 * s,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Heart Rate Zones',
                          style: GoogleFonts.inter(
                            fontSize: 13 * s,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12 * s),
                        SizedBox(
                          height: 130 * s,
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: _HrZonePainter(s: s),
                          ),
                        ),
                        SizedBox(height: 8 * s),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _ZoneLabel(
                              s: s,
                              label: 'Light',
                              color: const Color(0xFF4CAF50),
                            ),
                            _ZoneLabel(
                              s: s,
                              label: 'Moderate',
                              color: const Color(0xFFFFD600),
                            ),
                            _ZoneLabel(
                              s: s,
                              label: 'Hard',
                              color: const Color(0xFFFF9800),
                            ),
                            _ZoneLabel(
                              s: s,
                              label: 'Maximum',
                              color: const Color(0xFFEF5350),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 14 * s),

                // ── Weekly Distance Goal ──────────────────────────────
                _BorderCard(
                  s: s,
                  child: Padding(
                    padding: EdgeInsets.all(16 * s),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'weekly Distance Goal: 50 KM',
                              style: GoogleFonts.inter(
                                fontSize: 11 * s,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '65%',
                              style: GoogleFonts.inter(
                                fontSize: 11 * s,
                                fontWeight: FontWeight.w700,
                                color: AppColors.cyan,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8 * s),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6 * s),
                          child: Container(
                            height: 8 * s,
                            color: Colors.white.withAlpha(20),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 0.65,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6 * s),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF43C6E4),
                                      Color(0xFF9F56F5),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.cyan.withAlpha(80),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12 * s),
                        Text(
                          '32.5 km / 50 km (65%)',
                          style: GoogleFonts.inter(
                            fontSize: 10 * s,
                            color: AppColors.labelDim,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 14 * s),

                // ── AI Insight ────────────────────────────────────────
                _BorderCard(
                  s: s,
                  child: Padding(
                    padding: EdgeInsets.all(18 * s),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.cyan,
                          size: 24 * s,
                        ),
                        SizedBox(width: 12 * s),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI INSIGHT',
                                style: TextStyle(
                                  fontFamily: 'LemonMilk',
                                  fontSize: 10 * s,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.cyan,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              SizedBox(height: 8 * s),
                              Text(
                                'Your stress levels have remained elevated for extended periods. The AI recommends a short recovery window — deep breathing, a brief walk, or disengaging from screens — to help reset your system.',
                                style: GoogleFonts.inter(
                                  fontSize: 11 * s,
                                  color: Colors.white.withAlpha(220),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20 * s),

                // ── Share Activity button ─────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ShareActivityScreen(),
                    ),
                  ),
                  child: CustomPaint(
                    painter: SmoothGradientBorder(radius: 28 * s),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28 * s),
                      child: Container(
                        height: 52 * s,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.cyan.withAlpha(40),
                              const Color(0xFF9F56F5).withAlpha(40),
                            ],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Share Activity',
                          style: GoogleFonts.inter(
                            fontSize: 14 * s,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
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
// Widgets
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final double s;
  const _TopBar({required this.s});

  @override
  Widget build(BuildContext context) {
    final h = 60.0 * s;
    return CustomPaint(
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
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.cyan,
                      size: 20 * s,
                    ),
                  ),
                  const Spacer(),
                  Image.asset(
                    'assets/24 logo.png',
                    height: 40 * s,
                    fit: BoxFit.contain,
                  ),
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

class _StatsOverlayCard extends StatelessWidget {
  final double s;
  const _StatsOverlayCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SmoothGradientBorder(radius: 30 * s),
      child: Container(
        padding: EdgeInsets.fromLTRB(20 * s, 24 * s, 20 * s, 28 * s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30 * s),
          color: const Color(0xFF060E16).withAlpha(240),
        ),
        child: Column(
          children: [
            // Row 1: Duration, Distance, Avg Pace
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _StatCell(
                    s: s,
                    icon: Icons.history_rounded,
                    iconColor: AppColors.cyan,
                    label: 'Duration',
                    value: '1h 30m',
                  ),
                ),
                Expanded(
                  child: _StatCell(
                    s: s,
                    icon: Icons.pin_drop_outlined,
                    iconColor: const Color(0xFFD81B60),
                    label: 'Distance',
                    value: '12.5',
                  ),
                ),
                Expanded(
                  child: _StatCell(
                    s: s,
                    icon: Icons.speed_outlined,
                    iconColor: const Color(0xFF4CAF50),
                    label: 'Avg Pace',
                    value: "6'12\"",
                  ),
                ),
              ],
            ),
            SizedBox(height: 18 * s),
            // Row 2: Calories, Avg Heart Rate
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30 * s),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatCell(
                    s: s,
                    icon: Icons.local_fire_department_outlined,
                    iconColor: Colors.orange,
                    label: 'Calories',
                    value: '850',
                  ),
                  _StatCell(
                    s: s,
                    icon: Icons.monitor_heart_outlined,
                    iconColor: const Color(0xFFEF5350),
                    label: 'Avg Heart Rate',
                    value: '850',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 14 * s),
            SizedBox(width: 4 * s),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9 * s,
                color: AppColors.labelDim,
              ),
            ),
          ],
        ),
        SizedBox(height: 4 * s),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15 * s,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _ZoneLabel extends StatelessWidget {
  final double s;
  final String label;
  final Color color;
  const _ZoneLabel({required this.s, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8 * s,
          height: 8 * s,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4 * s),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 9 * s, color: AppColors.labelDim),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Performance Over Time painter  (mountain wave area chart)
// ─────────────────────────────────────────────────────────────────────────────
class _PerformancePainter extends CustomPainter {
  final double s;
  const _PerformancePainter({required this.s});

  // Normalised Y values 0→1 (0=top, 1=bottom)
  static const _pts = [
    0.90,
    0.80,
    0.60,
    0.45,
    0.55,
    0.40,
    0.30,
    0.35,
    0.45,
    0.55,
    0.60,
    0.50,
    0.40,
    0.30,
    0.25,
    0.35,
    0.50,
    0.65,
    0.75,
    0.88,
  ];

  // Y-axis labels (lo → hi)
  static const _yLabels = ["5'55", "6'05", "6'10", "6'20", "6'30", "6'45"];

  @override
  void paint(Canvas canvas, Size size) {
    final yLabelW = 34.0 * s;
    final chartW = size.width - yLabelW;
    final chartH = size.height;

    final tp = TextPainter(textDirection: TextDirection.ltr);

    // Y-axis labels + dashed lines
    final dashPaint = Paint()
      ..color = Colors.white.withAlpha(25)
      ..strokeWidth = 1.2;

    for (int i = 0; i < _yLabels.length; i++) {
      final y = chartH * (1 - i / (_yLabels.length - 1));
      tp
        ..text = TextSpan(
          text: _yLabels[i],
          style: TextStyle(fontSize: 8 * s, color: AppColors.labelDim),
        )
        ..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));

      double dx = yLabelW;
      while (dx < size.width) {
        canvas.drawLine(Offset(dx, y), Offset(dx + 5, y), dashPaint);
        dx += 9;
      }
    }

    if (_pts.isEmpty) return;

    final n = _pts.length;
    final step = chartW / (n - 1);

    Path buildLine() {
      final p = Path();
      p.moveTo(yLabelW, chartH * _pts[0]);
      for (int i = 1; i < n; i++) {
        final x0 = yLabelW + (i - 1) * step;
        final y0 = chartH * _pts[i - 1];
        final x1 = yLabelW + i * step;
        final y1 = chartH * _pts[i];
        final cx = (x0 + x1) / 2;
        p.cubicTo(cx, y0, cx, y1, x1, y1);
      }
      return p;
    }

    final linePath = buildLine();

    // Fill
    final areaPath = Path.from(linePath)
      ..lineTo(yLabelW + chartW, chartH)
      ..lineTo(yLabelW, chartH)
      ..close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.cyan.withAlpha(120), AppColors.cyan.withAlpha(0)],
        ).createShader(Rect.fromLTWH(yLabelW, 0, chartW, chartH)),
    );

    // Stroke
    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.cyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4 * s
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots on line at specific intervals
    final dotPaint = Paint()..color = Colors.white;
    final glowPaint = Paint()
      ..color = Colors.white.withAlpha(100)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (int i = 0; i < n; i += 3) {
      final x = yLabelW + i * step;
      final y = chartH * _pts[i];
      canvas.drawCircle(Offset(x, y), 3.5 * s, glowPaint);
      canvas.drawCircle(Offset(x, y), 2 * s, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_PerformancePainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Heart Rate Zones bar chart painter
// ─────────────────────────────────────────────────────────────────────────────
class _HrZonePainter extends CustomPainter {
  final double s;
  const _HrZonePainter({required this.s});

  static const _bars = [
    _BarDef(0.25, Color(0xFF4CAF50)), // Light (Green)
    _BarDef(0.55, Color(0xFFFFD600)), // Moderate (Yellow)
    _BarDef(0.70, Color(0xFFFF9800)), // Hard (Orange)
    _BarDef(0.92, Color(0xFFEF5350)), // Maximum (Red)
  ];

  static const _yLabels = ['40m', '30m', '20m', '10m', '0'];

  @override
  void paint(Canvas canvas, Size size) {
    final yLabelW = 34.0 * s;
    final chartW = size.width - yLabelW;
    final chartH = size.height;

    final tp = TextPainter(textDirection: TextDirection.ltr);

    // Dashed grid + y labels
    final dashPaint = Paint()
      ..color = Colors.white.withAlpha(18)
      ..strokeWidth = 1;

    for (int i = 0; i < _yLabels.length; i++) {
      final y = chartH * (i / (_yLabels.length - 1));
      tp
        ..text = TextSpan(
          text: _yLabels[i],
          style: TextStyle(fontSize: 7 * s, color: AppColors.labelDim),
        )
        ..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));

      double dx = yLabelW;
      while (dx < size.width) {
        canvas.drawLine(Offset(dx, y), Offset(dx + 5, y), dashPaint);
        dx += 9;
      }
    }

    // Bars
    final n = _bars.length;
    const groupGap = 10.0;
    final barW = (chartW - groupGap * (n + 1)) / n;

    for (int i = 0; i < n; i++) {
      final bH = chartH * _bars[i].heightFactor;
      final x = yLabelW + groupGap + i * (barW + groupGap);
      final top = chartH - bH;
      final rr = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, top, barW, bH),
        topLeft: Radius.circular(10 * s),
        topRight: Radius.circular(10 * s),
      );
      // Glow
      canvas.drawRRect(
        rr,
        Paint()
          ..color = _bars[i].color.withAlpha(60)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      // Fill
      canvas.drawRRect(
        rr,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bars[i].color, _bars[i].color.withAlpha(200)],
          ).createShader(Rect.fromLTWH(x, top, barW, bH)),
      );
    }
  }

  @override
  bool shouldRepaint(_HrZonePainter old) => false;
}

class _BarDef {
  final double heightFactor;
  final Color color;
  const _BarDef(this.heightFactor, this.color);
}

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
