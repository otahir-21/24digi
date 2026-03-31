import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import 'bracelet_scaffold.dart';
import 'activities_info_screen.dart';

import '../../bracelet/bracelet_channel.dart';
import '../../bracelet/activity_storage.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  ActivitiesScreen
// ─────────────────────────────────────────────────────────────────────────────
class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key, this.channel, this.liveData});
  final BraceletChannel? channel;
  /// Optional live data from dashboard (type 24). Not used for "in progress" — only live workout/session (e.g. type 30) should show in progress.
  final Map<String, dynamic>? liveData;
  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  String _search = '';
  BraceletChannel? get _channel => widget.channel;

  @override
  void initState() {
    super.initState();
    _channel?.requestActivityModeData();
  }

  static const _allActivities = [
    _ActivityDef('Walking', Icons.directions_walk_rounded, Color(0xFF607D8B)),
    _ActivityDef('Running', Icons.directions_run_rounded, Color(0xFFE65100)),
    _ActivityDef('Workout', Icons.fitness_center_rounded, Color(0xFF795548)),
    _ActivityDef('Football', Icons.sports_soccer_rounded, Color(0xFF00838F)),
    _ActivityDef(
      'Table Tennis',
      Icons.sports_tennis_rounded,
      Color(0xFF1565C0),
    ),
    _ActivityDef(
      'Basketball',
      Icons.sports_basketball_rounded,
      Color(0xFFF57F17),
    ),
    _ActivityDef('Badminton', Icons.sports_rounded, Color(0xFFAD1457)),
    _ActivityDef('Yoga', Icons.self_improvement_rounded, Color(0xFF2E7D32)),
    _ActivityDef('Hiking', Icons.terrain_rounded, Color(0xFF6D4C41)),
    _ActivityDef('Cricket', Icons.sports_cricket_rounded, Color(0xFF1B5E20)),
    _ActivityDef('Cycling', Icons.directions_bike_rounded, Color(0xFF00695C)),
    _ActivityDef('Dance', Icons.music_note_rounded, Color(0xFFAD14C8)),
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    final filtered = _allActivities
        .where((a) => a.label.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return BraceletScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Hi, User ──────────────────────────────────────────
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
          SizedBox(height: 12 * s),
          // ── Search bar ────────────────────────────────────────
          _SearchBar(s: s, onChanged: (v) => setState(() => _search = v)),
          SizedBox(height: 14 * s),
          // ── Two-column body ───────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: All Activities
              Expanded(
                flex: 48,
                child: _AllActivitiesPanel(
                  s: s,
                  activities: filtered,
                  channel: _channel,
                  dashboardLiveData: widget.liveData,
                ),
              ),
              SizedBox(width: 8 * s),
              // Right: Today's Activities
              Expanded(
                flex: 52,
                child: _TodayPanel(s: s, channel: _channel, liveData: widget.liveData),
              ),
            ],
          ),
          SizedBox(height: 24 * s),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Data classes
// ─────────────────────────────────────────────────────────────────────────────
class _ActivityDef {
  final String label;
  final IconData icon;
  final Color color;
  const _ActivityDef(this.label, this.icon, this.color);
}

