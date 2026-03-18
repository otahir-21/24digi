import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'adventure_invite_screen.dart';
import 'share_activity_card_screen.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import 'room_members_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/adventure_service.dart';
import 'competition_system_alert_screen.dart';

enum _MapTab { info, tools, group, safety }

class AdventureRoomScreen extends StatefulWidget {
  const AdventureRoomScreen({
    super.key,
    required this.roomId,
    this.roomName = 'Adventure Map',
    this.isLocked = false,
  });

  final String roomId;
  final String roomName;
  final bool isLocked;

  @override
  State<AdventureRoomScreen> createState() => _AdventureRoomScreenState();
}

class _AdventureRoomScreenState extends State<AdventureRoomScreen> {
  static const Color _panelBorder = Color(0xFFE0A10A);
  static const Color _gold = Color(0xFFE0A10A);
  static const Color _textDim = Color(0xFF9F958C);

  _MapTab _selectedTab = _MapTab.info;
  bool _toolsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1813),
      body: SafeArea(
        child: Stack(
          children: [
            // Map Base - Desert themed
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20 * s),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: AdventureService().getRoomStream(widget.roomId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Image.asset(
                        'assets/challenge/challenge_map.png',
                        fit: BoxFit.cover,
                      );
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final locationLat = (data['location_lat'] as num?)?.toDouble();
                    final locationLng = (data['location_lng'] as num?)?.toDouble();
                    final routePolyline = data['route_polyline'] as List<dynamic>?;

                    final target = LatLng(
                      locationLat ?? 25.2048,
                      locationLng ?? 55.2708,
                    );

                    final List<LatLng> polylinePoints = [];
                    if (routePolyline != null && routePolyline.isNotEmpty) {
                      for (final point in routePolyline) {
                        if (point is Map<String, dynamic>) {
                          final lat = (point['lat'] as num?)?.toDouble();
                          final lng = (point['lng'] as num?)?.toDouble();
                          if (lat != null && lng != null) {
                            polylinePoints.add(LatLng(lat, lng));
                          }
                        }
                      }
                    }

                    final Set<Marker> markers = {};
                    if (polylinePoints.isNotEmpty) {
                      markers.add(
                        Marker(
                          markerId: const MarkerId('start'),
                          position: polylinePoints.first,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen,
                          ),
                          infoWindow: const InfoWindow(title: 'Start'),
                        ),
                      );
                      markers.add(
                        Marker(
                          markerId: const MarkerId('end'),
                          position: polylinePoints.last,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed,
                          ),
                          infoWindow: const InfoWindow(title: 'End'),
                        ),
                      );
                    }

                    final Set<Polyline> polylines = {};
                    if (polylinePoints.isNotEmpty) {
                      polylines.add(
                        Polyline(
                          polylineId: const PolylineId('route'),
                          color: const Color(0xFFE0A10A), // Gold/desert color
                          width: 5,
                          points: polylinePoints,
                          geodesic: true,
                        ),
                      );
                    }

                    return GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: target,
                        zoom: 14,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapType: MapType.terrain, // Desert/brown terrain style
                      markers: markers,
                      polylines: polylines,
                    );
                  },
                ),
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
        Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final name = auth.profile?.name?.trim();
            final greeting = (name != null && name.isNotEmpty)
                ? 'HI, ${name.toUpperCase()}'
                : 'HI';
            return Text(
              greeting,
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 10 * s,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.0,
              ),
            );
          },
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
        _controlButton(s, Icons.straighten_outlined),
        SizedBox(height: 8 * s),
        _controlButton(s, Icons.explore_outlined),
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
        border: Border.all(
          color: _panelBorder.withValues(alpha: 0.5),
          width: 1.5,
        ),
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
    return StreamBuilder<DocumentSnapshot>(
      stream: AdventureService().getRoomStream(widget.roomId),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final distance = data?['distance_km']?.toString() ?? '--';
        final duration = data?['duration_minutes'] ?? 0;
        final hours = (duration ~/ 60).toString().padLeft(2, '0');
        final mins = (duration % 60).toString().padLeft(2, '0');
        final durationStr = duration > 0 ? '$hours:$mins' : '--:--';
        final elevation = data?['elevation_gain']?.toString() ?? '--';
        
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _metricCard(s, 'DISTANCE', distance, 'km')),
                SizedBox(width: 8 * s),
                Expanded(child: _metricCard(s, 'WEATHER', durationStr, 'time')),
                SizedBox(width: 8 * s),
                Expanded(child: _metricCard(s, 'ELEV', elevation, 'm')),
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
                          builder: (_) => AdventureInviteScreen(
                            roomName: widget.roomName,
                            roomId: widget.roomId,
                          ),
                        ),
                      );
                    },
                    child: _actionPill(s, 'Invite Friends'),
                  ),
                ),
                SizedBox(width: 8 * s),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ShareActivityCardScreen(roomName: widget.roomName),
                        ),
                      );
                    },
                    child: _actionPill(s, 'Share Live'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10 * s),
            GestureDetector(
              onTap: () async {
                final confirm = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CompetitionSystemAlertScreen(
                      alertType: AlertType.quit,
                      competitionName: widget.roomName,
                    ),
                  ),
                );
                if (confirm == true && mounted) {
                  final auth = context.read<AuthProvider>();
                  final userId = auth.firebaseUser?.uid;
                  if (userId != null) {
                    await AdventureService()
                        .removeRoomMember(roomId: widget.roomId, userId: userId);
                    if (mounted) {
                      Navigator.pop(context);
                      _showCustomSnackBar(context, 'Successfully left the adventure');
                    }
                  }
                }
              },
              child: _actionPill(s, 'Quit Adventure', isQuit: true),
            ),
          ],
        );
      },
    );
  }

  Widget _metricCard(double s, String title, String value, String unit) {
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(
          color: _panelBorder.withValues(alpha: 0.3),
          width: 1,
        ),
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

  Widget _actionPill(double s, String label, {bool isQuit = false}) {
    return Container(
      height: 28 * s,
      decoration: BoxDecoration(
        color: isQuit ? Colors.redAccent.withValues(alpha: 0.1) : Colors.black26,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isQuit
              ? Colors.redAccent.withValues(alpha: 0.5)
              : _panelBorder.withValues(alpha: 0.5),
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

  // TOOLS TAB - Single line with All button, expands on click
  Widget _buildToolsContent(double s) {
    final primaryTools = [
      _ToolItem(const Color(0xFF00FF88), Icons.radio_button_checked, 'Green'),
      _ToolItem(const Color(0xFFFF3B30), Icons.radio_button_checked, 'Red'),
      _ToolItem(Colors.white70, Icons.straighten, 'Ruler'),
      _ToolItem(const Color(0xFF00C8FF), Icons.location_on, 'Point'),
    ];

    final secondaryTools = [
      _ToolItem(Colors.white70, Icons.local_parking, 'P'),
      _ToolItem(Colors.white70, Icons.change_history, ''),
      _ToolItem(Colors.white70, Icons.restaurant, ''),
      _ToolItem(Colors.white70, Icons.shopping_basket, ''),
      _ToolItem(Colors.white70, Icons.pets, ''),
      _ToolItem(Colors.white70, Icons.local_fire_department, ''),
      _ToolItem(Colors.white70, Icons.forest, ''),
      _ToolItem(Colors.white70, Icons.home, ''),
      _ToolItem(Colors.white70, Icons.cell_tower, ''),
      _ToolItem(Colors.white70, Icons.warning_amber, ''),
      _ToolItem(Colors.white70, Icons.directions_car, ''),
      _ToolItem(Colors.white70, Icons.water_drop, ''),
    ];

    return Column(
      children: [
        // Top row: Green, Red, Ruler, Point + All button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ...primaryTools.map((t) => _buildToolCircle(s, t.color, t.icon, t.label)),
            GestureDetector(
              onTap: () => setState(() => _toolsExpanded = !_toolsExpanded),
              child: Column(
                children: [
                  Container(
                    width: 56 * s,
                    height: 56 * s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black26,
                      border: Border.all(color: _gold, width: 2),
                    ),
                    child: Icon(
                      _toolsExpanded ? Icons.expand_less : Icons.expand_more,
                      color: _gold,
                      size: 24 * s,
                    ),
                  ),
                  SizedBox(height: 4 * s),
                  Text(
                    _toolsExpanded ? 'Less' : 'All',
                    style: GoogleFonts.inter(
                      fontSize: 10 * s,
                      color: _gold,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Expandable secondary tools
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              SizedBox(height: 16 * s),
              Wrap(
                spacing: 12 * s,
                runSpacing: 12 * s,
                alignment: WrapAlignment.center,
                children: secondaryTools.map((t) => _buildToolIcon(s, t.icon, t.label)).toList(),
              ),
              SizedBox(height: 16 * s),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAlertButton(s, Icons.water_drop, 'First Aid', const Color(0xFF007AFF)),
                  _buildAlertButton(s, Icons.dangerous, 'Danger', Colors.redAccent),
                  _buildAlertButton(s, Icons.warning_amber, 'Caution', const Color(0xFFFF9500)),
                  _buildAlertButton(s, Icons.emergency, 'SOS', const Color(0xFFFF3B30), isSOS: true),
                ],
              ),
            ],
          ),
          crossFadeState: _toolsExpanded 
              ? CrossFadeState.showSecond 
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildToolCircle(double s, Color color, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        _sendToolAlert(label);
        _showCustomSnackBar(context, '$label tool activated');
      },
      child: Column(
        children: [
          Container(
            width: 56 * s,
            height: 56 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black26,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, color: color, size: 24 * s),
          ),
          SizedBox(height: 4 * s),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10 * s,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolIcon(double s, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        final toolName = label.isNotEmpty ? label : 'Tool';
        _sendToolAlert(toolName);
        _showCustomSnackBar(context, '$toolName tool activated');
      },
      child: Container(
        width: 48 * s,
        height: 48 * s,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2A2520),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: label.isNotEmpty && label.length == 1
            ? Center(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 18 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                  ),
                ),
              )
            : Icon(icon, color: Colors.white70, size: 22 * s),
      ),
    );
  }

  Widget _buildAlertButton(double s, IconData icon, String label, Color color, {bool isSOS = false}) {
    return GestureDetector(
      onTap: () {
        _sendEmergencyAlert(label, isSOS: isSOS);
        _showCustomSnackBar(
          context, 
          isSOS ? '🆘 SOS EMERGENCY sent!' : '$label alert sent to group',
          isError: isSOS,
        );
      },
      child: Column(
        children: [
          Container(
            width: 52 * s,
            height: 52 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
              border: Border.all(color: color, width: isSOS ? 2 : 1),
            ),
            child: Icon(icon, color: color, size: 24 * s),
          ),
          SizedBox(height: 4 * s),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9 * s,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendToolAlert(String toolName) async {
    final auth = context.read<AuthProvider>();
    final userName = auth.profile?.name ?? 'User';

    await AdventureService().sendMessage(widget.roomId, {
      'sender_id': auth.firebaseUser?.uid,
      'sender_display_name': userName,
      'sender_avatar_url': auth.profile?.profileImage ?? '',
      'text': 'Used tool: $toolName',
      'type': 'tool_alert',
    });
  }

  Future<void> _sendEmergencyAlert(String alertType, {bool isSOS = false}) async {
    final auth = context.read<AuthProvider>();
    final userName = auth.profile?.name ?? 'User';

    await AdventureService().sendMessage(widget.roomId, {
      'sender_id': auth.firebaseUser?.uid,
      'sender_display_name': userName,
      'sender_avatar_url': auth.profile?.profileImage ?? '',
      'text': isSOS ? '🆘 EMERGENCY SOS - $userName needs immediate help!' : '$alertType alert from $userName',
      'type': isSOS ? 'sos' : 'alert',
      'priority': isSOS ? 'high' : 'normal',
    });

    if (mounted && isSOS) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1E1813),
          title: Text(
            'SOS EMERGENCY',
            style: GoogleFonts.outfit(
              color: Colors.redAccent,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Your location has been broadcast to all group members.',
            style: GoogleFonts.inter(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: GoogleFonts.inter(color: _gold),
              ),
            ),
          ],
        ),
      );
    }
  }

  // GROUP TAB - Real Firestore data
  Widget _buildGroupContent(double s) {
    return StreamBuilder<DocumentSnapshot>(
      stream: AdventureService().getRoomStream(widget.roomId),
      builder: (context, roomSnapshot) {
        final roomData = roomSnapshot.data?.data() as Map<String, dynamic>?;
        final maxMembers = roomData?['max_members'] ?? 0;
        final members = (roomData?['members'] as List<dynamic>?) ?? [];
        final memberCount = members.length;
        
        return StreamBuilder<QuerySnapshot>(
          stream: AdventureService().getMessagesStream(widget.roomId),
          builder: (context, msgSnapshot) {
            final messages = msgSnapshot.data?.docs ?? [];
            final alertCount = messages.where((m) {
              final d = m.data() as Map<String, dynamic>;
              return d['type'] == 'alert' || d['type'] == 'sos';
            }).length;
            
            return Column(
              children: [
                Row(
                  children: [
                    _GroupStat(s: s, icon: Icons.group, label: 'Members', value: '$memberCount/$maxMembers'),
                    SizedBox(width: 10 * s),
                    _GroupStat(
                      s: s,
                      icon: Icons.warning_amber_rounded,
                      label: 'Alerts',
                      value: '$alertCount Issue${alertCount != 1 ? 's' : ''}',
                      isAlert: alertCount > 0,
                    ),
                  ],
                ),
                SizedBox(height: 10 * s),
                // Show up to 3 members from Firestore
                ...members.take(3).map((member) {
                  final m = member as Map<String, dynamic>;
                  return _MemberCard(
                    s: s,
                    name: m['display_name'] ?? 'Member',
                    status: m['status'] ?? 'Active',
                    isStopped: m['is_stopped'] ?? false,
                  );
                }).toList(),
                SizedBox(height: 8 * s),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RoomMembersScreen(
                          roomId: widget.roomId,
                          roomName: widget.roomName,
                          isAdventure: true,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'View All Members',
                    style: GoogleFonts.inter(
                      fontSize: 11 * s,
                      fontWeight: FontWeight.w700,
                      color: _gold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // SAFETY TAB
  Widget _buildSafetyContent(double s) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            _sendEmergencyAlert('SOS', isSOS: true);
            _showCustomSnackBar(context, '🆘 SOS EMERGENCY sent!', isError: true);
          },
          child: Container(
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
        ),
        SizedBox(height: 12 * s),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _sendSafetyAlert('Rest Stop');
                  _showCustomSnackBar(context, 'Rest Stop location shared');
                },
                child: _SafetyAction(
                  s: s,
                  icon: Icons.coffee,
                  label: 'Rest Stop',
                ),
              ),
            ),
            SizedBox(width: 10 * s),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _sendSafetyAlert('Meeting point');
                  _showCustomSnackBar(context, 'Meeting point shared');
                },
                child: _SafetyAction(
                  s: s,
                  icon: Icons.flag,
                  label: 'Meeting point',
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10 * s),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _sendSafetyAlert('Road');
                  _showCustomSnackBar(context, 'Road condition alert sent');
                },
                child: _SafetyAction(s: s, icon: Icons.alt_route, label: 'Road'),
              ),
            ),
            SizedBox(width: 10 * s),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _sendSafetyAlert('Steep Terrain');
                  _showCustomSnackBar(context, 'Terrain alert sent');
                },
                child: _SafetyAction(
                  s: s,
                  icon: Icons.terrain,
                  label: 'Steep Terrain',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _sendSafetyAlert(String alertType) async {
    final auth = context.read<AuthProvider>();
    final userName = auth.profile?.name ?? 'User';

    await AdventureService().sendMessage(widget.roomId, {
      'sender_id': auth.firebaseUser?.uid,
      'sender_display_name': userName,
      'sender_avatar_url': auth.profile?.profileImage ?? '',
      'text': '📍 Safety update: $alertType from $userName',
      'type': 'safety',
    });
  }

  // Custom Snackbar
  void _showCustomSnackBar(BuildContext context, String message, {bool isError = false}) {
    final s = AppConstants.scale(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Container(
          margin: EdgeInsets.only(bottom: 20 * s),
          padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
          decoration: BoxDecoration(
            color: isError
                ? const Color(0xFFFF3B30).withOpacity(0.9)
                : const Color(0xFF1E1813).withOpacity(0.95),
            borderRadius: BorderRadius.circular(16 * s),
            border: Border.all(
              color: isError ? Colors.white38 : _gold.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                isError ? Icons.warning_rounded : Icons.check_circle_outline,
                color: Colors.white,
                size: 22 * s,
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 14 * s,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Live Chat Section
  Widget _buildLiveChatSection(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6 * s,
              height: 6 * s,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF00FF88),
              ),
            ),
            SizedBox(width: 6 * s),
            Text(
              'Live Chat',
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            _AvatarStack(s: s),
          ],
        ),
        SizedBox(height: 12 * s),
        StreamBuilder<QuerySnapshot>(
          stream: AdventureService().getMessagesStream(widget.roomId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final docs = snapshot.data!.docs;
            final recentDocs = docs.length > 2 ? docs.sublist(docs.length - 2) : docs;

            return Column(
              children: recentDocs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final sentAt = data['sent_at'] as Timestamp?;
                final timeStr = sentAt != null
                    ? DateFormat('HH:mm').format(sentAt.toDate())
                    : '--:--';
                return _ChatMessage(
                  s: s,
                  name: data['sender_display_name'] ?? 'User',
                  time: timeStr,
                  text: data['text'] ?? '',
                );
              }).toList(),
            );
          },
        ),
        SizedBox(height: 12 * s),
        _ChatInput(
          s: s,
          gold: _gold,
          onSend: (text) async {
            final auth = context.read<AuthProvider>();
            await AdventureService().sendMessage(widget.roomId, {
              'sender_id': auth.firebaseUser?.uid,
              'sender_display_name': auth.profile?.name ?? 'User',
              'sender_avatar_url': auth.profile?.profileImage ?? '',
              'text': text,
            });
            _showCustomSnackBar(context, 'Message sent');
          },
        ),
      ],
    );
  }
}

