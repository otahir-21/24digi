import 'package:flutter/material.dart';
import '../../core/utils/custom_snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import 'private_zone_rules_screen.dart';
import 'share_activity_card_screen.dart';
import '../../services/challenge_service.dart';
import 'competition_system_alert_screen.dart';

class PrivateZoneRoomScreen extends StatefulWidget {
  final String roomId;
  final String roomName;
  final String bannerImage;
  final int entryFee;
  final int members;
  final int maxMembers;
  final String adminName;
  final String rules;
  final bool isLocked;
  final List<String> participantIds;

  const PrivateZoneRoomScreen({
    super.key,
    required this.roomId,
    this.roomName = 'Elite Runners Club',
    this.bannerImage = 'assets/challenge/challenge_24_main_1.png',
    this.entryFee = 500,
    this.members = 1,
    this.maxMembers = 20,
    this.adminName = 'Admin',
    this.rules = '',
    this.isLocked = false,
    this.participantIds = const [],
  });

  @override
  State<PrivateZoneRoomScreen> createState() => _PrivateZoneRoomScreenState();
}

class _PrivateZoneRoomScreenState extends State<PrivateZoneRoomScreen> {
  final Color themeGreen = const Color(0xFF00FF88);
  final Color bgDark = const Color(0xFF0D1217);
  bool _isWeeklySelected = true;

