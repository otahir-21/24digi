import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../core/app_constants.dart';
import '../services/bracelet_vitals_history_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Which vital to extract from a DailyVitals record
// ─────────────────────────────────────────────────────────────────────────────
enum VitalType { stress, heartRate, spo2, hrv, temperature, steps }

extension _VitalExt on VitalType {
  double? extract(DailyVitals v) {
    switch (this) {
      case VitalType.stress:      return v.stressIndex?.toDouble();
      case VitalType.heartRate:   return v.heartRateBpm?.toDouble();
      case VitalType.spo2:        return v.spo2Percent?.toDouble();
      case VitalType.hrv:         return v.hrvMs?.toDouble();
      case VitalType.temperature: return v.temperatureC;
      case VitalType.steps:       return v.steps?.toDouble();
    }
  }

  String get unit {
    switch (this) {
      case VitalType.stress:      return '';
      case VitalType.heartRate:   return 'BPM';
      case VitalType.spo2:        return '%';
      case VitalType.hrv:         return 'ms';
      case VitalType.temperature: return '°C';
      case VitalType.steps:       return 'steps';
    }
  }

  /// Returns a 0–1 normalised fraction for bar height.
  double normalise(double raw) {
    switch (this) {
      case VitalType.stress:      return (raw / 100).clamp(0, 1);
      case VitalType.heartRate:   return ((raw - 30) / 170).clamp(0, 1);
      case VitalType.spo2:        return ((raw - 80) / 20).clamp(0, 1);
      case VitalType.hrv:         return (raw / 100).clamp(0, 1);
      case VitalType.temperature: return ((raw - 35) / 5).clamp(0, 1);
      case VitalType.steps:       return (raw / 15000).clamp(0, 1);
    }
  }