// Helper class for tools
class _ToolItem {
  final Color color;
  final IconData icon;
  final String label;
  _ToolItem(this.color, this.icon, this.label);
}

// Widget Classes
class _GroupStat extends StatelessWidget {
  final double s;
  final IconData icon;
  final String label;
  final String value;
  final bool isAlert;

  const _GroupStat({
    required this.s,
    required this.icon,
    required this.label,
    required this.value,
    this.isAlert = false,
  });

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
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 8 * s,
                    color: Colors.white60,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
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
    );
  }
}

class _MemberCard extends StatelessWidget {
  final double s;
  final String name;
  final String status;
  final bool isStopped;

  const _MemberCard({
    required this.s,
    required this.name,
    required this.status,
    this.isStopped = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8 * s),
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(
          color: isStopped
              ? Colors.redAccent.withValues(alpha: 0.5)
              : Colors.white10,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _Avatar(s: s, size: 28 * s),
          SizedBox(width: 10 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 9 * s,
                    color: isStopped ? Colors.redAccent : Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          if (isStopped)
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 18 * s,
            ),
        ],
      ),
    );
  }
}

class _SafetyAction extends StatelessWidget {
  final double s;
  final IconData icon;
  final String label;

  const _SafetyAction({
    required this.s,
    required this.icon,
    required this.label,
  });

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
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
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

