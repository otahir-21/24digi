import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../../bracelet/bracelet_channel.dart';
import '../../bracelet/bracelet_metrics_cache.dart';
import '../../bracelet/hydration_activity_adjustment.dart';
import '../../bracelet/hydration_storage.dart';
import '../../painters/smooth_gradient_border.dart';
import 'bracelet_scaffold.dart';
import '../../bracelet/bracelet_dashboard_typography.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HydrationScreen – user-logged water + optional activity-adjusted goal from bracelet liveData.
// ─────────────────────────────────────────────────────────────────────────────
class HydrationScreen extends StatefulWidget {
  const HydrationScreen({super.key, this.channel, this.liveData});

  final BraceletChannel? channel;
  final Map<String, dynamic>? liveData;

  @override
  State<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> {
  int _periodIndex = 0; // 0=Daily 1=Weekly 2=Monthly

  double get _currentLiters => HydrationStorage.currentLiters;
  double get _baseGoalLiters => HydrationStorage.goalLiters;
  double get _activityBonusLiters =>
      HydrationActivityAdjustment.bonusLitersFromLiveData(widget.liveData);
  double get _effectiveGoalLiters =>
      HydrationActivityAdjustment.effectiveGoalLiters(_baseGoalLiters, widget.liveData);
  double get _progress => HydrationActivityAdjustment.progress(
        _currentLiters,
        _baseGoalLiters,
        widget.liveData,
      );

  int? get _braceletIndex =>
      HydrationActivityAdjustment.braceletHydrationIndexPercent(widget.liveData);

  /// Silhouette fill: logged progress and/or normalized bracelet index (38–97 → 0–1).
  double get _bodyFillProgress {
    final logged = _progress.clamp(0.0, 1.0);
    final idx = _braceletIndex;
    if (idx == null) return logged;
    final fromBand = ((idx - 38) / (97 - 38)).clamp(0.0, 1.0);
    return logged > fromBand ? logged : fromBand;
  }

  void _addWater(double liters) {
    HydrationStorage.addLiters(liters);
    if (mounted) setState(() {});
  }

  void _onRevisionChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    HydrationStorage.revision.addListener(_onRevisionChanged);
  }

