import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_constants.dart';
import 'adventure_create_room_screen.dart';
import 'adventure_room_screen.dart';
import '../profile/widgets/profile_top_bar.dart';

enum _AdventureTab { discover, myRooms, joined }

enum _AccessState { locked, open }

class _AdventureRoom {
  final String title;
  final String image;
  final _AccessState accessState;
  final int members;
  final int maxMembers;
  final int? entryFee;
  final int? pendingRequests;
  final String actionLabel;
  final Color actionColor;

  const _AdventureRoom({
    required this.title,
    required this.image,
    required this.accessState,
    required this.members,
    required this.maxMembers,
    required this.actionLabel,
    required this.actionColor,
    this.entryFee,
    this.pendingRequests,
  });
}

class AdventureChallengeScreen extends StatefulWidget {
  const AdventureChallengeScreen({super.key});

  @override
  State<AdventureChallengeScreen> createState() =>
      _AdventureChallengeScreenState();
}

class _AdventureChallengeScreenState extends State<AdventureChallengeScreen> {
  static const Color _background = Color(0xFF30261F);
  static const Color _panel = Color(0xFF0C1420);
  static const Color _gold = Color(0xFFE0A10A);
  static const Color _sand = Color(0xFFD9B182);
  static const Color _cyan = Color(0xFF00C8FF);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFFB8B4AE);

  static const List<_AdventureRoom> _discoverRooms = [
    _AdventureRoom(
      title: 'Weekend warriors',
      image: 'assets/challenge/challenge_24_main_1.png',
      accessState: _AccessState.locked,
      members: 12,
      maxMembers: 20,
      entryFee: 500,
      actionLabel: 'Request Access',
      actionColor: _gold,
    ),
    _AdventureRoom(
      title: 'Morning Dash',
      image: 'assets/challenge/challenge_24_main_2.png',
      accessState: _AccessState.open,
      members: 12,
      maxMembers: 20,
      entryFee: 200,
      actionLabel: 'Join Now',
      actionColor: _cyan,
    ),
    _AdventureRoom(
      title: 'mountain cycling',
      image: 'assets/challenge/challenge_24_main_3.png',
      accessState: _AccessState.locked,
      members: 12,
      maxMembers: 20,
      entryFee: 500,
      actionLabel: 'Request Access',
      actionColor: _gold,
    ),
  ];

  static const List<_AdventureRoom> _myRooms = [
    _AdventureRoom(
      title: 'Night Runner',
      image: 'assets/challenge/challenge_24_main_4.png',
      accessState: _AccessState.locked,
      members: 12,
      maxMembers: 20,
      pendingRequests: 3,
      actionLabel: 'Enter',
      actionColor: _sand,
    ),
    _AdventureRoom(
      title: 'Rock climbing Heroes',
      image: 'assets/challenge/challenge_24_main_5.png',
      accessState: _AccessState.open,
      members: 12,
      maxMembers: 20,
      actionLabel: 'Enter',
      actionColor: _sand,
    ),
    _AdventureRoom(
      title: 'Rock climbing Heroes',
      image: 'assets/challenge/challenge_24_main_6.png',
      accessState: _AccessState.open,
      members: 12,
      maxMembers: 20,
      actionLabel: 'Enter',
      actionColor: _sand,
    ),
  ];

  static const List<_AdventureRoom> _joinedRooms = [
    _AdventureRoom(
      title: 'Aqua Explorer',
      image: 'assets/challenge/challenge_24_main_8.png',
      accessState: _AccessState.open,
      members: 12,
      maxMembers: 20,
      actionLabel: 'Enter',
      actionColor: _sand,
    ),
    _AdventureRoom(
      title: 'Swimming Squad',
      image: 'assets/challenge/challenge_24_main_9.png',
      accessState: _AccessState.open,
      members: 12,
      maxMembers: 20,
      actionLabel: 'Enter',
      actionColor: _sand,
    ),
    _AdventureRoom(
      title: 'Rock climbing Heroes',
      image: 'assets/challenge/challenge_24_main_6.png',
      accessState: _AccessState.locked,
      members: 12,
      maxMembers: 20,
      actionLabel: 'Enter',
      actionColor: _sand,
    ),
  ];

  _AdventureTab _selectedTab = _AdventureTab.discover;

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final horizontalPadding = 5.0 * s;

    return Scaffold(
      backgroundColor: _background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF342B24), Color(0xFF251D17)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const ProfileTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 28 * s),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 2 * s),
                        _buildHeader(s),
                        SizedBox(height: 16 * s),
                        _buildTabs(s),
                        SizedBox(height: 20 * s),
                        _buildCurrentTab(s),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double s) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HI, USER',
                style: GoogleFonts.inter(
                  fontSize: 10 * s,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 8 * s),
              Text(
                'Adventure Zone',
                style: GoogleFonts.inter(
                  fontSize: 19 * s,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFC8CCD3),
                  height: 1.05,
                ),
              ),
              SizedBox(height: 5 * s),
              Text(
                'Create your arena',
                style: GoogleFonts.inter(
                  fontSize: 10 * s,
                  fontWeight: FontWeight.w400,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdventureCreateRoomScreen(),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
            decoration: BoxDecoration(
              color: const Color(0xFF111823),
              borderRadius: BorderRadius.circular(30 * s),
              border: Border.all(color: _sand, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 14 * s, color: _sand),
                SizedBox(width: 6 * s),
                Text(
                  'Create',
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w500,
                    color: _sand,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(double s) {
    return Row(
      children: [
        Expanded(child: _buildTab(s, _AdventureTab.discover, 'Discover')),
        SizedBox(width: 6 * s),
        Expanded(child: _buildTab(s, _AdventureTab.myRooms, 'My Rooms')),
        SizedBox(width: 6 * s),
        Expanded(child: _buildTab(s, _AdventureTab.joined, 'Joined')),
      ],
    );
  }

  Widget _buildTab(double s, _AdventureTab tab, String label) {
    final isSelected = _selectedTab == tab;
    final background = switch (tab) {
      _AdventureTab.discover => _gold,
      _AdventureTab.myRooms => _sand,
      _AdventureTab.joined => _gold,
    };

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 30 * s,
        decoration: BoxDecoration(
          color: isSelected ? background : background.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? background : background.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11 * s,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFFE8D7C2),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTab(double s) {
    final rooms = switch (_selectedTab) {
      _AdventureTab.discover => _discoverRooms,
      _AdventureTab.myRooms => _myRooms,
      _AdventureTab.joined => _joinedRooms,
    };

    return Column(
      children: [
        for (final room in rooms) ...[
          _AdventureRoomCard(
            s: s,
            room: room,
            panelColor: _panel,
            sand: _sand,
            gold: _gold,
            cyan: _cyan,
            isDiscover: _selectedTab == _AdventureTab.discover,
            isMyRoom: _selectedTab == _AdventureTab.myRooms,
            onPressed: () => _openAdventureRoom(context, room),
          ),
          SizedBox(height: 18 * s),
        ],
      ],
    );
  }

  void _openAdventureRoom(BuildContext context, _AdventureRoom room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdventureRoomScreen(
          roomName: room.title,
          isLocked: room.accessState == _AccessState.locked,
        ),
      ),
    );
  }
}

class _AdventureRoomCard extends StatelessWidget {
  const _AdventureRoomCard({
    required this.s,
    required this.room,
    required this.panelColor,
    required this.sand,
    required this.gold,
    required this.cyan,
    required this.isDiscover,
    required this.isMyRoom,
    required this.onPressed,
  });

  final double s;
  final _AdventureRoom room;
  final Color panelColor;
  final Color sand;
  final Color gold;
  final Color cyan;
  final bool isDiscover;
  final bool isMyRoom;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: panelColor,
          borderRadius: BorderRadius.circular(28 * s),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18 * s,
              offset: Offset(0, 10 * s),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(1 * s),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(27 * s),
            child: Container(
              color: panelColor,
              child: Column(
                children: [
                  _buildImageSection(),
                  if (isDiscover)
                    _buildDiscoverFooter()
                  else
                    _buildEnterFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return SizedBox(
      height: 158 * s,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(room.image, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.18),
                  const Color(0xFF08111B).withValues(alpha: 0.92),
                ],
                stops: const [0.45, 0.68, 1],
              ),
            ),
          ),
          Positioned(
            top: 10 * s,
            right: 10 * s,
            child: _StatusBadge(
              s: s,
              state: room.accessState,
              gold: gold,
              cyan: cyan,
            ),
          ),
          Positioned(
            left: 12 * s,
            right: 12 * s,
            bottom: 8 * s,
            child: isDiscover ? _buildDiscoverInfo() : _buildMembersInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            room.title,
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.1,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8 * s),
        _MetricColumn(
          s: s,
          label: 'Entry',
          value: room.entryFee?.toString() ?? '--',
          trailing: const _DpCoin(),
        ),
        SizedBox(width: 10 * s),
        _MetricColumn(
          s: s,
          label: 'Members',
          value: '${room.members}/${room.maxMembers}',
        ),
      ],
    );
  }

  Widget _buildMembersInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            room.title,
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.1,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 10 * s),
        if (isMyRoom && room.pendingRequests != null) ...[
          _MetricColumn(
            s: s,
            label: 'Members',
            value: '${room.members}/${room.maxMembers}',
          ),
          SizedBox(width: 10 * s),
          _MetricColumn(
            s: s,
            label: 'Pending requests',
            value: '${room.pendingRequests}',
            valueColor: gold,
          ),
        ] else
          _MetricColumn(
            s: s,
            label: 'Members',
            value: '${room.members}/${room.maxMembers}',
          ),
      ],
    );
  }

  Widget _buildDiscoverFooter() {
    return Padding(
      padding: EdgeInsets.fromLTRB(12 * s, 10 * s, 12 * s, 12 * s),
      child: GestureDetector(
        onTap: onPressed,
        child: _ActionButton(
          s: s,
          label: room.actionLabel,
          color: room.actionColor,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildEnterFooter() {
    return Padding(
      padding: EdgeInsets.fromLTRB(12 * s, 8 * s, 12 * s, 12 * s),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 4 * s),
              child: Text(
                isMyRoom ? '' : 'Members\n${room.members}/${room.maxMembers}',
                style: GoogleFonts.inter(
                  fontSize: isMyRoom ? 1 : 10 * s,
                  fontWeight: FontWeight.w500,
                  color: isMyRoom
                      ? Colors.transparent
                      : const Color(0xFFD8D9DD),
                  height: 1.45,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onPressed,
            child: _ActionButton(
              s: s,
              label: room.actionLabel,
              color: sand,
              width: 90 * s,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({
    required this.s,
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
    this.trailing,
  });

  final double s;
  final String label;
  final String value;
  final Color valueColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9 * s,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFA7AFB8),
          ),
        ),
        SizedBox(height: 2 * s),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
            if (trailing != null) ...[SizedBox(width: 4 * s), trailing!],
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.s,
    required this.label,
    required this.color,
    required this.width,
  });

  final double s;
  final String label;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 31 * s,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11 * s,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.s,
    required this.state,
    required this.gold,
    required this.cyan,
  });

  final double s;
  final _AccessState state;
  final Color gold;
  final Color cyan;

  @override
  Widget build(BuildContext context) {
    final isLocked = state == _AccessState.locked;
    final color = isLocked ? gold : cyan;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7 * s, vertical: 3 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF0A131D).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLocked ? Icons.lock_outline : Icons.lock_open_outlined,
            size: 11 * s,
            color: color,
          ),
          SizedBox(width: 3 * s),
          Text(
            isLocked ? 'Locked' : 'Open',
            style: GoogleFonts.inter(
              fontSize: 8 * s,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _DpCoin extends StatelessWidget {
  const _DpCoin();

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Container(
      width: 16 * s,
      height: 16 * s,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF00D8FF), Color(0xFF0C527F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        'DP',
        style: GoogleFonts.inter(
          fontSize: 5.5 * s,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
