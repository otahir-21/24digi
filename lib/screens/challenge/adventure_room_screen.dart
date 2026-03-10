import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'adventure_invite_screen.dart';
import '../../core/app_constants.dart';

enum _MapTab { info, tools, group, safety }

class AdventureRoomScreen extends StatefulWidget {
  const AdventureRoomScreen({
    super.key,
    this.roomName = 'Adventure Map',
    this.isLocked = false,
  });

  final String roomName;
  final bool isLocked;

  @override
  State<AdventureRoomScreen> createState() => _AdventureRoomScreenState();
}

class _AdventureRoomScreenState extends State<AdventureRoomScreen> {
  static const Color _panel = Color(0xFF1E1813);
  static const Color _panelBorder = Color(0xFFE0A10A);
  static const Color _gold = Color(0xFFE0A10A);
  static const Color _textDim = Color(0xFF9F958C);

  _MapTab _selectedTab = _MapTab.info;

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1813),
      body: SafeArea(
        child: Stack(
          children: [
            // Map Base
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20 * s),
                child: Image.asset(
                  'assets/challenge/challenge_map.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Map Route Overlay (Simplified representation)
            Positioned.fill(
              child: CustomPaint(
                painter: _RoutePainter(s: s),
              ),
            ),
            // Top Bar
            Positioned(
              top: 14 * s,
              left: 8 * s,
              right: 8 * s,
              child: _buildTopBar(s),
            ),
            // Map Controls
            Positioned(
              top: 248 * s,
              right: 10 * s,
              child: _buildMapControls(s),
            ),
            // Bottom Panel
            Positioned(
              left: 8 * s,
              right: 8 * s,
              bottom: 8 * s,
              child: _buildBottomPanel(s),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(double s) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30 * s),
            border: Border.all(color: Colors.white24, width: 1),
            color: const Color(0xFF1E1813).withValues(alpha: 0.6),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 28 * s,
                ),
              ),
              const Spacer(),
              Image.asset(
                'assets/24 logo.png',
                height: 30 * s,
                fit: BoxFit.contain,
                color: Colors.white,
              ),
              const Spacer(),
              _Avatar(s: s),
            ],
          ),
        ),
        SizedBox(height: 6 * s),
        Text(
          'HI, USER',
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 10 * s,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildMapControls(double s) {
    return Column(
      children: [
        _controlButton(s, Icons.add),
        SizedBox(height: 8 * s),
        _controlButton(s, Icons.remove),
        SizedBox(height: 8 * s),
        _controlButton(s, Icons.straighten_outlined), // Ruler
        SizedBox(height: 8 * s),
        _controlButton(s, Icons.explore_outlined), // Compass
      ],
    );
  }

  Widget _controlButton(double s, IconData icon) {
    return Container(
      width: 36 * s,
      height: 36 * s,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1813).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10 * s),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 20 * s, color: Colors.white),
    );
  }

  Widget _buildBottomPanel(double s) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1813).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: _panelBorder.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(8 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTabs(s),
            SizedBox(height: 12 * s),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _buildTabContent(s),
            ),
            SizedBox(height: 16 * s),
            _buildLiveChatSection(s),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(double s) {
    Widget tab(String label, _MapTab tab) {
      final active = tab == _selectedTab;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _selectedTab = tab),
          child: Container(
            height: 28 * s,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? _gold : Colors.transparent,
              borderRadius: BorderRadius.circular(8 * s),
            ),
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11 * s,
                fontWeight: FontWeight.w700,
                color: active ? Colors.black : _textDim,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 32 * s,
      padding: EdgeInsets.all(2 * s),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10 * s),
      ),
      child: Row(
        children: [
          tab('INFO', _MapTab.info),
          tab('TOOLS', _MapTab.tools),
          tab('GROUP', _MapTab.group),
          tab('SAFETY', _MapTab.safety),
        ],
      ),
    );
  }

  Widget _buildTabContent(double s) {
    switch (_selectedTab) {
      case _MapTab.info:
        return _buildInfoContent(s);
      case _MapTab.tools:
        return _buildToolsContent(s);
      case _MapTab.group:
        return _buildGroupContent(s);
      case _MapTab.safety:
        return _buildSafetyContent(s);
    }
  }

  Widget _buildInfoContent(double s) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _metricCard(s, 'DISTANCE', '8.4', 'km')),
            SizedBox(width: 8 * s),
            Expanded(child: _metricCard(s, 'WEATHER', '64:45', 'km/h')),
            SizedBox(width: 8 * s),
            Expanded(child: _metricCard(s, 'ELEV', '+210', 'm')),
          ],
        ),
        SizedBox(height: 10 * s),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdventureInviteScreen(roomName: widget.roomName),
                    ),
                  );
                },
                child: _actionPill(s, 'Invite Friends'),
              ),
            ),
            SizedBox(width: 8 * s),
            Expanded(child: _actionPill(s, 'Share Live')),
          ],
        ),
      ],
    );
  }

  Widget _metricCard(double s, String title, String value, String unit) {
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: _panelBorder.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 8 * s,
              fontWeight: FontWeight.w700,
              color: _gold,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4 * s),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 2 * s),
              Text(
                unit,
                style: GoogleFonts.inter(
                  fontSize: 8 * s,
                  fontWeight: FontWeight.w500,
                  color: _gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionPill(double s, String label) {
    return Container(
      height: 28 * s,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _panelBorder.withValues(alpha: 0.5), width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10 * s,
          fontWeight: FontWeight.w600,
          color: _gold,
        ),
      ),
    );
  }

  Widget _buildToolsContent(double s) {
    Widget toolIcon(Color color, IconData icon, String label) {
      return Column(
        children: [
          Container(
            width: 44 * s,
            height: 44 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black26,
              border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
            ),
            child: Icon(icon, color: color, size: 20 * s),
          ),
          SizedBox(height: 4 * s),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9 * s,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        toolIcon(const Color(0xFF00FF88), Icons.radio_button_checked, 'Green'),
        toolIcon(const Color(0xFFFF3B30), Icons.radio_button_checked, 'Red'),
        toolIcon(Colors.white70, Icons.straighten, 'Ruler'),
        toolIcon(const Color(0xFF00C8FF), Icons.location_on, 'Point'),
        toolIcon(_gold, Icons.all_out, 'All'),
      ],
    );
  }

  Widget _buildGroupContent(double s) {
    return Column(
      children: [
        Row(
          children: [
            _GroupStat(s: s, icon: Icons.group, label: 'Members', value: '4/4'),
            SizedBox(width: 10 * s),
            _GroupStat(s: s, icon: Icons.warning_amber_rounded, label: 'Alerts', value: '1 Issue', isAlert: true),
          ],
        ),
        SizedBox(height: 10 * s),
        _MemberCard(s: s, name: 'Khalfan', status: 'Stopped 2s • Soft sand', isStopped: true),
        _MemberCard(s: s, name: 'You', status: 'Moving • Leader'),
        _MemberCard(s: s, name: 'Mohammed', status: 'Moving • +150m'),
        SizedBox(height: 8 * s),
        Text(
          'View All Members',
          style: GoogleFonts.inter(
            fontSize: 11 * s,
            fontWeight: FontWeight.w700,
            color: _gold,
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyContent(double s) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12 * s),
          decoration: BoxDecoration(
            color: const Color(0xFFFF3B30),
            borderRadius: BorderRadius.circular(16 * s),
          ),
          child: Row(
            children: [
              Text(
                'SOS',
                style: GoogleFonts.outfit(
                  fontSize: 28 * s,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EMERGENCY SOS',
                      style: GoogleFonts.inter(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'BROADCAST LOCATION TO GROUP',
                      style: GoogleFonts.inter(
                        fontSize: 9 * s,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12 * s),
        Row(
          children: [
            Expanded(child: _SafetyAction(s: s, icon: Icons.coffee, label: 'Rest Stop')),
            SizedBox(width: 10 * s),
            Expanded(child: _SafetyAction(s: s, icon: Icons.flag, label: 'Meeting point')),
          ],
        ),
        SizedBox(height: 10 * s),
        Row(
          children: [
            Expanded(child: _SafetyAction(s: s, icon: Icons.alt_route, label: 'Road')),
            SizedBox(width: 10 * s),
            Expanded(child: _SafetyAction(s: s, icon: Icons.terrain, label: 'Steep Terrain')),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveChatSection(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6 * s,
              height: 6 * s,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF00FF88)),
            ),
            SizedBox(width: 6 * s),
            Text(
              'Live Chat',
              style: GoogleFonts.inter(fontSize: 12 * s, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const Spacer(),
            _AvatarStack(s: s),
          ],
        ),
        SizedBox(height: 12 * s),
        _ChatMessage(s: s, name: 'Khalfan', time: '10:42', text: 'Heading towards the ridge now. visibility is good.'),
        _ChatMessage(s: s, name: 'Yahya', time: '10:47', text: 'Watch out for soft sand near the ridge.'),
        SizedBox(height: 12 * s),
        _ChatInput(s: s, gold: _gold),
      ],
    );
  }
}

class _RoutePainter extends CustomPainter {
  final double s;
  _RoutePainter({required this.s});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3 * s
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.3);
    path.lineTo(size.width * 0.4, size.height * 0.25);
    path.lineTo(size.width * 0.6, size.height * 0.4);
    path.lineTo(size.width * 0.8, size.height * 0.35);

    // Draw dashed line
    final dashPath = Path();
    const dashWidth = 10.0;
    const dashSpace = 5.0;
    var distance = 0.0;
    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GroupStat extends StatelessWidget {
  final double s;
  final IconData icon;
  final String label;
  final String value;
  final bool isAlert;

  const _GroupStat({required this.s, required this.icon, required this.label, required this.value, this.isAlert = false});

  @override
  Widget build(BuildContext context) {
    final color = isAlert ? Colors.redAccent : Colors.white;
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10 * s),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12 * s),
          border: Border.all(color: Colors.white12, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18 * s),
            SizedBox(width: 8 * s),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 8 * s, color: Colors.white60)),
                Text(value, style: GoogleFonts.inter(fontSize: 12 * s, fontWeight: FontWeight.w700, color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final double s;
  final String name;
  final String status;
  final bool isStopped;

  const _MemberCard({required this.s, required this.name, required this.status, this.isStopped = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8 * s),
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: isStopped ? Colors.redAccent.withValues(alpha: 0.5) : Colors.white10, width: 1),
      ),
      child: Row(
        children: [
          _Avatar(s: s, size: 28 * s),
          SizedBox(width: 10 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.inter(fontSize: 12 * s, fontWeight: FontWeight.w700, color: Colors.white)),
                Text(status, style: GoogleFonts.inter(fontSize: 9 * s, color: isStopped ? Colors.redAccent : Colors.white54)),
              ],
            ),
          ),
          if (isStopped) Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 18 * s),
        ],
      ),
    );
  }
}