  const _ChatMessage({
    required this.s,
    required this.name,
    required this.time,
    required this.text,
  });

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
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 9 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        time,
                        style: GoogleFonts.inter(
                          fontSize: 8 * s,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4 * s),
                  Text(
                    text,
                    style: GoogleFonts.inter(
                      fontSize: 10 * s,
                      color: Colors.white70,
                      height: 1.3,
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
}

class _ChatInput extends StatefulWidget {
  final double s;
  final Color gold;
  final Function(String) onSend;

  const _ChatInput({
    required this.s,
    required this.gold,
    required this.onSend,
  });

  @override
  State<_ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<_ChatInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSend(_controller.text.trim());
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32 * widget.s,
          height: 32 * widget.s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Icon(
            Icons.settings_outlined,
            size: 16 * widget.s,
            color: Colors.white60,
          ),
        ),
        SizedBox(width: 8 * widget.s),
        Expanded(
          child: Container(
            height: 36 * widget.s,
            padding: EdgeInsets.symmetric(horizontal: 16 * widget.s),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: _controller,
              style: GoogleFonts.inter(
                fontSize: 11 * widget.s,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'Type to group...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 11 * widget.s,
                  color: Colors.white38,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
        ),
        SizedBox(width: 8 * widget.s),
        GestureDetector(
          onTap: _handleSend,
          child: Container(
            width: 36 * widget.s,
            height: 36 * widget.s,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: widget.gold),
            child: Icon(Icons.send, size: 20 * widget.s, color: Colors.black),
          ),
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
                      border: Border.all(
                        color: const Color(0xFF1E1813),
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '+4',
                      style: GoogleFonts.inter(
                        fontSize: 9 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Container(
                    width: 28 * s,
                    height: 28 * s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1E1813),
                        width: 2,
                      ),
                      image: const DecorationImage(
                        image: AssetImage('assets/fonts/male.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          );
        }),
      ),
    );
  }
}
