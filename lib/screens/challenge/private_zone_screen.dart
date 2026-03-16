import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import 'create_room_screen.dart';
import 'live_competition_screen.dart';
import 'private_zone_room_screen.dart';
import 'private_zone_rules_screen.dart';
import '../../services/challenge_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Data models ───────────────────────────────────────────────────────────────
enum _RoomStatus { locked, open }

class _RoomData {
  final String id;
  final String name;
  final String image;
  final _RoomStatus status;
  final int entry;
  final int pendingRequests;
  final bool isEnded;
  final int members;
  final int maxMembers;
  final String adminId;
  final String adminName;
  final String rules;
  final List<String> participantIds;

  const _RoomData({
    required this.id,
    required this.name,
    required this.image,
    required this.status,
    this.entry = 0,
    this.pendingRequests = 0,
    this.isEnded = false,
    this.members = 1,
    this.maxMembers = 20,
    this.adminId = '',
    this.adminName = 'Admin',
    this.rules = '',
    this.participantIds = const [],
  });

  factory _RoomData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final visibility = data['visibility'] ?? 'Public';
    final statusStr = data['status'] ?? 'ACTIVE';
    final participantIds = List<String>.from(data['participant_ids'] ?? []);

    return _RoomData(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Room',
      image: data['image_url'] ?? 'assets/challenge/challenge_24_main_1.png',
      status: visibility == 'Private' ? _RoomStatus.locked : _RoomStatus.open,
      entry: data['entry_fee'] ?? 0,
      pendingRequests: 0, // Would need a separate count if we want to show this
      isEnded: statusStr == 'COMPLETED',
      members: data['current_participants'] ?? 1,
      maxMembers: data['max_participants'] ?? 20,
      adminId: data['admin_id'] ?? '',
      adminName: data['admin_name'] ?? 'Admin',
      rules: data['rules'] ?? '',
      participantIds: participantIds,
    );
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────
class PrivateZoneScreen extends StatefulWidget {
  const PrivateZoneScreen({super.key});

  @override
  State<PrivateZoneScreen> createState() => _PrivateZoneScreenState();
}

class _PrivateZoneScreenState extends State<PrivateZoneScreen> {
  final Color themeGreen = const Color(0xFF00FF88);
  final Color bgDark = const Color(0xFF0D1217);
  final Color cyanBlue = const Color(0xFF00E5FF);
  final Color amber = const Color(0xFFFFC107);

