import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import 'adventure_create_room_screen.dart';
import 'adventure_room_screen.dart';
import 'adventure_join_room_screen.dart';
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
  static const Color _background = Color(0xFF1E1813);
  static const Color _gold = Color(0xFFE0A10A);
  static const Color _cyan = Color(0xFF00C8FF);

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
      actionColor: _gold,
    ),
    _AdventureRoom(
      title: 'Rock climbing Heroes',
      image: 'assets/challenge/challenge_24_main_5.png',
      accessState: _AccessState.open,
      members: 12,
      maxMembers: 20,
      actionLabel: 'Enter',
      actionColor: _gold,
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
      actionColor: _gold,
    ),
    _AdventureRoom(
      title: 'Swimming Squad',
      image: 'assets/challenge/challenge_24_main_9.png',
      accessState: _AccessState.open,
      members: 12,
      maxMembers: 20,
      actionLabel: 'Enter',
      actionColor: _gold,
    ),
  ];

  _AdventureTab _selectedTab = _AdventureTab.discover;

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            const ProfileTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8 * s),
                    _buildHeader(s),
                    SizedBox(height: 16 * s),
                    _buildTabs(s),
                    SizedBox(height: 20 * s),
                    _buildCurrentTab(s),
                    SizedBox(height: 40 * s),
                  ],
                ),
              ),
            ),
          ],
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
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final name = auth.profile?.name?.trim();
                  final greeting = (name != null && name.isNotEmpty)
                      ? 'HI, ${name.toUpperCase()}'
                      : 'HI';
                  return Text(
                    greeting,
                    style: GoogleFonts.outfit(
                      fontSize: 11 * s,
                      fontWeight: FontWeight.w500,
                      color: Colors.white60,
                      letterSpacing: 1.0,
                    ),
                  );
                },
              ),
              SizedBox(height: 2 * s),
              Text(
                'Adventure Zone',
                style: GoogleFonts.outfit(
                  fontSize: 24 * s,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 2 * s),
              Text(
                'Create your arena',
                style: GoogleFonts.inter(
                  fontSize: 11 * s,
                  color: Colors.white38,
                  fontWeight: FontWeight.w400,
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
            padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 8 * s),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20 * s),
              border: Border.all(color: _gold, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: _gold, size: 16 * s),
                SizedBox(width: 4 * s),
                Text(
                  'Create',
                  style: GoogleFonts.inter(
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w700,
                    color: _gold,
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
        _tab(s, _AdventureTab.discover, 'Discover'),
        SizedBox(width: 8 * s),
        _tab(s, _AdventureTab.myRooms, 'My Rooms'),
        SizedBox(width: 8 * s),
        _tab(s, _AdventureTab.joined, 'Joined'),
      ],
    );
  }

  Widget _tab(double s, _AdventureTab tab, String label) {
    final isSelected = _selectedTab == tab;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
        decoration: BoxDecoration(
          color: isSelected ? _gold : Colors.transparent,
          borderRadius: BorderRadius.circular(20 * s),
          border: isSelected
              ? null
              : Border.all(color: Colors.white24, width: 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13 * s,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.black : Colors.white60,
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
            gold: _gold,
            cyan: _cyan,
            selectedTab: _selectedTab,
            onPressed: () => _openAdventureRoom(context, room),
          ),
          SizedBox(height: 16 * s),
        ],
      ],
    );
  }

  void _openAdventureRoom(BuildContext context, _AdventureRoom room) {
    if (_selectedTab == _AdventureTab.discover) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdventureJoinRoomScreen(
            roomName: room.title,
            isLocked: room.accessState == _AccessState.locked,
            imagePath: room.image,
            entryFee: (room.entryFee ?? 500).toDouble(),
          ),
        ),
      );
    } else {
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
}

class _AdventureRoomCard extends StatelessWidget {
  const _AdventureRoomCard({
    required this.s,
    required this.room,
    required this.gold,
    required this.cyan,
    required this.selectedTab,
    required this.onPressed,
  });

  final double s;
  final _AdventureRoom room;
  final Color gold;
  final Color cyan;
  final _AdventureTab selectedTab;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF13181D),
          borderRadius: BorderRadius.circular(18 * s),
          border: Border.all(color: Colors.white12, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildImageSection(), _buildFooter()],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18 * s)),
          child: Image.asset(
            room.image,
            width: double.infinity,
            height: 160 * s,
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18 * s)),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
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
          left: 14 * s,
          right: 14 * s,
          bottom: 10 * s,
          child: _buildInfoRow(),
        ),
      ],
    );
  }

  Widget _buildInfoRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            room.title,
            style: GoogleFonts.outfit(
              fontSize: 16 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: const [Shadow(color: Colors.black, blurRadius: 8)],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8 * s),
        if (selectedTab == _AdventureTab.discover)
          _buildDiscoverInfo()
        else
          _buildMembersInfo(),
      ],
    );
  }

  Widget _buildDiscoverInfo() {
    return Row(
      children: [
        _MetricColumn(
          s: s,
          label: 'Entry',
          valueId: '${room.entryFee}',
          trailing: _DpCoin(s: s),
        ),
        SizedBox(width: 10 * s),
        _MetricColumn(
          s: s,
          label: 'Members',
          valueId: '${room.members}/${room.maxMembers}',
        ),
      ],
    );
  }

  Widget _buildMembersInfo() {
    return Row(
      children: [
        _MetricColumn(
          s: s,
          label: 'Members',
          valueId: '${room.members}/${room.maxMembers}',
        ),
        if (selectedTab == _AdventureTab.myRooms &&
            room.pendingRequests != null) ...[
          SizedBox(width: 10 * s),
          _MetricColumn(
            s: s,
            label: 'Pending requests',
            valueId: '${room.pendingRequests}',
            valueColor: Colors.orangeAccent,
          ),
        ],
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.fromLTRB(14 * s, 10 * s, 14 * s, 14 * s),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 11 * s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24 * s),
          border: Border.all(color: room.actionColor, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          room.actionLabel,
          style: GoogleFonts.inter(
            fontSize: 14 * s,
            fontWeight: FontWeight.w700,
            color: room.actionColor,
          ),
        ),
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({
    required this.s,
    required this.label,
    required this.valueId,
    this.valueColor = Colors.white,
    this.trailing,
  });

  final double s;
  final String label;
  final String valueId;
  final Color valueColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 8 * s, color: Colors.white60),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              valueId,
              style: GoogleFonts.outfit(
                fontSize: 12 * s,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
            if (trailing != null) ...[SizedBox(width: 3 * s), trailing!],
          ],
        ),
      ],
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
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 5 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1217).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLocked ? Icons.lock : Icons.lock_open,
            size: 12 * s,
            color: color,
          ),
          SizedBox(width: 4 * s),
          Text(
            isLocked ? 'Locked' : 'Open',
            style: GoogleFonts.inter(
              fontSize: 10 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _DpCoin extends StatelessWidget {
  const _DpCoin({required this.s});
  final double s;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14 * s,
      height: 14 * s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF00E5FF), width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        'DP',
        style: GoogleFonts.outfit(
          fontSize: 6 * s,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF00E5FF),
        ),
      ),
    );
  }
}