class _SafetyAction extends StatelessWidget {
  final double s;
  final IconData icon;
  final String label;

  const _SafetyAction({required this.s, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44 * s,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 18 * s),
          SizedBox(width: 8 * s),
          Text(label, style: GoogleFonts.inter(fontSize: 11 * s, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}

class _ChatMessage extends StatelessWidget {
  final double s;
  final String name;
  final String time;
  final String text;

  const _ChatMessage({required this.s, required this.name, required this.time, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(s: s, size: 24 * s),
          SizedBox(width: 8 * s),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10 * s),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12 * s),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name, style: GoogleFonts.inter(fontSize: 9 * s, fontWeight: FontWeight.w700, color: Colors.white)),
                      const Spacer(),
                      Text(time, style: GoogleFonts.inter(fontSize: 8 * s, color: Colors.white38)),
                    ],
                  ),
                  SizedBox(height: 4 * s),
                  Text(text, style: GoogleFonts.inter(fontSize: 10 * s, color: Colors.white70, height: 1.3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final double s;
  final Color gold;

  const _ChatInput({required this.s, required this.gold});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32 * s,
          height: 32 * s,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 1)),
          child: Icon(Icons.settings_outlined, size: 16 * s, color: Colors.white60),
        ),
        SizedBox(width: 8 * s),
        Expanded(
          child: Container(
            height: 36 * s,
            padding: EdgeInsets.symmetric(horizontal: 16 * s),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            alignment: Alignment.centerLeft,
            child: Text('Type to group...', style: GoogleFonts.inter(fontSize: 11 * s, color: Colors.white38)),
          ),
        ),
        SizedBox(width: 8 * s),
        Container(
          width: 36 * s,
          height: 36 * s,
          decoration: BoxDecoration(shape: BoxShape.circle, color: gold),
          child: Icon(Icons.mic, size: 20 * s, color: Colors.black),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final double s;
  final double? size;
  const _Avatar({required this.s, this.size});

  @override
  Widget build(BuildContext context) {
    final sz = size ?? 30 * s;
    return Container(
      width: sz,
      height: sz,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 1),
        image: const DecorationImage(
          image: AssetImage('assets/fonts/male.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  final double s;
  const _AvatarStack({required this.s});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90 * s,
      height: 28 * s,
      child: Stack(
        children: List.generate(4, (i) {
          return Positioned(
            left: i * 18 * s,
            child: i == 3 
              ? Container(
                  width: 28 * s,
                  height: 28 * s,
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1E1813), width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text('+4', style: GoogleFonts.inter(fontSize: 9 * s, fontWeight: FontWeight.w700, color: Colors.white)),
                )
              : Container(
                  width: 28 * s,
                  height: 28 * s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1E1813), width: 2),
                    image: const DecorationImage(image: AssetImage('assets/fonts/male.png'), fit: BoxFit.cover),
                  ),
                ),
          );
        }),
      ),
    );
  }
}