class _TodayDef {
  final String label;
  final IconData icon;
  final Color color;
  final String start;
  final String finish;
  final double progress;
  const _TodayDef(
    this.label,
    this.icon,
    this.color,
    this.start,
    this.finish,
    this.progress,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Search bar
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final double s;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.s, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SmoothGradientBorder(radius: 10 * s),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10 * s),
        child: ColoredBox(
          color: const Color(0xFF060E16),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 4 * s),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: AppColors.labelDim,
                  size: 18 * s,
                ),
                SizedBox(width: 8 * s),
                Expanded(
                  child: TextField(
                    onChanged: onChanged,
                    style: GoogleFonts.inter(
                      fontSize: 12 * s,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search activities ...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 12 * s,
                        color: AppColors.labelDim,
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 6 * s),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
//  All Activities panel (left column, dashed border)
// ─────────────────────────────────────────────────────────────────────────────
class _AllActivitiesPanel extends StatelessWidget {
  final double s;
  final List<_ActivityDef> activities;
  final BraceletChannel? channel;
  final Map<String, dynamic>? dashboardLiveData;
  const _AllActivitiesPanel({
    required this.s,
    required this.activities,
    this.channel,
    this.dashboardLiveData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Activities',
          style: GoogleFonts.inter(
            fontSize: 15 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12 * s),
        GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10 * s,
            mainAxisSpacing: 16 * s,
            childAspectRatio: 0.82,
          ),
          itemCount: activities.length,
          itemBuilder: (_, i) => _ActivityTile(
                s: s,
                def: activities[i],
                channel: channel,
                dashboardLiveData: dashboardLiveData,
              ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Single activity tile (circle icon + label)
// ─────────────────────────────────────────────────────────────────────────────
class _ActivityTile extends StatelessWidget {
  final double s;
  final _ActivityDef def;
  final BraceletChannel? channel;
  final Map<String, dynamic>? dashboardLiveData;
  const _ActivityTile({
    required this.s,
    required this.def,
    this.channel,
    this.dashboardLiveData,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ActivitiesInfoScreen(
              channel: channel,
              activityLabel: def.label,
              dashboardLiveData: dashboardLiveData,
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58 * s,
            height: 58 * s,
            decoration: BoxDecoration(shape: BoxShape.circle, color: def.color),
            child: Center(
              child: def.label == 'Badminton'
                  ? SizedBox(
                      width: 32 * s,
                      height: 32 * s,
                      child: CustomPaint(painter: _BadmintonPainter()),
                    )
                  : Icon(def.icon, color: Colors.white, size: 30 * s),
            ),
          ),
          SizedBox(height: 8 * s),
          Text(
            def.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11 * s,
              color: Colors.white.withAlpha(220),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Today's Activities panel (right column) – real data from ActivityStorage
// ─────────────────────────────────────────────────────────────────────────────
class _TodayPanel extends StatelessWidget {
  final double s;
  final BraceletChannel? channel;
  final Map<String, dynamic>? liveData;
  const _TodayPanel({required this.s, this.channel, this.liveData});

  static _TodayDef _sessionToTodayDef(Map<String, dynamic> s) {
    final label = s['sportName'] as String? ?? 'Activity';
    final pair = _iconAndColorForSport(label);
    final dateStr = s['date'] as String? ?? '';
    final activeMin = (s['activeMinutes'] is int)
        ? s['activeMinutes'] as int
        : (s['activeMinutes'] is num)
            ? (s['activeMinutes'] as num).toInt()
            : 0;
    String startStr = '—';
    String finishStr = '—';
    if (dateStr.length >= 16) {
      final timePart = dateStr.substring(11, 16);
      startStr = _formatTimeString(timePart);
      if (activeMin > 0) {
        final parts = timePart.split(':');
        final h = int.tryParse(parts[0]) ?? 0;
        final m = (int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0) + activeMin;
        final endH = h + m ~/ 60;
        final endM = m % 60;
        finishStr = _formatTimeString('${endH.clamp(0, 23)}:${endM.toString().padLeft(2, '0')}');
      } else {
        finishStr = startStr;
      }
    }
    return _TodayDef(
      label,
      pair.$1,
      pair.$2,
      startStr,
      finishStr,
      1.0,
    );
  }

  static String _formatTimeString(String timePart) {
    final parts = timePart.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final am = h < 12;
    final hour = h <= 12 ? (h == 0 ? 12 : h) : h - 12;
    return '${hour.toString().padLeft(2)}:${m.toString().padLeft(2, '0')} ${am ? 'AM' : 'PM'}';
  }

  static (IconData, Color) _iconAndColorForSport(String name) {
    const map = {
      'Walking': (Icons.directions_walk_rounded, Color(0xFF607D8B)),
      'Run': (Icons.directions_run_rounded, Color(0xFFE65100)),
      'Running': (Icons.directions_run_rounded, Color(0xFFE65100)),
      'Workout': (Icons.fitness_center_rounded, Color(0xFF795548)),
      'Football': (Icons.sports_soccer_rounded, Color(0xFF00838F)),
      'Table Tennis': (Icons.sports_tennis_rounded, Color(0xFF1565C0)),
      'Ping Pong': (Icons.sports_tennis_rounded, Color(0xFF1565C0)),
      'Basketball': (Icons.sports_basketball_rounded, Color(0xFFF57F17)),
      'Badminton': (Icons.sports_rounded, Color(0xFFAD1457)),
      'Yoga': (Icons.self_improvement_rounded, Color(0xFF2E7D32)),
      'Hiking': (Icons.terrain_rounded, Color(0xFF6D4C41)),
      'Cricket': (Icons.sports_cricket_rounded, Color(0xFF1B5E20)),
      'Cycling': (Icons.directions_bike_rounded, Color(0xFF00695C)),
      'Dance': (Icons.music_note_rounded, Color(0xFFAD14C8)),
      'Breath': (Icons.air_rounded, Color(0xFF4FC3F7)),
      'Rope Jump': (Icons.fitness_center_rounded, Color(0xFFFF7043)),
      'Sit Ups': (Icons.self_improvement_rounded, Color(0xFF66BB6A)),
      'Volleyball': (Icons.sports_volleyball_rounded, Color(0xFFEC407A)),
      'Aerobics': (Icons.fitness_center_rounded, Color(0xFFAB47BC)),
    };
    return map[name] ?? (Icons.directions_run_rounded, Color(0xFF607D8B));
  }

  /// Do NOT use type 24 (daily totals / steps / exerciseMinutes) to show "In progress".
  /// Only a live workout/session (e.g. active type 30 or device workout state) should show in progress.
  /// Until we have that signal, return null so the list shows only completed sessions from ActivityStorage (type 30).
  static _TodayDef? _currentActivityFromLiveData(Map<String, dynamic>? liveData) {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ActivityStorage.versionNotifier,
      builder: (context, _, __) {
        final sessions = ActivityStorage.todaySessions;
        List<_TodayDef> today = sessions.map(_sessionToTodayDef).toList();
        final current = _currentActivityFromLiveData(liveData);
        if (current != null) today = [current, ...today];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Todays Activities',
              style: GoogleFonts.inter(
                fontSize: 15 * s,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24 * s),
            Stack(
              children: [
                Positioned(
                  left: 14 * s,
                  top: 20 * s,
                  bottom: 20 * s,
                  child: Container(
                    width: 1.5 * s,
                    color: AppColors.cyan.withAlpha(100),
                  ),
                ),
                Column(
                  children: today.isEmpty
                      ? [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 24 * s),
                            child: Center(
                              child: Text(
                                'No activities today',
                                style: GoogleFonts.inter(
                                  fontSize: 13 * s,
                                  color: AppColors.labelDim,
                                ),
                              ),
                            ),
                          ),
                        ]
                      : List.generate(today.length, (i) {
                          final t = today[i];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 14 * s),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 28 * s,
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: 8 * s,
                                    height: 8 * s,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.cyan,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4 * s),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ActivitiesInfoScreen(
                                          channel: channel,
                                          activityLabel: t.label,
                                          dashboardLiveData: liveData,
                                        ),
                                      ),
                                    ),
                                    child: _TodayCard(s: s, def: t),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                ),
              ],
            ),
            SizedBox(height: 12 * s),
            Row(
              children: [
                Expanded(
                  child: _PillButton(
                    s: s,
                    label: 'View History',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ActivitiesInfoScreen(
                          channel: channel,
                          activityLabel: null,
                          dashboardLiveData: liveData,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8 * s),
                Expanded(
                  child: _PillButton(s: s, label: 'Daily Insights', onTap: () {}),
                ),
              ],
            ),
            SizedBox(height: 18 * s),
            _StatsSummary(s: s, liveData: liveData),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Today activity card
// ─────────────────────────────────────────────────────────────────────────────
class _TodayCard extends StatelessWidget {
  final double s;
  final _TodayDef def;
  const _TodayCard({required this.s, required this.def});

  @override
  Widget build(BuildContext context) {
    final progress = def.progress.clamp(0.0, 1.0);
    return CustomPaint(
      painter: SmoothGradientBorder(radius: 14 * s),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14 * s),
        child: ColoredBox(
          color: const Color(0xFF060E16),
          child: Padding(
            padding: EdgeInsets.all(10 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon + Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 32 * s,
                      height: 32 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: def.color.withAlpha(40),
                        border: Border.all(
                          color: def.color.withAlpha(180),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(def.icon, color: def.color, size: 16 * s),
                      ),
                    ),
                    Text(
                      def.label,
                      style: GoogleFonts.inter(
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10 * s),
                // Time rows
                _TimeRow(s: s, label: 'Start', time: def.start),
                SizedBox(height: 5 * s),
                _TimeRow(s: s, label: 'Finsh', time: def.finish),
                SizedBox(height: 10 * s),
                // Thick Progress bar
                Container(
                  height: 12 * s,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6 * s),
                    color: Colors.white.withAlpha(20),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6 * s),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF43C6E4),
                            Color(0xFF2E7D32),
                          ], // Match cyan to green/teal gradient in design
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
    );
  }
}

class _TimeRow extends StatelessWidget {
  final double s;
  final String label;
  final String time;
  const _TimeRow({required this.s, required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10 * s,
            color: AppColors.labelDim,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          time,
          style: GoogleFonts.inter(
            fontSize: 10 * s,
            color: Colors.white.withAlpha(220),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Pill buttons
// ─────────────────────────────────────────────────────────────────────────────
class _PillButton extends StatelessWidget {
  final double s;
  final String label;
  final VoidCallback onTap;
  const _PillButton({
    required this.s,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: 8 * s),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8 * s),
            color: const Color(0xFF060E16),
          ),
          padding: EdgeInsets.symmetric(vertical: 10 * s),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10 * s,
                fontWeight: FontWeight.w500,
                color: Colors.white.withAlpha(180),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Stats summary card – from ActivityStorage, or liveData (type 24) when no sessions
// ─────────────────────────────────────────────────────────────────────────────
class _StatsSummary extends StatelessWidget {
  final double s;
  final Map<String, dynamic>? liveData;
  const _StatsSummary({required this.s, this.liveData});

  @override
  Widget build(BuildContext context) {
    double calories = ActivityStorage.totalCalories;
    int minutes = ActivityStorage.totalActiveMinutes;
    if (calories <= 0 && liveData != null) {
      final c = liveData!['calories'] ?? liveData!['Calories'];
      if (c is num) calories = c.toDouble();
    }
    if (minutes <= 0 && liveData != null) {
      final m = liveData!['exerciseMinutes'] ?? liveData!['ExerciseMinutes'] ?? liveData!['activeMinutes'] ?? liveData!['ActiveMinutes'];
      if (m is int) minutes = m;
      if (m is num) minutes = m.toInt();
    }
    final caloriesStr = calories > 0 ? '${calories.round()}' : 'nil';
    final timeStr = minutes > 0 ? '${minutes} min' : 'nil';
    return CustomPaint(
      painter: SmoothGradientBorder(radius: 12 * s),
      child: Container(
        padding: EdgeInsets.all(16 * s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12 * s),
          color: const Color(0xFF060E16),
        ),
        child: Column(
          children: [
            _StatLine(s: s, label: 'Total Calories:', value: caloriesStr),
            SizedBox(height: 12 * s),
            _StatLine(s: s, label: 'Active Time:', value: timeStr),
          ],
        ),
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  final double s;
  final String label;
  final String value;
  const _StatLine({required this.s, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12 * s,
            color: AppColors.labelDim,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12 * s,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Badminton racket + shuttlecock painter
// ─────────────────────────────────────────────────────────────────────────────
class _BadmintonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final stroke = Paint()
      ..color = Colors.white
      ..strokeWidth = w * 0.07
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // ── Racket – drawn rotated 45° around the head centre ──────────────
    final headCx = w * 0.36;
    final headCy = h * 0.36;

    canvas.save();
    canvas.translate(headCx, headCy);
    canvas.rotate(-math.pi / 4); // tilt 45° counter-clockwise

    // Oval head (centred at 0,0 after translate)
    final rx = w * 0.22;
    final ry = h * 0.27;
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
      stroke,
    );

    // Strings – 3 vertical lines
    final sStroke = Paint()
      ..color = Colors.white.withAlpha(180)
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;
    for (int i = -1; i <= 1; i++) {
      final x = rx * 0.5 * i;
      final yTop =
          -math.sqrt(math.max(0, ry * ry * (1 - (x * x) / (rx * rx)))) +
          h * 0.04;
      final yBot =
          math.sqrt(math.max(0, ry * ry * (1 - (x * x) / (rx * rx)))) -
          h * 0.04;
      canvas.drawLine(Offset(x, yTop), Offset(x, yBot), sStroke);
    }
    // Strings – 3 horizontal lines
    for (int i = -1; i <= 1; i++) {
      final y = ry * 0.45 * i;
      final xLeft =
          -math.sqrt(math.max(0, rx * rx * (1 - (y * y) / (ry * ry)))) +
          w * 0.03;
      final xRight =
          math.sqrt(math.max(0, rx * rx * (1 - (y * y) / (ry * ry)))) -
          w * 0.03;
      canvas.drawLine(Offset(xLeft, y), Offset(xRight, y), sStroke);
    }

    // Handle – from bottom of oval downward
    canvas.drawLine(Offset(0, ry), Offset(0, ry + h * 0.42), stroke);

    // Grip wrap (3 short cross-lines on handle)
    final gripStroke = Paint()
      ..color = Colors.white.withAlpha(140)
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round;
    for (int i = 1; i <= 3; i++) {
      final gy = ry + h * 0.12 * i;
      canvas.drawLine(Offset(-w * 0.06, gy), Offset(w * 0.06, gy), gripStroke);
    }

    canvas.restore();

    // ── Shuttlecock – top-right area ────────────────────────────────────
    // Cork (filled circle)
    final ck = Offset(w * 0.82, h * 0.14);
    canvas.drawCircle(ck, w * 0.085, fill);

    // Feathers (small fan of 4 lines going up-left from cork)
    final fStroke = Paint()
      ..color = Colors.white
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;

    const featherAngles = [-2.4, -1.9, -1.4, -0.95];
    for (final a in featherAngles) {
      canvas.drawLine(
        ck,
        Offset(ck.dx + math.cos(a) * w * 0.20, ck.dy + math.sin(a) * h * 0.22),
        fStroke,
      );
    }

    // Feather crown arc connecting the feather tips
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(ck.dx - w * 0.09, ck.dy - h * 0.20),
        width: w * 0.30,
        height: h * 0.18,
      ),
      math.pi * 0.55,
      math.pi * 0.85,
      false,
      Paint()
        ..color = Colors.white
        ..strokeWidth = w * 0.05
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_BadmintonPainter old) => false;
}
