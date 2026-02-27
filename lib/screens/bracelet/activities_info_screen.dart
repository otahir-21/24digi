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

  // Dummy running route — ~5km loop around a generic neighbourhood
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
            padding:
                EdgeInsets.symmetric(horizontal: hPad, vertical: 14 * s),
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

                // ── Map + stats card ──────────────────────────────────
                _BorderCard(
                  s: s,
                  child: Column(
                    children: [
                      // Map
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15 * s)),
                        child: SizedBox(
                          height: 200 * s,
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
                                position: _startLatLng,
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
                        padding: EdgeInsets.symmetric(
                            horizontal: 14 * s, vertical: 12 * s),
                        child: Column(
                          children: [
                            // Row 1
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                _StatCell(
                                    s: s,
                                    icon: Icons.timer_rounded,
                                    iconColor: AppColors.cyan,
                                    label: 'Duration',
                                    value: '1h 30m'),
                                _Divider(s: s),
                                _StatCell(
                                    s: s,
                                    icon: Icons.route_rounded,
                                    iconColor: Colors.greenAccent,
                                    label: 'Distance',
                                    value: '12.5'),
                                _Divider(s: s),
                                _StatCell(
                                    s: s,
                                    icon: Icons.speed_rounded,
                                    iconColor: Colors.purpleAccent,
                                    label: 'Avg Pace',
                                    value: "6'12\""),
                              ],
                            ),
                            SizedBox(height: 10 * s),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                _StatCell(
                                    s: s,
                                    icon:
                                        Icons.local_fire_department_rounded,
                                    iconColor:
                                        const Color(0xFFFF7043),
                                    label: 'Calories',
                                    value: '850'),
                                _Divider(s: s),
                                _StatCell(
                                    s: s,
                                    icon: Icons.favorite_rounded,
                                    iconColor:
                                        const Color(0xFFEF5350),
                                    label: 'Avg Heart Rate',
                                    value: '850'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14 * s),

                // ── Performance Over Time ─────────────────────────────
                _BorderCard(
                  s: s,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        14 * s, 14 * s, 14 * s, 10 * s),
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
                          height: 120 * s,
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: _PerformancePainter(s: s),
                          ),
                        ),
                        SizedBox(height: 4 * s),
                        // dot-line axis
                        Row(
                          children: List.generate(
                            20,
                            (i) => Expanded(
                              child: Container(
                                height: 2 * s,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 1 * s),
                                decoration: BoxDecoration(
                                  color: i % 2 == 0
                                      ? AppColors.labelDim
                                      : Colors.transparent,
                                  borderRadius:
                                      BorderRadius.circular(1),
                                ),
                              ),
                            ),
                          ),
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
                        14 * s, 14 * s, 14 * s, 10 * s),
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
                        SizedBox(height: 10 * s),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                          children: [
                            _ZoneLabel(s: s, label: 'Light',
                                color: const Color(0xFFFFD600)),
                            _ZoneLabel(s: s, label: 'Moderate',
                                color: const Color(0xFFFF9800)),
                            _ZoneLabel(s: s, label: 'Hard',
                                color: const Color(0xFFFF5722)),
                            _ZoneLabel(s: s, label: 'Maximum',
                                color: const Color(0xFFE53935)),
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
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
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
                                  borderRadius:
                                      BorderRadius.circular(6 * s),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF43C6E4),
                                      Color(0xFF9F56F5)
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.cyan.withAlpha(80),
                                      blurRadius: 6,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 6 * s),
                        Text(
                          '32.5 km / 50 km (65%)',
                          style: GoogleFonts.inter(
                            fontSize: 10 * s,
                            color: AppColors.labelDim,
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
                    padding: EdgeInsets.all(16 * s),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.auto_awesome_rounded,
                            color: AppColors.cyan, size: 22 * s),
                        SizedBox(width: 10 * s),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI INSIGHT',
                                style: TextStyle(
                                  fontFamily: 'LemonMilk',
                                  fontSize: 10 * s,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.cyan,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              SizedBox(height: 6 * s),
                              Text(
                                'Your stress levels have remained elevated for extended periods. The AI suggests using this recovery window — deep breathing, a brief walk, or disengaging from screens — to help reset your system.',
                                style: GoogleFonts.inter(
                                  fontSize: 11 * s,
                                  color: AppColors.textLight,
                                  height: 1.5,
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
                        builder: (_) => const ShareActivityScreen()),
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
                        child: Image.asset('assets/fonts/male.png',
                            fit: BoxFit.cover),
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
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 9 * s, color: AppColors.labelDim)),
          ],
        ),
        SizedBox(height: 4 * s),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 15 * s,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final double s;
  const _Divider({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34 * s,
      color: AppColors.divider,
    );
  }
}