  int _selectedTab = 0; // 0=Discover, 1=My Rooms, 2=Joined

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            const ProfileTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8 * s),
                      _buildTopSection(s),
                      SizedBox(height: 16 * s),
                      _buildTabs(s),
                      SizedBox(height: 20 * s),
                      _buildContent(s),
                      SizedBox(height: 40 * s),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Section ──────────────────────────────────────────────────────────────
  Widget _buildTopSection(double s) {
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
                'Private Zone',
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
        // + Create button
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateRoomScreen()),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 8 * s),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20 * s),
              border: Border.all(color: themeGreen, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: themeGreen, size: 16 * s),
                SizedBox(width: 4 * s),
                Text(
                  'Create',
                  style: GoogleFonts.inter(
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w700,
                    color: themeGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Tab Bar ──────────────────────────────────────────────────────────────────
  Widget _buildTabs(double s) {
    return Row(
      children: [
        _tab(s, 0, 'Discover'),
        SizedBox(width: 8 * s),
        _tab(s, 1, 'My Rooms'),
        SizedBox(width: 8 * s),
        _tab(s, 2, 'Joined'),
      ],
    );
  }

  Widget _tab(double s, int index, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
        decoration: BoxDecoration(
          color: isSelected ? themeGreen : Colors.transparent,
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

  // ── Content by tab ───────────────────────────────────────────────────────────
  Widget _buildContent(double s) {
    if (_selectedTab == 0) return _buildDiscoverList(s);
    if (_selectedTab == 1) return _buildMyRoomsList(s);
    return _buildJoinedList(s);
  }

  // ── DISCOVER ─────────────────────────────────────────────────────────────────
  Widget _buildDiscoverList(double s) {
    final userId = context.read<AuthProvider>().firebaseUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: ChallengeService().getDiscoverRoomsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(top: 60 * s),
              child: CircularProgressIndicator(color: themeGreen),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        final rooms = docs
            .map((doc) => _RoomData.fromFirestore(doc))
            .where(
              (room) =>
                  room.adminId != userId &&
                  !room.participantIds.contains(userId),
            )
            .toList();

        if (rooms.isEmpty) return _buildEmptyState(s, "No rooms to discover");

        return Column(
          children: rooms.map((room) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16 * s),
              child: _DiscoverCard(
                s: s,
                room: room,
                themeGreen: themeGreen,
                cyanBlue: cyanBlue,
                amber: amber,
                onTap: () => _onDiscoverCardTap(room),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ── MY ROOMS ─────────────────────────────────────────────────────────────────
  Widget _buildMyRoomsList(double s) {
    final userId = context.read<AuthProvider>().firebaseUser?.uid;
    if (userId == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: ChallengeService().getMyRoomsStream(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(top: 60 * s),
              child: CircularProgressIndicator(color: themeGreen),
            ),
          );
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty)
          return _buildEmptyState(s, "You haven't created any rooms");

        return Column(
          children: docs.map((doc) {
            final room = _RoomData.fromFirestore(doc);
            return Padding(
              padding: EdgeInsets.only(bottom: 16 * s),
              child: _MyRoomCard(
                s: s,
                room: room,
                themeGreen: themeGreen,
                onTap: () => _goToRoom(room),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ── JOINED ───────────────────────────────────────────────────────────────────
  Widget _buildJoinedList(double s) {
    final userId = context.read<AuthProvider>().firebaseUser?.uid;
    if (userId == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: ChallengeService().getJoinedRoomsStream(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(top: 60 * s),
              child: CircularProgressIndicator(color: themeGreen),
            ),
          );
        }
        final docs = snapshot.data!.docs;
        final rooms = docs
            .map((doc) => _RoomData.fromFirestore(doc))
            .where(
              (room) => room.adminId != userId,
            ) // Don't show rooms user created in "Joined"
            .toList();

        if (rooms.isEmpty)
          return _buildEmptyState(s, "You haven't joined any rooms");

        return Column(
          children: rooms.map((room) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16 * s),
              child: _JoinedCard(
                s: s,
                room: room,
                themeGreen: themeGreen,
                onTap: () =>
                    room.isEnded ? _goToLiveCompetition(room) : _goToRoom(room),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmptyState(double s, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 40 * s),
        child: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white38, fontSize: 14 * s),
        ),
      ),
    );
  }

  void _goToRoom(_RoomData room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrivateZoneRoomScreen(
          roomId: room.id,
          roomName: room.name,
          bannerImage: room.image,
          entryFee: room.entry,
          members: room.members,
          maxMembers: room.maxMembers,
          adminName: room.adminName,
          rules: room.rules,
          isLocked: room.status == _RoomStatus.locked,
          participantIds: room.participantIds,
        ),
      ),
    );
  }

  void _onDiscoverCardTap(_RoomData room) {
    if (room.status == _RoomStatus.locked) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PrivateZoneRulesScreen(
            roomId: room.id,
            roomName: room.name,
            bannerImage: room.image,
            entryFeeOp: room.entry,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LiveCompetitionScreen(
            roomId: room.id,
            competitionName: room.name,
            bannerImage: room.image,
            viewState: CompetitionViewState.liveNotJoined,
          ),
        ),
      );
    }
  }

  void _goToLiveCompetition(_RoomData room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveCompetitionScreen(
          roomId: room.id,
          competitionName: room.name,
          bannerImage: room.image,
          viewState: room.isEnded
              ? CompetitionViewState.ended
              : CompetitionViewState.liveJoined,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DISCOVER CARD
// ─────────────────────────────────────────────────────────────────────────────
class _DiscoverCard extends StatelessWidget {
  final double s;
  final _RoomData room;
  final Color themeGreen;
  final Color cyanBlue;
  final Color amber;
  final VoidCallback onTap;

  const _DiscoverCard({
    required this.s,
    required this.room,
    required this.themeGreen,
    required this.cyanBlue,
    required this.amber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = room.status == _RoomStatus.locked;
    final buttonColor = isLocked ? amber : cyanBlue;
    final buttonLabel = isLocked ? 'Request Access' : 'Join Now';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF13181D),
          borderRadius: BorderRadius.circular(18 * s),
          border: Border.all(color: Colors.white12, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlays
            Stack(
              children: [
                // Photo
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(18 * s),
                  ),
                  child: _buildImage(room.image, 160 * s, s),
                ),
                // Gradient scrim
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18 * s),
                    ),
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
                // Lock/Open badge
                Positioned(
                  top: 10 * s,
                  right: 10 * s,
                  child: _StatusBadge(
                    s: s,
                    isLocked: isLocked,
                    themeGreen: themeGreen,
                  ),
                ),
                // Bottom info
                Positioned(
                  left: 14 * s,
                  right: 14 * s,
                  bottom: 10 * s,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          room.name,
                          style: GoogleFonts.outfit(
                            fontSize: 16 * s,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            shadows: [
                              const Shadow(color: Colors.black, blurRadius: 8),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8 * s),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Entry',
                            style: GoogleFonts.inter(
                              fontSize: 8 * s,
                              color: Colors.white60,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${room.entry}',
                                style: GoogleFonts.outfit(
                                  fontSize: 12 * s,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 3 * s),
                              _DpIcon(s: s),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: 10 * s),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Members',
                            style: GoogleFonts.inter(
                              fontSize: 8 * s,
                              color: Colors.white60,
                            ),
                          ),
                          Text(
                            '${room.members}/${room.maxMembers}',
                            style: GoogleFonts.outfit(
                              fontSize: 12 * s,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Button row
            Padding(
              padding: EdgeInsets.fromLTRB(14 * s, 10 * s, 14 * s, 14 * s),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 11 * s),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24 * s),
                  border: Border.all(color: buttonColor, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  buttonLabel,
                  style: GoogleFonts.inter(
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w700,
                    color: buttonColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MY ROOMS CARD
// ─────────────────────────────────────────────────────────────────────────────
class _MyRoomCard extends StatelessWidget {
  final double s;
  final _RoomData room;
  final Color themeGreen;
  final VoidCallback onTap;

  const _MyRoomCard({
    required this.s,
    required this.room,
    required this.themeGreen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = room.status == _RoomStatus.locked;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF13181D),
          borderRadius: BorderRadius.circular(18 * s),
          border: Border.all(color: Colors.white12, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(18 * s),
                  ),
                  child: _buildImage(room.image, 160 * s, s),
                ),
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18 * s),
                    ),
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
                    isLocked: isLocked,
                    themeGreen: themeGreen,
                  ),
                ),
                // Room name + members + pending
                Positioned(
                  left: 14 * s,
                  right: 14 * s,
                  bottom: 12 * s,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.name,
                              style: GoogleFonts.outfit(
                                fontSize: 16 * s,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(color: Colors.black, blurRadius: 8),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2 * s),
                            Row(
                              children: [
                                Text(
                                  'Members',
                                  style: GoogleFonts.inter(
                                    fontSize: 9 * s,
                                    color: Colors.white60,
                                  ),
                                ),
                                SizedBox(width: 4 * s),
                                Text(
                                  '${room.members}/${room.maxMembers}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10 * s,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (room.pendingRequests > 0) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Pending requests',
                              style: GoogleFonts.inter(
                                fontSize: 9 * s,
                                color: Colors.white60,
                              ),
                            ),
                            Text(
                              '${room.pendingRequests}',
                              style: GoogleFonts.outfit(
                                fontSize: 22 * s,
                                fontWeight: FontWeight.w800,
                                color: Colors.orangeAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Enter button
            Padding(
              padding: EdgeInsets.fromLTRB(14 * s, 10 * s, 14 * s, 14 * s),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 11 * s),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24 * s),
                  border: Border.all(color: themeGreen, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Enter',
                  style: GoogleFonts.inter(
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w700,
                    color: themeGreen,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// JOINED CARD
// ─────────────────────────────────────────────────────────────────────────────
class _JoinedCard extends StatelessWidget {
  final double s;
  final _RoomData room;
  final Color themeGreen;
  final VoidCallback onTap;

  const _JoinedCard({
    required this.s,
    required this.room,
    required this.themeGreen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = room.status == _RoomStatus.locked;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF13181D),
          borderRadius: BorderRadius.circular(18 * s),
          border: Border.all(color: Colors.white12, width: 1),
        ),
        child: Stack(
          children: [
            // Full image
            ClipRRect(
              borderRadius: BorderRadius.circular(18 * s),
              child: _buildImage(room.image, 180 * s, s),
            ),
            // Gradient scrim
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18 * s),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.82),
                      ],
                      stops: const [0.35, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            // Badge
            Positioned(
              top: 10 * s,
              right: 10 * s,
              child: _StatusBadge(
                s: s,
                isLocked: isLocked,
                themeGreen: themeGreen,
              ),
            ),
            // Bottom info + Enter button
            Positioned(
              left: 14 * s,
              right: 14 * s,
              bottom: 14 * s,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.name,
                          style: GoogleFonts.outfit(
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            shadows: const [
                              Shadow(color: Colors.black, blurRadius: 8),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2 * s),
                        Row(
                          children: [
                            Text(
                              'Members',
                              style: GoogleFonts.inter(
                                fontSize: 9 * s,
                                color: Colors.white60,
                              ),
                            ),
                            SizedBox(width: 4 * s),
                            Text(
                              '${room.members}/${room.maxMembers}',
                              style: GoogleFonts.inter(
                                fontSize: 10 * s,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Enter pill button
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20 * s,
                        vertical: 8 * s,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20 * s),
                        border: Border.all(color: themeGreen, width: 1.5),
                      ),
                      child: Text(
                        'Enter',
                        style: GoogleFonts.inter(
                          fontSize: 13 * s,
                          fontWeight: FontWeight.w700,
                          color: themeGreen,
                        ),
                      ),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

/// 🔒 Locked / 🔓 Open badge
class _StatusBadge extends StatelessWidget {
  final double s;
  final bool isLocked;
  final Color themeGreen;

  const _StatusBadge({
    required this.s,
    required this.isLocked,
    required this.themeGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(
          color: isLocked ? Colors.orangeAccent : themeGreen,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
            color: isLocked ? Colors.orangeAccent : themeGreen,
            size: 9 * s,
          ),
          SizedBox(width: 3 * s),
          Text(
            isLocked ? 'Locked' : 'Open',
            style: GoogleFonts.inter(
              fontSize: 9 * s,
              fontWeight: FontWeight.w700,
              color: isLocked ? Colors.orangeAccent : themeGreen,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small circular DP coin icon
class _DpIcon extends StatelessWidget {
  final double s;
  const _DpIcon({required this.s});

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
          fontSize: 5 * s,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF00E5FF),
        ),
      ),
    );
  }
}

Widget _buildImage(String imagePath, double height, double s) {
  if (imagePath.startsWith('http')) {
    return Image.network(
      imagePath,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          _buildPlaceholder(height, s),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildPlaceholder(height, s);
      },
    );
  }
  return Image.asset(
    imagePath,
    width: double.infinity,
    height: height,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(height, s),
  );
}

Widget _buildPlaceholder(double height, double s) {
  return Container(
    width: double.infinity,
    height: height,
    color: Colors.white12,
    child: Icon(Icons.image_outlined, color: Colors.white24, size: 30 * s),
  );
}