  @override
  void dispose() {
    HydrationStorage.revision.removeListener(_onRevisionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final cw = AppConstants.getScaleWidth(context);

    return BraceletScaffold(
      child: Column(
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
          SizedBox(height: 20 * s),

          // ── Main hydration display (from storage, no dummy) ────
          _HydrationTopCard(
            s: s,
            braceletIndex: _braceletIndex,
            bodyFillProgress: _bodyFillProgress,
            currentLiters: _currentLiters,
            goalLiters: _effectiveGoalLiters,
            activityBonusLiters: _activityBonusLiters,
          ),
          SizedBox(height: 30 * s),

          // ── Daily progress card + add water buttons ────────────
          _BorderCard(
            s: s,
            child: _GaugeCard(
              s: s,
              cw: cw,
              currentLiters: _currentLiters,
              goalLiters: _effectiveGoalLiters,
              activityBonusLiters: _activityBonusLiters,
              braceletIndex: _braceletIndex,
              onAddCup: _addWater,
            ),
          ),
          SizedBox(height: 20 * s),

          // ── Period toggle ────────────────────────────────────────
          Center(
            child: _PeriodToggle(
              s: s,
              selected: _periodIndex,
              onTap: (i) => setState(() => _periodIndex = i),
            ),
          ),
          SizedBox(height: 24 * s),

          // ── Hydration frequency (no dummy data; empty when no history) ─
          _BorderCard(
            s: s,
            child: _GraphCard(s: s, cw: cw, period: _periodIndex),
          ),
          SizedBox(height: 20 * s),

          // ── AI Insight ────────────────────────────────────────
          _BorderCard(
            s: s,
            child: _AiInsightCard(
              s: s,
              progress: _progress,
              currentLiters: _currentLiters,
              goalLiters: _effectiveGoalLiters,
              activityBonusLiters: _activityBonusLiters,
              braceletIndex: _braceletIndex,
            ),
          ),
          SizedBox(height: 30 * s),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Components
// ─────────────────────────────────────────────────────────────────────────────
class _BorderCard extends StatelessWidget {
  final double s;
  final Widget child;
  const _BorderCard({required this.s, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SmoothGradientBorder(radius: 32 * s),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32 * s),
        child: ColoredBox(color: const Color(0xFF060E16), child: child),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hydration top card: header + neon pills + person painter
// ─────────────────────────────────────────────────────────────────────────────
class _HydrationTopCard extends StatelessWidget {
  final double s;
  final int? braceletIndex;
  final double bodyFillProgress;
  final double currentLiters;
  final double goalLiters;
  final double activityBonusLiters;
  const _HydrationTopCard({
    required this.s,
    required this.braceletIndex,
    required this.bodyFillProgress,
    required this.currentLiters,
    required this.goalLiters,
    this.activityBonusLiters = 0,
  });

  @override
  Widget build(BuildContext context) {
    final p = bodyFillProgress.clamp(0.0, 1.0);
    final indexText = braceletIndex != null ? '${braceletIndex!}' : '—';

    return Row(
      children: [
        // ── LEFT stats ──
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bracelet hydration index',
                style: BraceletDashboardTypography.text(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15 * s,
                ),
              ),
              SizedBox(height: 4 * s),
              Text(
                'From live band readings (not body water %).',
                style: BraceletDashboardTypography.text(
                  color: AppColors.labelDim,
                  fontWeight: FontWeight.w400,
                  fontSize: 10 * s,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 12 * s),
              _ValueBox(
                s: s,
                width: 130 * s,
                height: 100 * s,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 8 * s),
                      child: Text(
                        '% ',
                        style: BraceletDashboardTypography.text(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 28 * s,
                        ),
                      ),
                    ),
                    Text(
                      indexText,
                      style: BraceletDashboardTypography.text(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 48 * s,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20 * s),
              Text(
                'Progress Towards Goal',
                style: BraceletDashboardTypography.text(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15 * s,
                ),
              ),
              SizedBox(height: 12 * s),
              _ValueBox(
                s: s,
                width: 130 * s,
                height: 100 * s,
                child: Center(
                  child: currentLiters > 0
                      ? Text(
                          '${currentLiters.toStringAsFixed(1)}L\n/ ${goalLiters.toStringAsFixed(1)}L',
                          textAlign: TextAlign.center,
                          style: BraceletDashboardTypography.text(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18 * s,
                            height: 1.3,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '— L',
                              style: BraceletDashboardTypography.text(
                                color: AppColors.labelDim,
                                fontWeight: FontWeight.w700,
                                fontSize: 22 * s,
                              ),
                            ),
                            Text(
                              'Tap + to log',
                              style: BraceletDashboardTypography.text(
                                color: AppColors.labelDim,
                                fontSize: 10 * s,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (activityBonusLiters >= 0.01) ...[
                SizedBox(height: 10 * s),
                Text(
                  '+${activityBonusLiters.toStringAsFixed(1)} L for activity (estimate)',
                  style: BraceletDashboardTypography.text(
                    color: AppColors.labelDim,
                    fontSize: 11 * s,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 20 * s),
        // ── RIGHT person ──
        HydrationBodyWidget(progress: p, size: 320 * s),
      ],
    );
  }
}

class _ValueBox extends StatelessWidget {
  final double s, width, height;
  final Widget child;
  const _ValueBox({
    required this.s,
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SmoothGradientBorder(radius: 20 * s),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20 * s),
        child: Container(
          width: width,
          height: height,
          color: const Color(0xFF060E16),
          child: child,
        ),
      ),
    );
  }
}

class HydrationBodyWidget extends StatelessWidget {
  final double progress;
  final double size;

  const HydrationBodyWidget({
    super.key,
    required this.progress,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    // SVG canvas: body=173×292, head=89.9×89.9 placed above body
    // Combined logical canvas: 173 wide, 380 tall (head@y=0, body@y=88)
    return SizedBox(
      width: size * 0.455, // 173/380
      height: size,
      child: CustomPaint(painter: _HydrationBodyPainter(progress: progress)),
    );
  }
}

class _HydrationBodyPainter extends CustomPainter {
  final double progress;
  _HydrationBodyPainter({required this.progress});

  // SVG logical dimensions
  static const double _svgW = 173;
  static const double _svgH = 380; // head(88) + body(292)
  static const double _bodyOffsetY =
      88; // body starts at this y in combined canvas

  // Head circle: center ~(44.95, 44.95), r~41.45 in its own 89.9×89.9 space
  // Centered in 173-wide canvas: translate x by (173/2 - 44.95) = 41.55
  static final Path _headPath = parseSvgPathData(
    'M44.9546 86.4093C67.8494 86.4093 86.4093 67.8494 86.4093 44.9546'
    'C86.4093 22.0599 67.8494 3.5 44.9546 3.5C22.0599 3.5 3.5 22.0599'
    ' 3.5 44.9546C3.5 67.8494 22.0599 86.4093 44.9546 86.4093Z',
  );

  static final Path _bodyPath = parseSvgPathData(
    'M121.942 3.5H50.8767C38.323 3.5371 26.2941 8.54048 17.4173 17.4173'
    'C8.54048 26.2941 3.5371 38.323 3.5 50.8767V130.47C3.5 138.501 9.74041'
    ' 145.334 17.7648 145.623C19.7535 145.695 21.7363 145.366 23.5949 144.655'
    'C25.4535 143.944 27.1497 142.866 28.5822 141.485C30.0146 140.103 31.1539'
    ' 138.448 31.9319 136.616C32.71 134.784 33.1108 132.815 33.1105 130.825'
    'V56.9987C33.0916 55.4709 33.6511 53.9924 34.6766 52.8597C35.7022 51.7271'
    ' 37.118 51.024 38.6402 50.8915C39.4503 50.8377 40.2627 50.9511 41.0272'
    ' 51.2245C41.7916 51.498 42.4916 51.9256 43.0838 52.481C43.6759 53.0364'
    ' 44.1476 53.7076 44.4694 54.4529C44.7913 55.1982 44.9564 56.0018 44.9546'
    ' 56.8136V270.734C44.9546 275.25 46.7484 279.581 49.9414 282.774C53.1344'
    ' 285.967 57.4651 287.76 61.9806 287.76C66.4962 287.76 70.8269 285.967'
    ' 74.0199 282.774C77.2129 279.581 79.0067 275.25 79.0067 270.734V165.129'
    'C78.9804 163.217 79.6776 161.366 80.9583 159.947C82.2391 158.527 84.009'
    ' 157.644 85.9133 157.474C86.9263 157.406 87.9425 157.547 88.8987 157.889'
    'C89.8549 158.23 90.7306 158.765 91.4714 159.459C92.2122 160.153 92.8023'
    ' 160.993 93.2049 161.925C93.6076 162.857 93.8142 163.862 93.8119 164.877'
    'V270.734C93.8119 275.25 95.6057 279.581 98.7987 282.774C101.992 285.967'
    ' 106.322 287.76 110.838 287.76C115.353 287.76 119.684 285.967 122.877'
    ' 282.774C126.07 279.581 127.864 275.25 127.864 270.734V56.9987C127.845'
    ' 55.4709 128.405 53.9924 129.43 52.8597C130.456 51.7271 131.871 51.024'
    ' 133.394 50.8915C134.204 50.8377 135.016 50.9511 135.781 51.2245C136.545'
    ' 51.498 137.245 51.9256 137.837 52.481C138.429 53.0364 138.901 53.7076'
    ' 139.223 54.4529C139.545 55.1982 139.71 56.0018 139.708 56.8136V130.484'
    'C139.708 138.516 145.948 145.349 153.973 145.638C155.963 145.71 157.947'
    ' 145.381 159.806 144.669C161.666 143.957 163.363 142.877 164.796 141.494'
    'C166.228 140.112 167.367 138.454 168.144 136.621C168.921 134.787 169.321'
    ' 132.816 169.319 130.825V50.8767C169.281 38.323 164.278 26.2941 155.401'
    ' 17.4173C146.524 8.54048 134.495 3.5371 121.942 3.5Z',
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final scaleX = size.width / _svgW;
    final scaleY = size.height / _svgH;

    // Scale + position head: center it in the 173-wide canvas, place at top
    final headMatrix = Matrix4.identity()
      ..translate(41.55 * scaleX, 0.0)
      ..scale(scaleX, scaleY);
    final scaledHead = _headPath.transform(headMatrix.storage);

    // Scale + position body: shifted down by _bodyOffsetY in SVG space
    final bodyMatrix = Matrix4.identity()
      ..translate(0.0, _bodyOffsetY * scaleY)
      ..scale(scaleX, scaleY);
    final scaledBody = _bodyPath.transform(bodyMatrix.storage);

    // Combine both into one path for clipping + outline
    final combinedPath = Path.combine(
      PathOperation.union,
      scaledHead,
      scaledBody,
    );

    // ── Water fill clipped to combined silhouette ──
    canvas.save();
    canvas.clipPath(combinedPath);

    final waterLevel = size.height - (size.height * progress.clamp(0.0, 1.0));
    final wavePath = Path()..moveTo(0, waterLevel);
    for (double i = 0; i <= size.width; i++) {
      wavePath.lineTo(
        i,
        waterLevel + math.sin((i / size.width * 2 * math.pi)) * 6 * scaleY,
      );
    }
    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();
    canvas.drawPath(wavePath, Paint()..color = const Color(0xFF35B1DC));

    // Shimmer on wave crest
    final crestPath = Path()..moveTo(0, waterLevel);
    for (double i = 0; i <= size.width; i++) {
      crestPath.lineTo(
        i,
        waterLevel + math.sin((i / size.width * 2 * math.pi)) * 6 * scaleY,
      );
    }
    canvas.drawPath(
      crestPath,
      Paint()
        ..color = Colors.white.withAlpha(90)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.restore();

    // ── Outline on top ──
    canvas.drawPath(
      combinedPath,
      Paint()
        ..color = const Color(0xFF2B3143)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7 * scaleX
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_HydrationBodyPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Gauge card: circular water fill + cup buttons (real data from HydrationStorage)
// ─────────────────────────────────────────────────────────────────────────────
class _GaugeCard extends StatelessWidget {
  final double s;
  final double cw;
  final double currentLiters;
  final double goalLiters;
  final double activityBonusLiters;
  final int? braceletIndex;
  final void Function(double liters) onAddCup;

  const _GaugeCard({
    required this.s,
    required this.cw,
    required this.currentLiters,
    required this.goalLiters,
    this.activityBonusLiters = 0,
    this.braceletIndex,
    required this.onAddCup,
  });

  @override
  Widget build(BuildContext context) {
    final gaugeSize = 180.0 * s;
    final pct = goalLiters > 0 ? (currentLiters / goalLiters).clamp(0.0, 1.0) : 0.0;
    final percentText = goalLiters > 0 ? (pct * 100).round() : 0;
    final gaugeLabel = currentLiters > 0 ? '$percentText%' : '—';

    return Padding(
      padding: EdgeInsets.all(24 * s),
      child: Column(
        children: [
          Text(
            currentLiters > 0
                ? '${currentLiters.toStringAsFixed(1)} L / ${goalLiters.toStringAsFixed(1)} L'
                : 'No water logged yet · tap + to start',
            style: BraceletDashboardTypography.text(
              fontSize: currentLiters > 0 ? 16 * s : 13 * s,
              fontWeight: FontWeight.w600,
              color: currentLiters > 0 ? Colors.white : AppColors.labelDim,
              letterSpacing: 0.5,
            ),
          ),
          if (activityBonusLiters >= 0.01)
            Padding(
              padding: EdgeInsets.only(top: 6 * s),
              child: Text(
                'Includes +${activityBonusLiters.toStringAsFixed(1)} L from bracelet activity',
                textAlign: TextAlign.center,
                style: BraceletDashboardTypography.text(
                  fontSize: 11 * s,
                  color: AppColors.labelDim,
                  height: 1.3,
                ),
              ),
            ),
          if (braceletIndex != null)
            Padding(
              padding: EdgeInsets.only(top: 8 * s),
              child: Text(
                'Bracelet hydration index: $braceletIndex% (heuristic; bracelet home tile shows logged liters & goal)',
                textAlign: TextAlign.center,
                style: BraceletDashboardTypography.text(
                  fontSize: 11 * s,
                  color: AppColors.cyan.withAlpha(200),
                  height: 1.3,
                ),
              ),
            ),
          SizedBox(height: 24 * s),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: gaugeSize,
                height: gaugeSize,
                child: CustomPaint(
                  painter: _WaterGaugePainter(pct: pct, s: s),
                  child: Center(
                    child: Text(
                      gaugeLabel,
                      style: BraceletDashboardTypography.text(
                        fontSize: 38 * s,
                        fontWeight: FontWeight.w700,
                        color: currentLiters > 0
                            ? Colors.white
                            : AppColors.labelDim,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _CupButton(
                    s: s,
                    label: '+1 CUP/',
                    sub: '250 ml',
                    type: 1,
                    onTap: () => onAddCup(0.25),
                  ),
                  SizedBox(height: 16 * s),
                  _CupButton(
                    s: s,
                    label: '+2 CUP/',
                    sub: '500 ml',
                    type: 2,
                    onTap: () => onAddCup(0.5),
                  ),
                  SizedBox(height: 20 * s),
                  Row(
                    children: [
                      Text(
                        'Custom',
                        style: BraceletDashboardTypography.text(
                          fontSize: 13 * s,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8 * s),
                      _CupIcon(s: s, type: 3, width: 32 * s, height: 40 * s),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Circular water-fill gauge painter
class _WaterGaugePainter extends CustomPainter {
  final double pct, s;
  const _WaterGaugePainter({required this.pct, required this.s});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Background circle
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = const Color(0xFF1E2E3A),
    );

    // Water fill clipping
    canvas.save();
    canvas.clipPath(Path()..addOval(rect));

    final fillH = size.height * pct;
    final waterLevelY = size.height - fillH;

    // Dual wave layer
    final wavePaint = Paint()..color = const Color(0xFF35B1DC);

    // Back wave (darker)
    final backWavePath = Path();
    backWavePath.moveTo(0, waterLevelY);
    for (double x = 0; x <= size.width; x++) {
      final y =
          waterLevelY +
          math.sin((x / size.width * 2 * math.pi) + math.pi) * 6 * s;
      backWavePath.lineTo(x, y);
    }
    backWavePath.lineTo(size.width, size.height);
    backWavePath.lineTo(0, size.height);
    backWavePath.close();
    canvas.drawPath(
      backWavePath,
      Paint()..color = const Color(0xFF35B1DC).withAlpha(150),
    );

    // Front wave (brighter)
    final frontWavePath = Path();
    frontWavePath.moveTo(0, waterLevelY);
    for (double x = 0; x <= size.width; x++) {
      final y = waterLevelY + math.sin((x / size.width * 2 * math.pi)) * 6 * s;
      frontWavePath.lineTo(x, y);
    }
    frontWavePath.lineTo(size.width, size.height);
    frontWavePath.lineTo(0, size.height);
    frontWavePath.close();
    canvas.drawPath(frontWavePath, wavePaint);

    canvas.restore();

    // Border
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00F0FF).withAlpha(100),
            const Color(0xFF8B36FF).withAlpha(100),
          ],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * s,
    );
  }

  @override
  bool shouldRepaint(_WaterGaugePainter old) => old.pct != pct;
}

// Cup add button
class _CupButton extends StatelessWidget {
  final double s;
  final String label;
  final String sub;
  final int type;
  final VoidCallback? onTap;

  const _CupButton({
    required this.s,
    required this.label,
    required this.sub,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              label,
              style: BraceletDashboardTypography.text(
                fontSize: 12 * s,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            Text(
              sub,
              style: BraceletDashboardTypography.text(
                fontSize: 10 * s,
                color: AppColors.labelDim,
              ),
            ),
          ],
        ),
        SizedBox(width: 12 * s),
        _CupIcon(s: s, type: type),
      ],
    );
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }
    return content;
  }
}

class _CupIcon extends StatelessWidget {
  final double s;
  final int type;
  final double? width, height;
  const _CupIcon({
    required this.s,
    required this.type,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width ?? 28 * s, height ?? 36 * s),
      painter: _CupPainter(type: type),
    );
  }
}

class _CupPainter extends CustomPainter {
  final int type;
  _CupPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF16202A)
      ..style = PaintingStyle.fill;

    // Simple trapezoid for cup
    final path = Path();
    path.moveTo(size.width * 0.1, 0);
    path.lineTo(size.width * 0.9, 0);
    path.lineTo(size.width * 0.75, size.height);
    path.lineTo(size.width * 0.25, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Water fill
    final fillPath = Path();
    fillPath.moveTo(size.width * 0.1, size.height * 0.4);
    fillPath.lineTo(size.width * 0.9, size.height * 0.4);
    fillPath.lineTo(size.width * 0.75, size.height);
    fillPath.lineTo(size.width * 0.25, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, Paint()..color = const Color(0xFF35B1DC));

    // Water drops if type 2
    if (type == 1 || type == 2) {
      final dropPaint = Paint()..color = Colors.white;
      _drawDrop(
        canvas,
        Offset(size.width * 0.5, size.height * 0.2),
        size.width * 0.15,
        dropPaint,
      );
      if (type == 2) {
        _drawDrop(
          canvas,
          Offset(size.width * 0.3, size.height * 0.5),
          size.width * 0.15,
          dropPaint,
        );
        _drawDrop(
          canvas,
          Offset(size.width * 0.7, size.height * 0.5),
          size.width * 0.15,
          dropPaint,
        );
      }
    }
  }

  void _drawDrop(Canvas canvas, Offset center, double r, Paint paint) {
    final p = Path();
    p.moveTo(center.dx, center.dy - r * 1.5);
    p.quadraticBezierTo(center.dx + r, center.dy, center.dx, center.dy + r);
    p.quadraticBezierTo(
      center.dx - r,
      center.dy,
      center.dx,
      center.dy - r * 1.5,
    );
    canvas.drawPath(p, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Period toggle: Daily / Weekly / Monthly
// ─────────────────────────────────────────────────────────────────────────────
class _PeriodToggle extends StatelessWidget {
  final double s;
  final int selected;
  final ValueChanged<int> onTap;
  const _PeriodToggle({
    required this.s,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['Daily', 'Weekly', 'Monthly'];
    return Container(
      padding: EdgeInsets.all(4 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF16202A),
        borderRadius: BorderRadius.circular(28 * s),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(labels.length, (i) {
          final active = i == selected;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 2 * s),
              padding: EdgeInsets.symmetric(
                horizontal: 24 * s,
                vertical: 8 * s,
              ),
              decoration: BoxDecoration(
                color: active ? const Color(0xFF145E73) : Colors.transparent,
                borderRadius: BorderRadius.circular(24 * s),
              ),
              child: Text(
                labels[i],
                style: BraceletDashboardTypography.text(
                  fontSize: 13 * s,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? Colors.white : AppColors.labelDim,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily graph card – uses HydrationStorage.hourlyProgressForGraph (real data).
// ─────────────────────────────────────────────────────────────────────────────
List<String> _weekdayLabelsOldestFirst() {
  const abbr = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return List.generate(7, (i) {
    final d = today.subtract(Duration(days: 6 - i));
    return abbr[d.weekday - 1];
  });
}

class _GraphCard extends StatelessWidget {
  final double s;
  final double cw;
  final int period;
  const _GraphCard({required this.s, required this.cw, required this.period});

  @override
  Widget build(BuildContext context) {
    const titles = ['Daily Graph', 'Weekly Graph', 'Monthly Graph'];
    const subtitles = [
      'Logged water vs goal by hour',
      'Bracelet index from saved daily steps & calories',
      'Bracelet index from ~4-day buckets (last 28 days)',
    ];

    late final List<double> values;
    late final List<String> xLabels;
    late final String emptyMessage;
    late final bool useHourlyLayout;

    if (period == 0) {
      values = HydrationStorage.hourlyProgressForGraph;
      xLabels = const ['00', '06', '12', '18', '24'];
      emptyMessage = 'Log water to see daily graph';
      useHourlyLayout = true;
    } else if (period == 1) {
      final cache = BraceletMetricsCache.instance;
      values = HydrationActivityAdjustment.normalizedHydrationIndexBarsFromActivitySeries(
        cache.last7DaysSteps,
        cache.last7DaysCalories,
      );
      xLabels = _weekdayLabelsOldestFirst();
      emptyMessage = 'Wear the band and sync to see weekly trend';
      useHourlyLayout = false;
    } else {
      final cache = BraceletMetricsCache.instance;
      values = HydrationActivityAdjustment.normalizedHydrationIndexBarsFromActivitySeries(
        cache.monthlyStepBars7,
        cache.monthlyCaloriesBars7,
      );
      xLabels = List.generate(7, (i) => '${i + 1}');
      emptyMessage = 'Wear the band and sync to see monthly trend';
      useHourlyLayout = false;
    }

    final hasData = values.isNotEmpty &&
        values.any((v) => v > 0) &&
        (useHourlyLayout ? values.length >= 24 : values.length >= 7);

    return Padding(
      padding: EdgeInsets.fromLTRB(14 * s, 14 * s, 14 * s, 10 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titles[period],
            style: BraceletDashboardTypography.text(
              fontSize: 11 * s,
              color: AppColors.labelDim,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            subtitles[period],
            style: BraceletDashboardTypography.text(
              fontSize: 9 * s,
              color: AppColors.labelDim.withAlpha(180),
              height: 1.2,
            ),
          ),
          SizedBox(height: 10 * s),
          SizedBox(
            width: double.infinity,
            height: 110 * s,
            child: hasData
                ? CustomPaint(
                    painter: _HydrationBarPainter(
                      s: s,
                      values: values,
                      xLabels: xLabels,
                    ),
                  )
                : Center(
                    child: Text(
                      emptyMessage,
                      textAlign: TextAlign.center,
                      style: BraceletDashboardTypography.text(
                        fontSize: 13 * s,
                        color: AppColors.labelDim,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _HydrationBarPainter extends CustomPainter {
  final double s;
  final List<double> values;
  final List<String> xLabels;

  const _HydrationBarPainter({
    required this.s,
    required this.values,
    this.xLabels = const ['00', '06', '12', '18', '24'],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    if (n == 0) return;
    final chartH = size.height - 20 * s;
    final barGap = 2.0 * s;
    final barW = (size.width - (n - 1) * barGap) / n;

    // Dashed guide lines
    final linePaint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..strokeWidth = 0.5;
    for (int i = 0; i < 6; i++) {
      final y = chartH * (i / 5);
      double curX = 0;
      while (curX < size.width) {
        canvas.drawLine(Offset(curX, y), Offset(curX + 4 * s, y), linePaint);
        curX += 8 * s;
      }
    }

    // Bars (0..1 per bucket)
    for (int i = 0; i < n; i++) {
      final x = (barW + barGap) * i;
      final pct = values[i].clamp(0.0, 1.0);
      final bH = chartH * pct;
      final top = chartH - bH;

      canvas.drawRect(
        Rect.fromLTWH(x, top, barW, bH),
        Paint()..color = const Color(0xFF35B1DC),
      );
    }

    final labels = xLabels;
    if (labels.isEmpty) return;
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final denom = labels.length > 1 ? (labels.length - 1) : 1;
    for (int i = 0; i < labels.length; i++) {
      final xPos = (size.width / denom) * i;
      tp
        ..text = TextSpan(
          text: labels[i],
          style: TextStyle(fontSize: 10 * s, color: AppColors.labelDim),
        )
        ..layout();
      tp.paint(canvas, Offset(xPos - tp.width / 2, chartH + 8 * s));
    }
  }

  @override
  bool shouldRepaint(_HydrationBarPainter old) =>
      old.s != s || old.values != values || old.xLabels != xLabels;
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Insight card
// ─────────────────────────────────────────────────────────────────────────────
class _AiInsightCard extends StatelessWidget {
  final double s;
  final double progress;
  final double currentLiters;
  final double goalLiters;
  final double activityBonusLiters;
  final int? braceletIndex;

  const _AiInsightCard({
    required this.s,
    required this.progress,
    required this.currentLiters,
    required this.goalLiters,
    this.activityBonusLiters = 0,
    this.braceletIndex,
  });

  static String _insight(
    double progress,
    double current,
    double goal,
    double activityBonus,
    int? braceletIndex,
  ) {
    final bandNote = braceletIndex != null
        ? ' Bracelet hydration index is $braceletIndex% (heuristic from activity and vitals, not a lab value).'
        : '';
    final activityNote = activityBonus >= 0.01
        ? ' Your ${goal.toStringAsFixed(1)} L target includes +${activityBonus.toStringAsFixed(1)} L suggested for today\'s activity (not a medical reading).'
        : '';
    if (current == 0) {
      return 'You have not logged any water yet today. Start with a glass now — even mild dehydration affects focus, energy, and physical performance.$bandNote$activityNote';
    }
    if (progress < 0.25) {
      return 'You are at ${(progress * 100).round()}% of your daily goal (${current.toStringAsFixed(1)}L / ${goal.toStringAsFixed(1)}L). Drink steadily throughout the day rather than all at once to maintain optimal hydration.$bandNote$activityNote';
    }
    if (progress < 0.5) {
      return 'Good start — you are at ${(progress * 100).round()}% of your goal. Keep it up. Aim to reach 50% by midday and spread the rest across the afternoon.$bandNote$activityNote';
    }
    if (progress < 0.75) {
      return 'You are halfway there at ${(progress * 100).round()}%. Your circulation and energy levels should be well-supported. Keep sipping regularly to hit your ${goal.toStringAsFixed(1)}L goal.$bandNote$activityNote';
    }
    if (progress < 1.0) {
      return 'Almost there — ${(progress * 100).round()}% complete (${current.toStringAsFixed(1)}L / ${goal.toStringAsFixed(1)}L). Just a little more to fully meet your daily hydration target.$bandNote$activityNote';
    }
    return 'Goal reached! You have logged ${current.toStringAsFixed(1)}L today. Well done — staying consistently hydrated supports recovery, skin health, and cognitive performance.$bandNote';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: AppColors.cyan, size: 22 * s),
          SizedBox(width: 10 * s),
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
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 6 * s),
                Text(
                  _insight(
                    progress,
                    currentLiters,
                    goalLiters,
                    activityBonusLiters,
                    braceletIndex,
                  ),
                  style: BraceletDashboardTypography.text(
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
    );
  }
}