class _ZoneLabel extends StatelessWidget {
  final double s;
  final String label;
  final Color color;
  const _ZoneLabel(
      {required this.s, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8 * s,
          height: 8 * s,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4 * s),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 9 * s, color: AppColors.labelDim)),
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
    0.90, 0.80, 0.60, 0.45, 0.55, 0.40, 0.30,
    0.35, 0.45, 0.55, 0.60, 0.50, 0.40, 0.30,
    0.25, 0.35, 0.50, 0.65, 0.75, 0.88,
  ];

  // Y-axis labels (lo → hi)
  static const _yLabels = ['4:00', '5:00', '6:00', '7:00', '8:00'];

  @override
  void paint(Canvas canvas, Size size) {
    final yLabelW = 30.0 * s;
    final chartW  = size.width - yLabelW;
    final chartH  = size.height;

    final tp = TextPainter(textDirection: TextDirection.ltr);

    // Y-axis labels + dashed grid lines
    final dashPaint = Paint()
      ..color = Colors.white.withAlpha(18)
      ..strokeWidth = 1;

    for (int i = 0; i < _yLabels.length; i++) {
      final y = chartH * (i / (_yLabels.length - 1));
      tp
        ..text = TextSpan(
            text: _yLabels[_yLabels.length - 1 - i],
            style: TextStyle(fontSize: 7 * s, color: AppColors.labelDim))
        ..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));

      double dx = yLabelW;
      while (dx < size.width) {
        canvas.drawLine(Offset(dx, y), Offset(dx + 5, y), dashPaint);
        dx += 9;
      }
    }

    if (_pts.isEmpty) return;

    // Build the area path
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
        final mx = (x0 + x1) / 2;
        p.cubicTo(mx, y0, mx, y1, x1, y1);
      }
      return p;
    }

    final linePath = buildLine();

    // Area fill
    final areaPath = Path.from(linePath)
      ..lineTo(yLabelW + (n - 1) * step, chartH)
      ..lineTo(yLabelW, chartH)
      ..close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF00C8FF).withAlpha(160),
            const Color(0xFF00C8FF).withAlpha(20),
          ],
        ).createShader(Rect.fromLTWH(yLabelW, 0, chartW, chartH)),
    );

    // Line stroke
    canvas.drawPath(
      linePath,
      Paint()
        ..color = const Color(0xFF00E5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2 * s
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
    );
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
    _BarDef(0.40, Color(0xFFFFD600)),  // Light
    _BarDef(0.65, Color(0xFFFF9800)),  // Moderate
    _BarDef(0.82, Color(0xFFFF5722)),  // Hard
    _BarDef(0.55, Color(0xFFE53935)),  // Maximum
  ];

  static const _yLabels = ['100+', '75+', '50+', '25+'];

  @override
  void paint(Canvas canvas, Size size) {
    final yLabelW = 34.0 * s;
    final chartW  = size.width - yLabelW;
    final chartH  = size.height;

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
            style: TextStyle(fontSize: 7 * s, color: AppColors.labelDim))
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
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top, barW, bH),
        Radius.circular(barW / 2),
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
            colors: [
              _bars[i].color,
              _bars[i].color.withAlpha(200),
            ],
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