  Color barColor(double raw) {
    switch (this) {
      case VitalType.stress:
        if (raw < 33) return const Color(0xFF4CAF50);
        if (raw < 66) return const Color(0xFF43C6E4);
        return const Color(0xFFE53935);
      case VitalType.heartRate:
        if (raw < 60 || raw > 120) return const Color(0xFFE53935);
        if (raw > 100) return const Color(0xFFFFEB3B);
        return const Color(0xFF4CAF50);
      case VitalType.spo2:
        if (raw >= 95) return const Color(0xFF4CAF50);
        if (raw >= 91) return const Color(0xFFFFEB3B);
        return const Color(0xFFE53935);
      case VitalType.hrv:
        if (raw > 50) return const Color(0xFF4CAF50);
        if (raw >= 30) return const Color(0xFF43C6E4);
        if (raw >= 20) return const Color(0xFFFFEB3B);
        return const Color(0xFFE53935);
      case VitalType.temperature:
        if (raw < 36.0 || raw > 38.0) return const Color(0xFFE53935);
        if (raw > 37.2) return const Color(0xFFFFEB3B);
        return const Color(0xFF4CAF50);
      case VitalType.steps:
        if (raw >= 10000) return const Color(0xFF4CAF50);
        if (raw >= 5000)  return const Color(0xFF43C6E4);
        return const Color(0xFFFFEB3B);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Public widget
// ─────────────────────────────────────────────────────────────────────────────

/// Fetches vitals history from Firestore and renders a color-coded bar chart.
///
/// Used by Weekly (7 days) and Monthly (30 days) period tabs on each health screen.
class VitalsHistoryChart extends StatefulWidget {
  final VitalType vitalType;
  final bool weekly; // true = 7 days, false = 30 days

  const VitalsHistoryChart({
    super.key,
    required this.vitalType,
    required this.weekly,
  });

  @override
  State<VitalsHistoryChart> createState() => _VitalsHistoryChartState();
}

class _VitalsHistoryChartState extends State<VitalsHistoryChart> {
  List<DailyVitals>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(VitalsHistoryChart old) {
    super.didUpdateWidget(old);
    if (old.weekly != widget.weekly || old.vitalType != widget.vitalType) {
      setState(() { _loading = true; _data = null; _error = null; });
      _fetch();
    }
  }

  Future<void> _fetch() async {
    final uid = context.read<AuthProvider>().firebaseUser?.uid;
    if (uid == null) {
      setState(() { _loading = false; _error = 'Not logged in'; });
      return;
    }
    try {
      final list = widget.weekly
          ? await BraceletVitalsHistoryService.fetchWeekly(uid)
          : await BraceletVitalsHistoryService.fetchMonthly(uid);
      if (mounted) setState(() { _data = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    if (_loading) {
      return SizedBox(
        height: 180 * s,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2),
        ),
      );
    }

    if (_error != null) {
      return _EmptyState(s: s, message: 'Could not load history.');
    }

    final vt = widget.vitalType;
    final entries = (_data ?? [])
        .map((d) => (date: d.date, raw: vt.extract(d)))
        .where((e) => e.raw != null)
        .toList();

    if (entries.isEmpty) {
      return _EmptyState(
        s: s,
        message: widget.weekly
            ? 'No weekly data yet.\n\nKeep your bracelet connected — readings save automatically. Check back after using it for a day or two.'
            : 'No monthly data yet.\n\nData builds up over time as you wear your bracelet daily.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // summary row
        _SummaryRow(s: s, entries: entries, vitalType: vt),
        SizedBox(height: 12 * s),
        SizedBox(
          width: double.infinity,
          height: 180 * s,
          child: CustomPaint(
            painter: _HistoryBarPainter(
              s: s,
              entries: entries,
              vitalType: vt,
              weekly: widget.weekly,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final double s;
  final String message;
  const _EmptyState({required this.s, required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120 * s,
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 12 * s, color: AppColors.labelDim, height: 1.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final double s;
  final List<({DateTime date, double? raw})> entries;
  final VitalType vitalType;

  const _SummaryRow({required this.s, required this.entries, required this.vitalType});

  @override
  Widget build(BuildContext context) {
    final vals = entries.map((e) => e.raw!).toList();
    final avg = vals.reduce((a, b) => a + b) / vals.length;
    final mn  = vals.reduce((a, b) => a < b ? a : b);
    final mx  = vals.reduce((a, b) => a > b ? a : b);
    final u   = vitalType.unit;

    String fmt(double v) =>
        vitalType == VitalType.temperature ? v.toStringAsFixed(1) : v.round().toString();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _SummaryTile(s: s, label: 'Avg', value: '${fmt(avg)} $u'.trim(), color: AppColors.cyan),
        _SummaryTile(s: s, label: 'Min', value: '${fmt(mn)} $u'.trim(),  color: const Color(0xFF4CAF50)),
        _SummaryTile(s: s, label: 'Max', value: '${fmt(mx)} $u'.trim(),  color: const Color(0xFFE53935)),
        _SummaryTile(s: s, label: 'Days', value: vals.length.toString(), color: AppColors.labelDim),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final double s;
  final String label;
  final String value;
  final Color color;
  const _SummaryTile({required this.s, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.inter(fontSize: 15 * s, fontWeight: FontWeight.w700, color: color)),
        Text(label,  style: GoogleFonts.inter(fontSize: 10 * s, color: AppColors.labelDim)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bar chart painter
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryBarPainter extends CustomPainter {
  final double s;
  final List<({DateTime date, double? raw})> entries;
  final VitalType vitalType;
  final bool weekly;

  const _HistoryBarPainter({
    required this.s,
    required this.entries,
    required this.vitalType,
    required this.weekly,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const yLW = 32.0;
    const xLH = 20.0;
    final yLabelW = yLW * s;
    final xLabelH = xLH * s;
    final chartW  = size.width  - yLabelW;
    final chartH  = size.height - xLabelH;
    final tp = TextPainter(textDirection: TextDirection.ltr);

    // grid lines
    for (int i = 0; i <= 4; i++) {
      final y = chartH * (i / 4);
      canvas.drawLine(
        Offset(yLabelW, y),
        Offset(yLabelW + chartW, y),
        Paint()..color = Colors.white.withAlpha(25)..strokeWidth = 0.5 * s,
      );
    }

    final n = entries.length;
    if (n == 0) return;

    final slotW = chartW / n;
    final barW  = (slotW * 0.6).clamp(4.0 * s, 18.0 * s);

    for (int i = 0; i < n; i++) {
      final raw = entries[i].raw;
      if (raw == null) continue;
      final norm = vitalType.normalise(raw);
      final h    = chartH * norm;
      final x    = yLabelW + i * slotW + (slotW - barW) / 2;
      final top  = chartH - h;
      final col  = vitalType.barColor(raw);

      final barRect = Rect.fromLTWH(x, top, barW, h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, Radius.circular(barW / 2)),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [col.withAlpha(160), col],
          ).createShader(barRect),
      );

      // x-axis label: day abbreviation for weekly, date for monthly
      final date = entries[i].date;
      final label = weekly
          ? _dayAbbr(date.weekday)
          : '${date.day}';
      tp.text = TextSpan(
        text: label,
        style: TextStyle(fontSize: 8 * s, color: Colors.white.withAlpha(90)),
      );
      tp.layout();
      tp.paint(canvas, Offset(x + (barW - tp.width) / 2, chartH + 4 * s));
    }

    // base line
    canvas.drawLine(
      Offset(yLabelW, chartH),
      Offset(yLabelW + chartW, chartH),
      Paint()..color = Colors.white.withAlpha(50)..strokeWidth = 0.8 * s,
    );
  }

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static String _dayAbbr(int weekday) => _days[(weekday - 1).clamp(0, 6)];

  @override
  bool shouldRepaint(_HistoryBarPainter old) =>
      old.entries != entries || old.vitalType != old.vitalType;
}
