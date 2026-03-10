import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  static const Color _panel = Color(0xFF3F352F);
  static const Color _panelBorder = Color(0xFFE0A10A);
  static const Color _gold = Color(0xFFE0A10A);
  static const Color _textDim = Color(0xFF9F958C);

  _MapTab _selectedTab = _MapTab.info;

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF2E251E),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20 * s),
                child: Image.asset(
                  'assets/challenge/challenge_map.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 14 * s,
              left: 8 * s,
              right: 8 * s,
              child: _buildTopBar(s),
            ),
            Positioned(
              top: 248 * s,
              right: 10 * s,
              child: _buildMapControls(s),
            ),
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
            gradient: const LinearGradient(
              colors: [Color(0xFF00F0FF), Color(0xFFB161FF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          padding: const EdgeInsets.all(1.2),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
            decoration: BoxDecoration(
              color: const Color(0xFF8A7D70).withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(30 * s),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.chevron_left,
                    color: const Color(0xFF00F0FF),
                    size: 28 * s,
                  ),
                ),
                const Spacer(),
                Image.asset(
                  'assets/24 logo.png',
                  height: 30 * s,
                  fit: BoxFit.contain,
                ),
                const Spacer(),
                Container(
                  width: 30 * s,
                  height: 30 * s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/fonts/male.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 4 * s),
        Text(
          'HI, USER',
          style: GoogleFonts.inter(
            color: const Color(0xFFB6AFA8),
            fontSize: 10 * s,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMapControls(double s) {
    return Column(
      children: [
        _controlButton(s, Icons.add),
        SizedBox(height: 6 * s),
        _controlButton(s, Icons.remove),
        SizedBox(height: 6 * s),
        _controlButton(s, Icons.my_location),
        SizedBox(height: 6 * s),
        _controlButton(s, Icons.layers_outlined),
      ],
    );
  }

  Widget _controlButton(double s, IconData icon) {
    return Container(
      width: 34 * s,
      height: 34 * s,
      decoration: BoxDecoration(
        color: const Color(0xFF3A2820).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 20 * s, color: Colors.white),
    );
  }

  Widget _buildBottomPanel(double s) {
    return Container(
      decoration: BoxDecoration(
        color: _panel.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: _panelBorder, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8 * s, 6 * s, 8 * s, 8 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTabs(s),
            SizedBox(height: 8 * s),
            _buildTabContent(s),
            SizedBox(height: 8 * s),
            _buildLiveChatHeader(s),
            SizedBox(height: 6 * s),
            _buildMessages(s),
            SizedBox(height: 8 * s),
            _buildInput(s),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(double s) {
    Widget tab(String label, _MapTab tab) {
      final active = tab == _selectedTab;
      return GestureDetector(
        onTap: () => setState(() => _selectedTab = tab),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8 * s),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12 * s,
              fontWeight: FontWeight.w600,
              color: active ? _gold : _textDim,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 28 * s,
      decoration: BoxDecoration(
        color: const Color(0xFF2F2722).withValues(alpha: 0.9),
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
            Expanded(child: _metricCard(s, 'Distance', '8.4', 'km')),
            SizedBox(width: 8 * s),
            Expanded(child: _metricCard(s, 'AVG Pace', '6:45', '/km')),
            SizedBox(width: 8 * s),
            Expanded(child: _metricCard(s, 'ELEV', '+210', 'm')),
          ],
        ),
        SizedBox(height: 8 * s),
        Row(
          children: [
            Expanded(child: _actionPill(s, 'mark Point')),
            SizedBox(width: 8 * s),
            Expanded(child: _actionPill(s, 'Share Live')),
          ],
        ),
      ],
    );
  }

  Widget _metricCard(double s, String title, String value, String unit) {
    return Container(
      padding: EdgeInsets.fromLTRB(8 * s, 6 * s, 8 * s, 7 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2420).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14 * s),
        border: Border.all(color: _panelBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 9 * s,
              fontWeight: FontWeight.w500,
              color: _gold,
            ),
          ),
          SizedBox(height: 4 * s),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: GoogleFonts.inter(
                    fontSize: 27 / 2 * s,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: GoogleFonts.inter(
                    fontSize: 9 * s,
                    fontWeight: FontWeight.w500,
                    color: _gold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionPill(double s, String label) {
    return Container(
      height: 24 * s,
      decoration: BoxDecoration(
        color: const Color(0xFF27211D).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _panelBorder, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10 * s,
          fontWeight: FontWeight.w500,
          color: _gold,
        ),
      ),
    );
  }

  Widget _buildToolsContent(double s) {
    Widget tool(Color color, IconData icon, String label) {
      return Expanded(
        child: Column(
          children: [
            Container(
              width: 38 * s,
              height: 38 * s,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2420).withValues(alpha: 0.9),
                shape: BoxShape.circle,
                border: Border.all(color: _panelBorder, width: 1),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 20 * s),
            ),
            SizedBox(height: 4 * s),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10 * s,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        tool(const Color(0xFF10DF7F), Icons.circle_outlined, 'Green'),
        tool(const Color(0xFFFF1E1E), Icons.circle_outlined, 'Red'),
        tool(const Color(0xFFD5D5D5), Icons.straighten, 'Ruler'),
        tool(const Color(0xFFD9B182), Icons.location_on_outlined, 'Point'),
        tool(_gold, Icons.route, 'All'),
      ],
    );
  }

  Widget _buildGroupContent(double s) {
    Widget stat(String title, String value, IconData icon) {
      return Expanded(
        child: Container(
          height: 40 * s,
          padding: EdgeInsets.symmetric(horizontal: 9 * s),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2420).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(14 * s),
            border: Border.all(color: _panelBorder, width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70, size: 16 * s),
              SizedBox(width: 6 * s),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 8 * s,
                      fontWeight: FontWeight.w500,
                      color: _textDim,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 15 / 2 * s * 2,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget memberRow(String name, String subtitle) {
      return Container(
        margin: EdgeInsets.only(top: 6 * s),
        padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2420).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _panelBorder, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 24 * s,
              height: 24 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: AssetImage('assets/fonts/male.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            SizedBox(width: 7 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 11 * s,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 8 * s, color: _textDim),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            stat('Members', '4/4', Icons.group),
            SizedBox(width: 8 * s),
            stat('Alerts', '1 Issue', Icons.warning_rounded),
          ],
        ),
        memberRow('Khalfan', 'Stopped 2m  Soft sand'),
        memberRow('You', 'Moving, Leader'),
        memberRow('Mohammed', 'Moving, +150m'),
        SizedBox(height: 6 * s),
        Text(
          'View All Members',
          style: GoogleFonts.inter(
            fontSize: 11 * s,
            fontWeight: FontWeight.w600,
            color: _gold,
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyContent(double s) {
    Widget option(IconData icon, String label) {
      return Expanded(
        child: Container(
          height: 36 * s,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2420).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(14 * s),
            border: Border.all(color: _panelBorder, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white70, size: 16 * s),
              SizedBox(width: 6 * s),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10 * s,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 8 * s),
          decoration: BoxDecoration(
            color: const Color(0xFFD70F0F),
            borderRadius: BorderRadius.circular(14 * s),
          ),
          child: Row(
            children: [
              Text(
                'SOS',
                style: GoogleFonts.inter(
                  fontSize: 34 / 2 * s * 2,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EMERGENCY SOS',
                      style: GoogleFonts.inter(
                        fontSize: 13 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'BROADCAST LOCATION TO GROUP',
                      style: GoogleFonts.inter(
                        fontSize: 8 * s,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8 * s),
        Row(
          children: [
            option(Icons.free_breakfast_outlined, 'Rest Stop'),
            SizedBox(width: 8 * s),
            option(Icons.group, 'Meeting point'),
          ],
        ),
        SizedBox(height: 8 * s),
        Row(
          children: [
            option(Icons.traffic, 'Road'),
            SizedBox(width: 8 * s),
            option(Icons.landscape, 'Steep Terrain'),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveChatHeader(double s) {
    return Row(
      children: [
        Container(
          width: 5 * s,
          height: 5 * s,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF39F289),
          ),
        ),
        SizedBox(width: 6 * s),
        Text(
          'Live Chat',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 12 * s,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        _chatAvatars(s),
      ],
    );
  }

  Widget _chatAvatars(double s) {
    Widget avatar(double left, {String? text}) {
      return Positioned(
        left: left,
        child: Container(
          width: 30 * s,
          height: 30 * s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD8D8D8),
            border: Border.all(color: const Color(0xFF1E1813), width: 1.5),
            image: text == null
                ? const DecorationImage(
                    image: AssetImage('assets/fonts/male.png'),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: text == null
              ? null
              : Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
        ),
      );
    }

    return SizedBox(
      width: 120 * s,
      height: 30 * s,
      child: Stack(
        children: [
          avatar(0),
          avatar(22 * s),
          avatar(44 * s),
          avatar(66 * s),
          avatar(88 * s, text: '+4'),
        ],
      ),
    );
  }

  Widget _buildMessages(double s) {
    Widget bubble({
      required String name,
      required String time,
      required String text,
    }) {
      return Padding(
        padding: EdgeInsets.only(bottom: 8 * s),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26 * s,
              height: 26 * s,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/fonts/male.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            SizedBox(width: 6 * s),
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(8 * s, 5 * s, 8 * s, 6 * s),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2723).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(8 * s),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.inter(
                            fontSize: 8 * s,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8 * s),
                        Text(
                          time,
                          style: GoogleFonts.inter(
                            fontSize: 7 * s,
                            color: _textDim,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      text,
                      style: GoogleFonts.inter(
                        fontSize: 8 * s,
                        height: 1.2,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 100 * s),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            bubble(
              name: 'Khalfan',
              time: '10:42',
              text: 'Heading towards the ridge now. visibility is good.',
            ),
            bubble(
              name: 'Yahya',
              time: '10:47',
              text: 'Watch out for soft sand near the ridge.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(double s) {
    return Row(
      children: [
        Container(
          width: 24 * s,
          height: 24 * s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _panelBorder, width: 1),
          ),
          child: Icon(Icons.settings, size: 13 * s, color: Colors.white60),
        ),
        SizedBox(width: 6 * s),
        Expanded(
          child: Container(
            height: 31 * s,
            decoration: BoxDecoration(
              color: const Color(0xFF29231E).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _panelBorder, width: 1),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12 * s),
            alignment: Alignment.centerLeft,
            child: Text(
              'Type to group...',
              style: GoogleFonts.inter(fontSize: 10 * s, color: _textDim),
            ),
          ),
        ),
        SizedBox(width: 6 * s),
        Container(
          width: 30 * s,
          height: 30 * s,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE0A10A),
          ),
          child: Icon(Icons.mic, size: 16 * s, color: Colors.black),
        ),
      ],
    );
  }
}
