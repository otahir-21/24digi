import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/utils/custom_snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import '../../services/challenge_service.dart';
import '../../services/adventure_service.dart';
import 'group_chat_screen.dart';

/// My Room section: search, Requests (if any), Administrators (OWNER/ADMIN), Members.
/// Owner and admins can accept/reject requests, make admin, remove member.
class RoomMembersScreen extends StatefulWidget {
  final String roomId;
  final String roomName;
  final bool isAdventure;

  const RoomMembersScreen({
    super.key,
    required this.roomId,
    this.roomName = 'Elite Runners Club',
    this.isAdventure = false,
  });

  @override
  State<RoomMembersScreen> createState() => _RoomMembersScreenState();
}

class _RoomMembersScreenState extends State<RoomMembersScreen> {
  late Color themeColor;
  final Color bgDark = const Color(0xFF0D1217);
  int? _removeIndex;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    themeColor = widget.isAdventure ? const Color(0xFFE0A10A) : const Color(0xFF00FF88);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final userId = context.watch<AuthProvider>().firebaseUser?.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: ((widget.isAdventure ? AdventureService() : ChallengeService()) as dynamic).getRoomStream(widget.roomId),
      builder: (context, roomSnapshot) {
        if (!roomSnapshot.hasData || !roomSnapshot.data!.exists) {
          return Scaffold(
            backgroundColor: bgDark,
            body: Center(
              child: CircularProgressIndicator(color: themeColor),
            ),
          );
        }
        final roomData = roomSnapshot.data!.data() as Map<String, dynamic>? ?? {};
        final adminId = roomData['admin_id']?.toString();
        final adminIdsRaw = roomData['admin_ids'];
        final adminIds = adminIdsRaw != null ? List<String>.from(adminIdsRaw) : <String>[];
        if (adminId != null && !adminIds.contains(adminId)) {
          adminIds.insert(0, adminId);
        }
        final isOwner = userId == adminId;
        final isAdmin = isOwner || (userId != null && adminIds.contains(userId));
        final canManage = isAdmin;

        return Scaffold(
          backgroundColor: bgDark,
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
                        _buildGreeting(s),
                        SizedBox(height: 12 * s),
                        _buildSearchBar(s),
                        SizedBox(height: 12 * s),
                        _buildGroupChatButton(s),
                        SizedBox(height: 20 * s),
                        StreamBuilder<QuerySnapshot>(
                          stream: ((widget.isAdventure ? AdventureService() : ChallengeService()) as dynamic).getJoinRequestsStream(widget.roomId),
                          builder: (context, reqSnapshot) {
                            final requests = reqSnapshot.hasData
                                ? reqSnapshot.data!.docs
                                : <QueryDocumentSnapshot>[];
                            if (requests.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: EdgeInsets.only(bottom: 24 * s),
                              child: _buildRequestsSection(
                                s,
                                requests,
                                canManage,
                              ),
                            );
                          },
                        ),
                        _buildSectionTitle(s, 'Administrators'),
                        SizedBox(height: 12 * s),
                        StreamBuilder<QuerySnapshot>(
                          stream: ((widget.isAdventure ? AdventureService() : ChallengeService()) as dynamic).getRoomParticipantsStream(widget.roomId),
                          builder: (context, partSnapshot) {
                            if (!partSnapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            final participants = partSnapshot.data!.docs;
                            final admins = _buildAdminList(
                              participants,
                              adminId,
                              adminIds,
                              roomData,
                            );
                            return Column(
                              children: admins
                                  .map((a) => _buildAdminRow(
                                        s,
                                        a.name,
                                        a.level,
                                        a.cls,
                                        a.tag,
                                        a.avatarUrl,
                                        a.userId,
                                        canManage,
                                        isOwner,
                                        adminId,
                                        adminIds,
                                      ))
                                  .toList(),
                            );
                          },
                        ),
                        SizedBox(height: 24 * s),
                        _buildMembersHeader(s),
                        SizedBox(height: 12 * s),
                        StreamBuilder<QuerySnapshot>(
                          stream: ((widget.isAdventure ? AdventureService() : ChallengeService()) as dynamic).getRoomParticipantsStream(widget.roomId),
                          builder: (context, partSnapshot) {
                            if (!partSnapshot.hasData) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24 * s),
                                  child: Text(
                                    'Loading more players....',
                                    style: GoogleFonts.inter(
                                      fontSize: 12 * s,
                                      color: Colors.white38,
                                    ),
                                  ),
                                ),
                              );
                            }
                            final participants = partSnapshot.data!.docs;
                            final adminId = roomData['admin_id']?.toString();
                            final adminIdsRaw = roomData['admin_ids'];
                            final adminIds = adminIdsRaw != null ? List<String>.from(adminIdsRaw) : <String>[];
                            if (adminId != null && !adminIds.contains(adminId)) {
                              adminIds.insert(0, adminId);
                            }
                            final members = participants.where((d) {
                              final data = d.data() as Map<String, dynamic>?;
                              final id = data?['user_id']?.toString();
                              return id != null && !adminIds.contains(id);
                            }).toList();
                            final filtered = _searchQuery != null && _searchQuery!.isNotEmpty
                                ? members.where((d) {
                                    final data = d.data() as Map<String, dynamic>?;
                                    final name = (data?['display_name'] ?? '').toString().toLowerCase();
                                    return name.contains(_searchQuery!.toLowerCase());
                                  }).toList()
                                : members;
                            return Column(
                              children: filtered.asMap().entries.map((e) {
                                final d = e.value.data() as Map<String, dynamic>? ?? {};
                                return _buildMemberRow(
                                  s,
                                  e.key,
                                  d['display_name']?.toString() ?? 'Member',
                                  d['rank']?.toString() ?? '0',
                                  'Elite class',
                                  d['avatar_url']?.toString(),
                                  d['user_id']?.toString(),
                                  canManage,
                                  isOwner,
                                  adminIds,
                                );
                              }).toList(),
                            );
                          },
                        ),
                        SizedBox(height: 24 * s),
                        Center(
                          child: Text(
                            'Loading more players....',
                            style: GoogleFonts.inter(
                              fontSize: 12 * s,
                              color: Colors.white38,
                            ),
                          ),
                        ),
                        SizedBox(height: 40 * s),
                      ],
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

  Widget _buildSearchBar(double s) {
    return Container(
      height: 44 * s,
      padding: EdgeInsets.symmetric(horizontal: 14 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A31),
        borderRadius: BorderRadius.circular(22 * s),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 20 * s, color: Colors.white38),
          SizedBox(width: 10 * s),
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.isEmpty ? null : v),
              style: GoogleFonts.inter(fontSize: 14 * s, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Find a player by name or rank...',
                hintStyle: GoogleFonts.inter(fontSize: 14 * s, color: Colors.white38),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupChatButton(double s) {
    return SizedBox(
      width: double.infinity,
      height: 44 * s,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GroupChatScreen(
                roomId: widget.roomId,
                roomName: widget.roomName,
                isAdventure: widget.isAdventure,
              ),
            ),
          );
        },
        icon: Icon(Icons.chat_bubble_outline, size: 20 * s, color: themeColor),
        label: Text(
          'Group Chat',
          style: GoogleFonts.inter(fontSize: 14 * s, fontWeight: FontWeight.w700, color: themeColor),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: themeColor,
          side: BorderSide(color: themeColor, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * s)),
        ),
      ),
    );
  }

  List<_AdminEntry> _buildAdminList(
    List<QueryDocumentSnapshot> participants,
    String? ownerId,
    List<String> adminIds,
    Map<String, dynamic> roomData,
  ) {
    final entries = <_AdminEntry>[];
    if (ownerId != null) {
      final ownerDoc = participants.where((d) => d.id == ownerId).toList();
      final data = ownerDoc.isNotEmpty ? ownerDoc.first.data() as Map<String, dynamic>? : null;
      entries.add(_AdminEntry(
        userId: ownerId,
        name: data?['display_name']?.toString() ?? roomData['admin_display_name']?.toString() ?? 'Owner',
        level: 'Level 99',
        cls: 'Elite class',
        tag: 'OWNER',
        avatarUrl: data?['avatar_url']?.toString() ?? roomData['admin_avatar_url']?.toString(),
      ));
    }
    for (final id in adminIds) {
      if (id == ownerId) continue;
      final docList = participants.where((d) => d.id == id).toList();
      final data = docList.isNotEmpty ? docList.first.data() as Map<String, dynamic>? : null;
      entries.add(_AdminEntry(
        userId: id,
        name: data?['display_name']?.toString() ?? 'Admin',
        level: 'Level 99',
        cls: 'Elite class',
        tag: 'ADMIN',
        avatarUrl: data?['avatar_url']?.toString(),
      ));
    }
    return entries;
  }

  Widget _buildRequestsSection(
    double s,
    List<QueryDocumentSnapshot> requests,
    bool canManage,
  ) {
    final avatars = requests.take(3).map((d) {
      final data = d.data() as Map<String, dynamic>;
      return data['avatar_url']?.toString();
    }).toList();
    final extra = requests.length > 3 ? requests.length - 3 : 0;

    return GestureDetector(
      onTap: canManage
          ? () => _showRequestsSheet(s, requests)
          : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 10 * s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14 * s),
          border: Border.all(
            color: themeColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
          gradient: LinearGradient(
            colors: [
              themeColor.withValues(alpha: 0.1),
              const Color(0xFFFFD700).withValues(alpha: 0.08),
              const Color(0xFFFFB74D).withValues(alpha: 0.08),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 70 * s,
              height: 36 * s,
              child: Stack(
                children: [
                  for (int i = 0; i < avatars.length; i++)
                    Positioned(
                      left: (i * 18.0) * s,
                      child: _avatar(s, 32, avatars[i]),
                    ),
                ],
              ),
            ),
            if (extra > 0) ...[
              SizedBox(width: 6 * s),
              Container(
                width: 28 * s,
                height: 28 * s,
                decoration: BoxDecoration(
                  color: themeColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$extra',
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
            SizedBox(width: 10 * s),
            Text(
              'Requests',
              style: GoogleFonts.inter(
                fontSize: 14 * s,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestsSheet(double s, List<QueryDocumentSnapshot> requests) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2A31),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20 * s)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16 * s),
              child: Text(
                'Join requests',
                style: GoogleFonts.inter(
                  fontSize: 18 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: EdgeInsets.symmetric(horizontal: 16 * s),
                itemCount: requests.length,
                itemBuilder: (_, i) {
                  final doc = requests[i];
                  final data = doc.data() as Map<String, dynamic>;
                  final requestUserId = data['user_id']?.toString() ?? doc.id;
                  final name = data['display_name']?.toString() ?? 'User';
                  final avatarUrl = data['avatar_url']?.toString();
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12 * s),
                    child: Row(
                      children: [
                        _avatar(s, 44, avatarUrl),
                        SizedBox(width: 12 * s),
                        Expanded(
                          child: Text(
                            name,
                            style: GoogleFonts.inter(
                              fontSize: 15 * s,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              await ((widget.isAdventure ? AdventureService() : ChallengeService()) as dynamic).rejectJoinRequest(
                                roomId: widget.roomId,
                                requestUserId: requestUserId,
                              );
                              if (context.mounted) Navigator.pop(ctx);
                            } catch (e) {
                              if (context.mounted) {
                                CustomSnackBar.show(context, message: 'Failed: $e', isError: true, isAdventure: widget.isAdventure);
                              }
                            }
                          },
                          child: Text(
                            'Reject',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFE53935),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 8 * s),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await ((widget.isAdventure ? AdventureService() : ChallengeService()) as dynamic).acceptJoinRequest(
                                roomId: widget.roomId,
                                requestUserId: requestUserId,
                                displayName: name,
                                avatarUrl: avatarUrl ?? '',
                              );
                              if (context.mounted) {
                                Navigator.pop(ctx);
                                CustomSnackBar.show(context, message: 'Request accepted', isAdventure: widget.isAdventure);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                CustomSnackBar.show(context, message: 'Failed: $e', isError: true, isAdventure: widget.isAdventure);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Accept'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(double s, double size, [String? imageUrl]) {
    return Container(
      width: size * s,
      height: size * s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: bgDark, width: 2),
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl.startsWith('http')
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.person, color: themeColor, size: size * 0.5 * s),
              )
            : Image.asset(
                'assets/fonts/male.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.person, color: themeColor, size: size * 0.5 * s),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(double s, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14 * s,
        fontWeight: FontWeight.w700,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildAdminRow(
    double s,
    String name,
    String level,
    String cls,
    String tag,
    String? avatarUrl,
    String? userId,
    bool canManage,
    bool isOwner,
    String? ownerId,
    List<String> adminIds,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12 * s),
      child: Row(
        children: [
          _avatar(s, 44, avatarUrl),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2 * s),
                Text(
                  '$level • $cls',
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 4 * s),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12 * s),
              border: Border.all(color: themeColor, width: 1),
            ),
            child: Text(
              tag,
              style: GoogleFonts.inter(
                fontSize: 10 * s,
                fontWeight: FontWeight.w800,
                color: themeColor,
              ),
            ),
          ),
          if (canManage && userId != null && userId != ownerId)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.white54, size: 22 * s),
              color: const Color(0xFF1E2A31),
              onSelected: (v) {
                if (v == 'remove_admin' && isOwner) {
                  _confirmRemoveAdmin(userId);
                }
              },
              itemBuilder: (_) => [
                if (isOwner && tag == 'ADMIN')
                  const PopupMenuItem(value: 'remove_admin', child: Text('Remove from admins')),
              ],
            )
          else
            SizedBox(width: 22 * s),
        ],
      ),
    );
  }

  Future<void> _confirmRemoveAdmin(String userId) async {
    // Optional: implement remove from admin_ids (would need a new Firestore method)
  }

  Widget _buildMembersHeader(double s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle(s, 'Members'),
        GestureDetector(
          onTap: () {},
          child: Text(
            'Sort by level',
            style: GoogleFonts.inter(
              fontSize: 13 * s,
              fontWeight: FontWeight.w600,
              color: themeColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberRow(
    double s,
    int index,
    String name,
    String level,
    String cls,
    String? avatarUrl,
    String? memberUserId,
    bool canManage,
    bool isOwner,
    List<String> adminIds,
  ) {
    final showRemove = _removeIndex == index;

    return Padding(
      padding: EdgeInsets.only(bottom: 12 * s),
      child: Row(
        children: [
          _avatar(s, 44, avatarUrl),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2 * s),
                Text(
                  'Level $level • $cls',
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          if (showRemove && memberUserId != null)
            GestureDetector(
              onTap: () async {
                setState(() => _removeIndex = null);
                try {
                  await ((widget.isAdventure ? AdventureService() : ChallengeService()) as dynamic).removeRoomMember(
                    roomId: widget.roomId,
                    userId: memberUserId,
                  );
                  if (mounted) {
                    CustomSnackBar.show(context, message: 'Member removed', isAdventure: widget.isAdventure);
                  }
                } catch (e) {
                  if (mounted) {
                    CustomSnackBar.show(context, message: 'Failed: $e', isError: true, isAdventure: widget.isAdventure);
                  }
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 8 * s),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10 * s),
                  border: Border.all(color: const Color(0xFFE53935), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline, color: const Color(0xFFE53935), size: 18 * s),
                    SizedBox(width: 4 * s),
                    Text(
                      'Remove',
                      style: GoogleFonts.inter(
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE53935),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (canManage && memberUserId != null)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.white54, size: 22 * s),
              color: const Color(0xFF1E2A31),
              onSelected: (v) {
                if (v == 'remove') {
                  setState(() => _removeIndex = index);
                } else if (v == 'make_admin' && isOwner) {
                  _makeAdmin(memberUserId);
                }
              },
              itemBuilder: (_) => [
                if (isOwner)
                  const PopupMenuItem(value: 'make_admin', child: Text('Make admin')),
                const PopupMenuItem(value: 'remove', child: Text('Remove')),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _makeAdmin(String userId) async {
    try {
      await ((widget.isAdventure ? AdventureService() : ChallengeService()) as dynamic).addRoomAdmin(roomId: widget.roomId, userId: userId);
      if (mounted) {
        CustomSnackBar.show(context, message: 'User is now an admin', isAdventure: widget.isAdventure);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(context, message: 'Failed: $e', isError: true, isAdventure: widget.isAdventure);
      }
    }
  }
}

class _AdminEntry {
  final String userId;
  final String name;
  final String level;
  final String cls;
  final String tag;
  final String? avatarUrl;

  _AdminEntry({
    required this.userId,
    required this.name,
    required this.level,
    required this.cls,
    required this.tag,
    this.avatarUrl,
  });
}
