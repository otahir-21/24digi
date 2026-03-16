import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import '../../services/challenge_service.dart';

/// Private room request access screen: room card, about, approval required,
/// Send a Request. After sending shows "Sent" with tick. Uses Firestore for room + request status.
class PrivateRoomRequestScreen extends StatelessWidget {
  final String roomId;

  const PrivateRoomRequestScreen({
    super.key,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().firebaseUser?.uid;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1217),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: ChallengeService().getRoomStream(roomId),
          builder: (context, roomSnapshot) {
            if (!roomSnapshot.hasData || !roomSnapshot.data!.exists) {
              return Center(
                child: CircularProgressIndicator(color: const Color(0xFF00FF88)),
              );
            }
            final roomData = roomSnapshot.data!.data() as Map<String, dynamic>? ?? {};
            final visibility = roomData['visibility'] ?? 'Public';
            if (visibility != 'Private') {
              return Center(
                child: Text(
                  'This room is not private',
                  style: GoogleFonts.inter(color: Colors.white70),
                ),
              );
            }
            return StreamBuilder<DocumentSnapshot>(
              stream: userId != null
                  ? ChallengeService().getJoinRequestStream(roomId, userId)
                  : null,
              builder: (context, requestSnapshot) {
                String? requestStatus;
                if (requestSnapshot.hasData && requestSnapshot.data!.exists) {
                  final data = requestSnapshot.data!.data() as Map<String, dynamic>?;
                  requestStatus = data?['status']?.toString();
                }
                return _Content(
                  roomId: roomId,
                  roomData: roomData,
                  requestStatus: requestStatus,
                  userId: userId,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _Content extends StatefulWidget {
  final String roomId;
  final Map<String, dynamic> roomData;
  final String? requestStatus;
  final String? userId;

  const _Content({
    required this.roomId,
    required this.roomData,
    this.requestStatus,
    this.userId,
  });

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  bool _isSending = false;
  bool _sentOnce = false;

  String get _name => widget.roomData['name']?.toString() ?? 'Elite Runners Club';
  String get _imageUrl =>
      widget.roomData['image_url']?.toString() ??
      'assets/challenge/challenge_24_main_1.png';
  String get _adminName =>
      widget.roomData['admin_display_name']?.toString() ??
      widget.roomData['admin_name']?.toString() ??
      'Khalfan';
  String get _adminAvatar =>
      widget.roomData['admin_avatar_url']?.toString() ?? '';
  int get _entryFee =>
      (widget.roomData['entry_fee'] is int)
          ? widget.roomData['entry_fee'] as int
          : ((widget.roomData['entry_fee'] is num)
              ? (widget.roomData['entry_fee'] as num).toInt()
              : 500);
  int get _members =>
      (widget.roomData['current_participants'] is int)
          ? widget.roomData['current_participants'] as int
          : 48;
  int get _maxMembers =>
      (widget.roomData['max_participants'] is int)
          ? widget.roomData['max_participants'] as int
          : 50;
  String get _rules =>
      widget.roomData['rules']?.toString() ??
      'Welcome to the elite circle of night runners. We push limits, break records, and earn massive DIGI points. This room is for those who take cardio seriously.';

  bool get _hasPendingRequest =>
      widget.requestStatus == 'PENDING' || _sentOnce;
  bool get _isRejected => widget.requestStatus == 'REJECTED';
  bool get _isAccepted => widget.requestStatus == 'ACCEPTED';

  Future<void> _sendRequest() async {
    if (widget.userId == null) return;
    setState(() => _isSending = true);
    try {
      final auth = context.read<AuthProvider>();
      await ChallengeService().requestJoinLockedRoom(
        roomId: widget.roomId,
        userId: widget.userId!,
        displayName: auth.profile?.name ?? 'User',
        avatarUrl: auth.profile?.profileImage ?? '',
      );
      if (mounted) {
        setState(() {
          _isSending = false;
          _sentOnce = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send request: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    const themeGreen = Color(0xFF00FF88);
    const cardDark = Color(0xFF13181D);

    return Column(
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
                _buildGreeting(s),
                SizedBox(height: 16 * s),
                _buildTitle(s),
                SizedBox(height: 16 * s),
                _buildRoomCard(s, cardDark, themeGreen),
                SizedBox(height: 20 * s),
                _buildAboutSection(s, cardDark),
                SizedBox(height: 16 * s),
                _buildApprovalRequired(s, cardDark),
                SizedBox(height: 20 * s),
                _buildEntryFeeAndButton(s, themeGreen),
                SizedBox(height: 40 * s),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(double s) {
    return Center(
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final name = auth.profile?.name?.trim();
          final greeting = (name != null && name.isNotEmpty)
              ? 'HI, ${name.toUpperCase()}'
              : 'HI, USER';
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
      ),
    );
  }

  Widget _buildTitle(double s) {
    return Center(
      child: Text(
        _name,
        style: GoogleFonts.outfit(
          fontSize: 22 * s,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRoomCard(double s, Color cardDark, Color themeGreen) {
    final isNetwork = _imageUrl.startsWith('http');
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16 * s)),
            child: isNetwork
                ? Image.network(
                    _imageUrl,
                    width: double.infinity,
                    height: 140 * s,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderBanner(s),
                  )
                : Image.asset(
                    _imageUrl,
                    width: double.infinity,
                    height: 140 * s,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderBanner(s),
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(16 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42 * s,
                      height: 42 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: themeGreen, width: 1.5 * s),
                      ),
                      child: ClipOval(
                        child: _adminAvatar.isNotEmpty && _adminAvatar.startsWith('http')
                            ? Image.network(
                                _adminAvatar,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Icon(Icons.person, color: themeGreen, size: 24 * s),
                              )
                            : Image.asset(
                                'assets/fonts/male.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Icon(Icons.person, color: themeGreen, size: 24 * s),
                              ),
                      ),
                    ),
                    SizedBox(width: 10 * s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Room Admin',
                            style: GoogleFonts.inter(
                              fontSize: 10 * s,
                              color: Colors.white54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 2 * s),
                          Text(
                            _adminName,
                            style: GoogleFonts.inter(
                              fontSize: 14 * s,
                              fontWeight: FontWeight.w700,
                              color: themeGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Room Status',
                          style: GoogleFonts.inter(
                            fontSize: 10 * s,
                            color: Colors.white54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4 * s),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10 * s,
                            vertical: 4 * s,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF262C31),
                            borderRadius: BorderRadius.circular(20 * s),
                            border: Border.all(color: Colors.orangeAccent, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock_rounded,
                                size: 12 * s,
                                color: Colors.orangeAccent,
                              ),
                              SizedBox(width: 4 * s),
                              Text(
                                'Locked',
                                style: GoogleFonts.inter(
                                  fontSize: 10 * s,
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 14 * s),
                Row(
                  children: [
                    Text(
                      'Members',
                      style: GoogleFonts.inter(
                        fontSize: 12 * s,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Text(
                      '$_members/$_maxMembers',
                      style: GoogleFonts.outfit(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w700,
                        color: themeGreen,
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Text(
                      'View All',
                      style: GoogleFonts.inter(
                        fontSize: 11 * s,
                        color: themeGreen,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Icon(Icons.chat_bubble_outline, size: 14 * s, color: themeGreen),
                    SizedBox(width: 4 * s),
                    Text(
                      'Group Chat',
                      style: GoogleFonts.inter(
                        fontSize: 11 * s,
                        color: themeGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderBanner(double s) {
    return Container(
      width: double.infinity,
      height: 140 * s,
      color: const Color(0xFF1E2A31),
      alignment: Alignment.center,
      child: Icon(Icons.image_not_supported, color: Colors.white38, size: 40 * s),
    );
  }

  Widget _buildAboutSection(double s, Color cardDark) {
    final keyRules = [
      'Sync your 24DIGI device daily before starting.',
      'Top 3 winners split the weekly pot (10k DIGI point).',
    ];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About this room',
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10 * s),
          Text(
            _rules,
            style: GoogleFonts.inter(
              fontSize: 13 * s,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          SizedBox(height: 14 * s),
          Text(
            'Key Rules',
            style: GoogleFonts.inter(
              fontSize: 13 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6 * s),
          ...keyRules.map(
            (r) => Padding(
              padding: EdgeInsets.only(left: 12 * s, bottom: 4 * s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: GoogleFonts.inter(
                      fontSize: 13 * s,
                      color: Colors.white70,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      r,
                      style: GoogleFonts.inter(
                        fontSize: 13 * s,
                        color: Colors.white70,
                        height: 1.4,
                      ),
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

  Widget _buildApprovalRequired(double s, Color cardDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person_off_rounded,
            size: 32 * s,
            color: Colors.orangeAccent,
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Approval Required',
                  style: GoogleFonts.inter(
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4 * s),
                Text(
                  'This is a private room. Your profile stats will be reviewed by the admin before access is granted.',
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryFeeAndButton(double s, Color themeGreen) {
    if (_isAccepted) {
      return Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 14 * s, horizontal: 16 * s),
            decoration: BoxDecoration(
              color: themeGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12 * s),
              border: Border.all(color: themeGreen, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: themeGreen, size: 24 * s),
                SizedBox(width: 10 * s),
                Text(
                  'Request accepted! You can now access the room from Joined.',
                  style: GoogleFonts.inter(
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_isRejected) {
      return Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 14 * s, horizontal: 16 * s),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12 * s),
              border: Border.all(color: const Color(0xFFE53935), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel, color: const Color(0xFFE53935), size: 24 * s),
                SizedBox(width: 10 * s),
                Text(
                  'Your request was rejected.',
                  style: GoogleFonts.inter(
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF13181D),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: themeGreen.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                '$_entryFee',
                style: GoogleFonts.outfit(
                  fontSize: 16 * s,
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
                  border: Border.all(color: themeGreen, width: 1),
                  color: const Color(0xFF0F2D24),
                ),
                alignment: Alignment.center,
                child: Text(
                  'DP',
                  style: GoogleFonts.outfit(
                    fontSize: 8 * s,
                    fontWeight: FontWeight.w800,
                    color: themeGreen,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14 * s),
          SizedBox(
            width: double.infinity,
            height: 52 * s,
            child: ElevatedButton(
              onPressed: (_hasPendingRequest || _isSending) ? null : _sendRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeGreen,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14 * s),
                ),
              ),
              child: _isSending
                  ? SizedBox(
                      width: 24 * s,
                      height: 24 * s,
                      child: const CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : _hasPendingRequest
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, size: 22 * s, color: Colors.black),
                            SizedBox(width: 8 * s),
                            Text(
                              'Sent',
                              style: GoogleFonts.inter(
                                fontSize: 16 * s,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Send a Request',
                          style: GoogleFonts.inter(
                            fontSize: 16 * s,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