  // Leaderboard data now comes from Firestore stream

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final auth = context.read<AuthProvider>();
    final userId = auth.firebaseUser?.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('challenge_rooms')
          .doc(widget.roomId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D1217),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final roomData = snapshot.data!.data() as Map<String, dynamic>;
        final status = roomData['status'] ?? 'ACTIVE';
        final participantIds = List<String>.from(roomData['participant_ids'] ?? []);
        final quitUsers = List<String>.from(roomData['quit_users'] ?? []);
        final bool isJoined = userId != null && participantIds.contains(userId);
        final bool isQuit = userId != null && quitUsers.contains(userId);
        final bool isEnded = status == 'ENDED';

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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 8 * s),
                          _buildGreeting(s),
                          SizedBox(height: 4 * s),
                          _buildTitle(s),
                          SizedBox(height: 16 * s),
                          _buildRoomCardDynamic(s, roomData),
                          if (isQuit) ...[
                            SizedBox(height: 20 * s),
                            _buildQuitNotice(s),
                          ] else if (isJoined) ...[
                            SizedBox(height: 20 * s),
                            _buildLiveAndToggle(s),
                            SizedBox(height: 12 * s),
                            _buildLeaderboard(s),
                            SizedBox(height: 12 * s),
                            _buildSeeMore(s),
                            SizedBox(height: 8 * s),
                            _buildShareActivityLink(s),
                            SizedBox(height: 12 * s),
                            _buildUserRow(s),
                            SizedBox(height: 24 * s),
                            if (!isEnded) _buildQuitButton(s),
                          ] else if (widget.isLocked) ...[
                            SizedBox(height: 20 * s),
                            _buildAboutThisRoom(s),
                            SizedBox(height: 16 * s),
                            _buildApprovalRequired(s),
                            SizedBox(height: 24 * s),
                            _buildEntryFeeFooter(s),
                            _buildSendRequestButton(s),
                          ] else ...[
                            SizedBox(height: 20 * s),
                            if (!isEnded) ...[
                              _buildLiveAndToggle(s),
                              SizedBox(height: 12 * s),
                              _buildLeaderboard(s),
                              SizedBox(height: 12 * s),
                              _buildSeeMore(s),
                              SizedBox(height: 8 * s),
                              _buildShareActivityLink(s),
                              SizedBox(height: 12 * s),
                              _buildUserRow(s),
                              SizedBox(height: 24 * s),
                              _buildEntryFeeFooter(s),
                              _buildJoinNowButton(s),
                            ] else ...[
                              _buildLeaderboard(s),
                            ],
                          ],
                          SizedBox(height: 32 * s),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuitNotice(double s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20 * s, horizontal: 16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5252).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: const Color(0xFFFF5252).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF5252), size: 32),
          SizedBox(height: 12 * s),
          Text(
            'YOU ALREADY QUIT THIS COMPETITION',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16 * s,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFF5252),
            ),
          ),
          SizedBox(height: 8 * s),
          Text(
            'You cannot re-join this competition after quitting.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13 * s,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCardDynamic(double s, Map<String, dynamic> data) {
    final status = data['status'] ?? 'ACTIVE';
    final isLive = status == 'ACTIVE';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1B2228),
        borderRadius: BorderRadius.circular(24 * s),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24 * s)),
            child: Stack(
              children: [
                _buildRoomImage(widget.bannerImage, 180 * s, s),
                Positioned(
                  top: 12 * s,
                  left: 12 * s,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
                    decoration: BoxDecoration(
                      color: isLive ? themeGreen : const Color(0xFFFF5252),
                      borderRadius: BorderRadius.circular(12 * s),
                    ),
                    child: Text(
                      isLive ? 'LIVE' : 'ENDED',
                      style: GoogleFonts.inter(
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w800,
                        color: isLive ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16 * s),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoItem(s, 'Fee', '${widget.entryFee} pts'),
                _infoItem(s, 'Members', '${data['current_participants'] ?? 0}/${widget.maxMembers}'),
                _infoItem(s, 'Admin', widget.adminName),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(double s, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9 * s,
            color: Colors.white54,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4 * s),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14 * s,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(double s) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final name = auth.profile?.name?.trim();
        final greeting = (name != null && name.isNotEmpty)
            ? 'HI, ${name.toUpperCase()}'
            : 'HI';
        return Text(
          greeting,
          style: GoogleFonts.outfit(
            fontSize: 12 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        );
      },
    );
  }

  Widget _buildTitle(double s) {
    return Text(
      widget.roomName,
      textAlign: TextAlign.center,
      style: GoogleFonts.outfit(
        fontSize: 26 * s,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: 0.2,
      ),
    );
  }



  Widget _buildAboutThisRoom(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {},
          child: Text(
            'About this room',
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              fontWeight: FontWeight.w600,
              color: Colors.blueAccent,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        SizedBox(height: 10 * s),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16 * s),
          decoration: BoxDecoration(
            color: const Color(0xFF13181D),
            borderRadius: BorderRadius.circular(16 * s),
            border: Border.all(color: Colors.white12, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.rules.isNotEmpty
                    ? widget.rules
                    : 'Welcome to the elite circle of night runners. We push limits, break records, and earn massive DIGI points. This room is for those who take cardio seriously.',
                style: GoogleFonts.inter(
                  fontSize: 13 * s,
                  color: Colors.white70,
                  height: 1.45,
                ),
              ),
              SizedBox(height: 14 * s),
              Text(
                'Key Rules',
                style: GoogleFonts.inter(
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8 * s),
              _buildBullet(s, 'Sync your 24DIGI device daily before starting.'),
              _buildBullet(
                s,
                'Top 3 winners split the weekly pot (10k DIGI point).',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBullet(double s, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: GoogleFonts.inter(fontSize: 13 * s, color: Colors.white70),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalRequired(double s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF13181D),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, color: Colors.white54, size: 20 * s),
          SizedBox(width: 12 * s),
          Expanded(
            child: Text(
              'Approval Required. This is a private room. Your profile stats will be reviewed by the admin before access is granted.',
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryFeeFooter(double s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF13181D),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Row(
        children: [
          Text(
            'ENTRY FEE',
            style: GoogleFonts.inter(
              fontSize: 11 * s,
              color: Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 8 * s),
          Text(
            '${widget.entryFee}',
            style: GoogleFonts.outfit(
              fontSize: 20 * s,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 6 * s),
          Container(
            width: 22 * s,
            height: 22 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00E5FF), width: 1),
            ),
            alignment: Alignment.center,
            child: Text(
              'DP',
              style: GoogleFonts.outfit(
                fontSize: 7 * s,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF00E5FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendRequestButton(double s) {
    return Padding(
      padding: EdgeInsets.only(top: 12 * s),
      child: SizedBox(
        width: double.infinity,
        height: 52 * s,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: themeGreen,
            foregroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14 * s),
            ),
          ),
          child: Text(
            'Send a Request',
            style: GoogleFonts.inter(
              fontSize: 15 * s,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJoinNowButton(double s) {
    return Padding(
      padding: EdgeInsets.only(top: 12 * s),
      child: SizedBox(
        width: double.infinity,
        height: 52 * s,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PrivateZoneRulesScreen(
                  roomId: widget.roomId,
                  roomName: widget.roomName,
                  bannerImage: 'assets/challenge/challenge_24_main_7.png',
                  entryFeeOp: 500,
                  adminName: 'Admin_Name',
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: themeGreen,
            foregroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14 * s),
            ),
          ),
          child: Text(
            'Join Now',
            style: GoogleFonts.inter(
              fontSize: 15 * s,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildLiveAndToggle(double s) {
    return Row(
      children: [
        // Live indicator
        Container(
          width: 8 * s,
          height: 8 * s,
          decoration: BoxDecoration(
            color: themeGreen,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: themeGreen.withValues(alpha: 0.8),
                blurRadius: 6 * s,
                spreadRadius: 1 * s,
              ),
            ],
          ),
        ),
        SizedBox(width: 6 * s),
        Text(
          'Live',
          style: GoogleFonts.inter(
            fontSize: 14 * s,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        // Toggle pill
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E252C),
            borderRadius: BorderRadius.circular(20 * s),
            border: Border.all(color: Colors.white12, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToggleOption(s, 'Weekly', _isWeeklySelected, () {
                setState(() => _isWeeklySelected = true);
              }),
              _buildToggleOption(s, 'All Time', !_isWeeklySelected, () {
                setState(() => _isWeeklySelected = false);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleOption(
    double s,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 6 * s),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E3E48) : Colors.transparent,
          borderRadius: BorderRadius.circular(20 * s),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12 * s,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboard(double s) {
    return StreamBuilder<QuerySnapshot>(
      stream: ChallengeService().getParticipantsStream(widget.roomId),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        
        if (docs.isEmpty) {
          return Center(
            child: Text(
              'No participants yet',
              style: GoogleFonts.inter(fontSize: 14 * s, color: Colors.white54),
            ),
          );
        }
        
        return Column(
          children: docs.take(5).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final doc = entry.value;
            final data = doc.data() as Map<String, dynamic>;
            final rank = (index + 1).toString().padLeft(2, '0');
            
            return Padding(
              padding: EdgeInsets.only(bottom: 8 * s),
              child: _buildLeaderboardRow(
                s,
                rank: rank,
                name: data['display_name']?.toString() ?? 'User',
                calories: data['calories']?.toString() ?? '--',
                time: data['time']?.toString() ?? '--',
                bpm: data['bpm']?.toString() ?? '--',
                pace: data['pace']?.toString() ?? '--',
                height: data['height']?.toString() ?? "--",
                isUser: false,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSeeMore(double s) {
    return Text(
      'see more',
      style: GoogleFonts.inter(fontSize: 10 * s, color: Colors.white38),
    );
  }

  Widget _buildShareActivityLink(double s) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShareActivityCardScreen(roomName: widget.roomName),
          ),
        );
      },
      child: Text(
        'Share Activity',
        style: GoogleFonts.inter(
          fontSize: 13 * s,
          color: themeGreen,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildUserRow(double s) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final userName = auth.profile?.name ?? 'You';
        return _buildLeaderboardRow(
          s,
          rank: '--',
          name: userName,
          calories: '--',
          time: '--',
          bpm: '--',
          pace: '--',
          height: "--",
          isUser: true,
        );
      },
    );
  }

  Widget _buildLeaderboardRow(
    double s, {
    required String rank,
    required String name,
    required String calories,
    required String time,
    required String bpm,
    required String pace,
    required String height,
    required bool isUser,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 10 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF13181D),
        borderRadius: BorderRadius.circular(14 * s),
        border: Border.all(color: themeGreen, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name row
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 11 * s,
              fontWeight: FontWeight.w600,
              color: isUser ? themeGreen : Colors.white70,
            ),
          ),
          SizedBox(height: 8 * s),
          // Stats row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Rank number
              Text(
                rank,
                style: GoogleFonts.outfit(
                  fontSize: 22 * s,
                  fontWeight: FontWeight.w800,
                  color: themeGreen,
                  height: 1,
                ),
              ),
              SizedBox(width: 8 * s),
              // Avatar
              Container(
                width: 34 * s,
                height: 34 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1),
                  image: const DecorationImage(
                    image: AssetImage('assets/fonts/male.png'),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
              SizedBox(width: 8 * s),
              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol(
                      s,
                      Icons.local_fire_department,
                      const Color(0xFFFF6B35),
                      calories,
                    ),
                    _buildStatCol(
                      s,
                      Icons.access_time_rounded,
                      Colors.blueAccent,
                      time,
                    ),
                    _buildStatCol(
                      s,
                      Icons.favorite,
                      const Color(0xFFE040FB),
                      bpm,
                    ),
                    _buildStatCol(
                      s,
                      Icons.location_on,
                      const Color(0xFFAB47BC),
                      pace,
                    ),
                    _buildStatCol(s, Icons.speed_rounded, themeGreen, height),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(double s, IconData icon, Color iconColor, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 16 * s),
        SizedBox(height: 2 * s),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 9 * s,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }


  Widget _buildQuitButton(double s) {
    return GestureDetector(
      onTap: () => _showQuitConfirmation(context),
      child: _actionPill(s, 'Quit Competition', isQuit: true),
    );
  }

  Widget _actionPill(double s, String label, {bool isQuit = false}) {
    return Container(
      height: 28 * s,
      decoration: BoxDecoration(
        color: isQuit ? Colors.redAccent.withOpacity(0.1) : Colors.black26,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isQuit
              ? Colors.redAccent.withOpacity(0.5)
              : Colors.white24.withOpacity(0.5),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11 * s,
          fontWeight: FontWeight.w700,
          color: isQuit ? Colors.redAccent : Colors.white70,
        ),
      ),
    );
  }

  Future<void> _showQuitConfirmation(BuildContext context) async {
    final confirm = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const CompetitionSystemAlertScreen(alertType: AlertType.quit),
      ),
    );

    if (confirm == true) {
      try {
        final auth = context.read<AuthProvider>();
        final userId = auth.firebaseUser?.uid;
        if (userId != null) {
          await ChallengeService().quitChallengeRoom(
            roomId: widget.roomId,
            userId: userId,
          );
          if (mounted) {
            Navigator.pop(context);
            CustomSnackBar.show(
              context,
              message: 'Succesfully left the room',
              isAdventure: false,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBar.show(
            context,
            message: 'Error: ${e.toString()}',
            isError: true,
            isAdventure: false,
          );
        }
      }
    }
  }

  Widget _buildRoomImage(String imagePath, double height, double s) {
    // Check if URL is valid and accessible
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Log error for debugging
          debugPrint('Image failed to load: $imagePath, error: $error');
          return _buildPlaceholder(height, s);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(height, s);
        },
      );
    }
    // For asset paths, verify the asset exists by trying to load it
    return Image.asset(
      imagePath,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Asset image failed to load: $imagePath, error: $error');
        return _buildPlaceholder(height, s);
      },
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
}
