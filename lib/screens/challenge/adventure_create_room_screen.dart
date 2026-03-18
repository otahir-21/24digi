import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/utils/custom_snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';

import '../../services/adventure_service.dart';

/// First design: Adventure Room Creation — profile upload, room name, rules,
/// duration, entry fee, max players, room access, Create Room button.
class AdventureCreateRoomScreen extends StatefulWidget {
  const AdventureCreateRoomScreen({super.key});

  @override
  State<AdventureCreateRoomScreen> createState() =>
      _AdventureCreateRoomScreenState();
}

class _AdventureCreateRoomScreenState extends State<AdventureCreateRoomScreen> {
  final Color themeGreen = const Color(0xFFE0A10A);
  final Color bgDark = const Color(0xFF2E251E);
  final Color fieldBg = const Color(0xFF4A4039);

  File? _profileImage;
  final _roomNameController = TextEditingController();
  final _rulesController = TextEditingController();
  bool _isPublic = true;
  DateTime? _startAt;
  DateTime? _endAt;
  final _feeController = TextEditingController(text: '100');
  final _maxPlayersController = TextEditingController(text: '20');

  // Location and route state
  LatLng? _startPoint;
  LatLng? _endPoint;
  List<LatLng> _routePoints = [];

  bool _isLoading = false;

  @override
  void dispose() {
    _roomNameController.dispose();
    _roomNameController.dispose();
    _rulesController.dispose();
    _feeController.dispose();
    _maxPlayersController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null && mounted) {
      setState(() => _profileImage = File(xFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
                    _buildHiUser(s),
                    SizedBox(height: 20 * s),
                    _buildProfileUpload(s),
                    _buildTapToUpload(s),
                    SizedBox(height: 24 * s),
                    _buildRoomName(s),
                    SizedBox(height: 16 * s),
                    _buildRulesAndObjective(s),
                    SizedBox(height: 16 * s),
                    _buildDuration(s),
                    SizedBox(height: 16 * s),
                    _buildEntryFeeAndMaxPlayers(s),
                    SizedBox(height: 16 * s),
                    _buildRoomAccess(s),
                    SizedBox(height: 16 * s),
                    _buildPickRouteButton(s),
                    SizedBox(height: 28 * s),
                    _buildCreateRoomButton(s),
                    SizedBox(height: 40 * s),
                  ],
                ),
              ),
            ),
          ],
        ),
            if (_isLoading)
              Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: CircularProgressIndicator(color: themeGreen),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHiUser(double s) {
    return Center(
      child: Consumer<AuthProvider>(
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
    );
  }

  Widget _buildProfileUpload(double s) {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: SizedBox(
          width: 120 * s,
          height: 120 * s,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(120 * s, 120 * s),
                painter: _DashedCirclePainter(
                  color: Colors.white24,
                  strokeWidth: 2,
                  gap: 6,
                  dashLength: 8,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4 * s),
                child: Container(
                  width: 112 * s,
                  height: 112 * s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fieldBg,
                  ),
                  child: ClipOval(
                    child: _profileImage != null
                        ? Image.file(_profileImage!, fit: BoxFit.cover)
                        : Icon(
                            Icons.camera_alt_outlined,
                            size: 36 * s,
                            color: Colors.white38,
                          ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 28 * s,
                  height: 28 * s,
                  decoration: BoxDecoration(
                    color: themeGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: bgDark, width: 2),
                  ),
                  child: Icon(Icons.edit, size: 14 * s, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTapToUpload(double s) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 8 * s),
        child: Text(
          'Tap to upload a Photo',
          style: GoogleFonts.inter(
            fontSize: 12 * s,
            color: Colors.white38,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildRoomName(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Room Name',
          style: GoogleFonts.inter(
            fontSize: 13 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8 * s),
        Container(
          height: 48 * s,
          decoration: BoxDecoration(
            color: fieldBg,
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(color: Colors.white12, width: 1),
          ),
          padding: EdgeInsets.symmetric(horizontal: 14 * s),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _roomNameController,
                  style: GoogleFonts.inter(
                    fontSize: 14 * s,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. super running 2026',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14 * s,
                      color: Colors.white38,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14 * s),
                  ),
                ),
              ),
              Icon(Icons.edit_outlined, size: 18 * s, color: Colors.white38),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRulesAndObjective(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rules & Objective',
          style: GoogleFonts.inter(
            fontSize: 13 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8 * s),
        Container(
          constraints: BoxConstraints(minHeight: 100 * s),
          decoration: BoxDecoration(
            color: fieldBg,
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(color: Colors.white12, width: 1),
          ),
          padding: EdgeInsets.all(14 * s),
          child: TextField(
            controller: _rulesController,
            maxLines: 4,
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText:
                  'Describe the winning conditions, allowed activities, and rules for disqualification...',
              hintStyle: GoogleFonts.inter(
                fontSize: 14 * s,
                color: Colors.white38,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDuration(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: GoogleFonts.inter(
            fontSize: 13 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8 * s),
        GestureDetector(
          onTap: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: themeGreen,
                      onPrimary: Colors.black,
                      surface: bgDark,
                      onSurface: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                _startAt = picked.start;
                _endAt = picked.end;
              });
            }
          },
          child: Container(
            height: 48 * s,
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(12 * s),
              border: Border.all(color: Colors.white12, width: 1),
            ),
            padding: EdgeInsets.symmetric(horizontal: 14 * s),
            alignment: Alignment.centerLeft,
            child: Text(
              _startAt != null && _endAt != null
                  ? '${_startAt!.day}/${_startAt!.month}/${_startAt!.year} - ${_endAt!.day}/${_endAt!.month}/${_endAt!.year}'
                  : 'Select start & end dates',
              style: GoogleFonts.inter(
                fontSize: 14 * s,
                color: _startAt != null ? Colors.white : Colors.white38,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEntryFeeAndMaxPlayers(double s) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Entry Fee',
                style: GoogleFonts.inter(
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8 * s),
              Container(
                height: 48 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFF26313A),
                  borderRadius: BorderRadius.circular(12 * s),
                  border: Border.all(color: Colors.white12, width: 1),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14 * s),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _feeController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.outfit(
                          fontSize: 14 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 6 * s),
                    _OpIcon(s: s, themeGreen: themeGreen),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Max Players',
                style: GoogleFonts.inter(
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8 * s),
              Container(
                height: 48 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFF26313A),
                  borderRadius: BorderRadius.circular(12 * s),
                  border: Border.all(color: Colors.white12, width: 1),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14 * s),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _maxPlayersController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.outfit(
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomAccess(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Room Access',
          style: GoogleFonts.inter(
            fontSize: 13 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8 * s),
        Container(
          height: 44 * s,
          decoration: BoxDecoration(
            color: fieldBg,
            borderRadius: BorderRadius.circular(22 * s),
            border: Border.all(color: Colors.white12, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isPublic = true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.all(3 * s),
                    decoration: BoxDecoration(
                      color: _isPublic ? themeGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(20 * s),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Public',
                      style: GoogleFonts.inter(
                        fontSize: 13 * s,
                        fontWeight: FontWeight.w700,
                        color: _isPublic ? Colors.black : Colors.white60,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isPublic = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.all(3 * s),
                    decoration: BoxDecoration(
                      color: !_isPublic ? themeGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(20 * s),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Private',
                      style: GoogleFonts.inter(
                        fontSize: 13 * s,
                        fontWeight: FontWeight.w700,
                        color: !_isPublic ? Colors.black : Colors.white60,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPickRouteButton(double s) {
    final hasRoute = _startPoint != null && _endPoint != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Route (Optional)',
          style: GoogleFonts.inter(
            fontSize: 13 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8 * s),
        GestureDetector(
          onTap: () => _showMapPicker(s),
          child: Container(
            height: 48 * s,
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(12 * s),
              border: Border.all(
                color: hasRoute ? themeGreen : Colors.white12,
                width: 1,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 14 * s),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(
                  Icons.map_outlined,
                  color: hasRoute ? themeGreen : Colors.white38,
                  size: 20 * s,
                ),
                SizedBox(width: 10 * s),
                Expanded(
                  child: Text(
                    hasRoute
                        ? 'Route set: ${_routePoints.length} points'
                        : 'Tap to pick start & end points on map',
                    style: GoogleFonts.inter(
                      fontSize: 14 * s,
                      color: hasRoute ? Colors.white : Colors.white38,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (hasRoute)
                  Icon(Icons.check_circle, color: themeGreen, size: 20 * s),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showMapPicker(double s) async {
    final result = await showDialog<_RouteResult>(
      context: context,
      builder: (context) => _MapPickerDialog(
        initialStart: _startPoint,
        initialEnd: _endPoint,
      ),
    );

    if (result != null) {
      setState(() {
        _startPoint = result.start;
        _endPoint = result.end;
        _routePoints = result.routePoints;
      });
    }
  }

  Widget _buildCreateRoomButton(double s) {
    return SizedBox(
      width: double.infinity,
      height: 52 * s,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createRoom,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeGreen,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14 * s),
          ),
        ),
        child: Text(
          'Create Room',
          style: GoogleFonts.inter(
            fontSize: 16 * s,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Future<void> _createRoom() async {
    final name = _roomNameController.text.trim();
    final rules = _rulesController.text.trim();
    if (name.isEmpty) {
      CustomSnackBar.show(context, message: 'Please enter a room name.', isError: true, isAdventure: true);
      return;
    }

    final auth = context.read<AuthProvider>();
    final userId = auth.firebaseUser?.uid;
    if (userId == null) return;

    final fee = int.tryParse(_feeController.text) ?? 100;
    final maxPlayers = int.tryParse(_maxPlayersController.text) ?? 20;

    // Convert route points to the format expected by Firestore
    final List<Map<String, double>>? routePolyline = _routePoints.isNotEmpty
        ? _routePoints.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList()
        : null;

    // Use start point as the room location, or default to Dubai
    final double? locationLat = _startPoint?.latitude;
    final double? locationLng = _startPoint?.longitude;

    setState(() => _isLoading = true);
    try {
      await AdventureService().createAdventureRoom(
        adminId: userId,
        adminName: auth.profile?.name ?? 'Admin',
        adminAvatar: auth.profile?.profileImage ?? '',
        name: name,
        rules: rules,
        startAt: _startAt,
        endAt: _endAt,
        entryFee: fee,
        maxPlayers: maxPlayers,
        isPublic: _isPublic,
        imageFile: _profileImage,
        locationLat: locationLat,
        locationLng: locationLng,
        routePolyline: routePolyline,
      );
      if (mounted) {
        Navigator.pop(context);
        CustomSnackBar.show(context, message: 'Room created successfully!', isAdventure: true);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(context, message: 'Failed to create room: $e', isError: true, isAdventure: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Data class for route result
class _RouteResult {
  final LatLng start;
  final LatLng end;
  final List<LatLng> routePoints;

  _RouteResult({required this.start, required this.end, required this.routePoints});
}

// Simple map picker dialog for selecting start and end points
class _MapPickerDialog extends StatefulWidget {
  final LatLng? initialStart;
  final LatLng? initialEnd;

  const _MapPickerDialog({this.initialStart, this.initialEnd});

  @override
  State<_MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<_MapPickerDialog> {
  LatLng? _start;
  LatLng? _end;
  int _step = 0; // 0 = pick start, 1 = pick end

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
    if (_start != null && _end == null) {
      _step = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final target = _start ?? const LatLng(25.2048, 55.2708); // Default to Dubai

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        height: 500,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1813),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      _step == 0 ? 'Tap to set START point' : 'Tap to set END point',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (_step == 1)
                    TextButton(
                      onPressed: () => setState(() => _step = 0),
                      child: Text(
                        'Back',
                        style: GoogleFonts.inter(color: const Color(0xFFE0A10A)),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
            // Map
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: target,
                    zoom: 14,
                  ),
                  onTap: (latLng) {
                    setState(() {
                      if (_step == 0) {
                        _start = latLng;
                        _step = 1;
                      } else {
                        _end = latLng;
                      }
                    });
                  },
                  markers: {
                    if (_start != null)
                      Marker(
                        markerId: const MarkerId('start'),
                        position: _start!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                        infoWindow: const InfoWindow(title: 'Start'),
                      ),
                    if (_end != null)
                      Marker(
                        markerId: const MarkerId('end'),
                        position: _end!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                        infoWindow: const InfoWindow(title: 'End'),
                      ),
                  },
                  polylines: {
                    if (_start != null && _end != null)
                      Polyline(
                        polylineId: const PolylineId('preview'),
                        color: const Color(0xFF00F0FF),
                        width: 4,
                        points: [_start!, _end!],
                        geodesic: true,
                      ),
                  },
                ),
              ),
            ),
            // Bottom actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _start == null
                          ? 'Tap on map to place start marker'
                          : _end == null
                              ? 'Tap on map to place end marker'
                              : 'Route ready!',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  if (_start != null && _end != null)
                    ElevatedButton(
                      onPressed: () {
                        // Generate intermediate points for the route
                        final points = _interpolatePoints(_start!, _end!, 10);
                        Navigator.pop(
                          context,
                          _RouteResult(start: _start!, end: _end!, routePoints: points),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE0A10A),
                        foregroundColor: Colors.black,
                      ),
                      child: Text(
                        'Confirm',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
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

  // Generate interpolated points between start and end
  List<LatLng> _interpolatePoints(LatLng start, LatLng end, int segments) {
    final List<LatLng> points = [start];
    for (int i = 1; i < segments; i++) {
      final t = i / segments;
      points.add(LatLng(
        start.latitude + (end.latitude - start.latitude) * t,
        start.longitude + (end.longitude - start.longitude) * t,
      ));
    }
    points.add(end);
    return points;
  }
}

class _OpIcon extends StatelessWidget {
  final double s;
  final Color themeGreen;

  const _OpIcon({required this.s, required this.themeGreen});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22 * s,
      height: 22 * s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: themeGreen, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        'OP',
        style: GoogleFonts.outfit(
          fontSize: 8 * s,
          fontWeight: FontWeight.w800,
          color: themeGreen,
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;

  _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.dashLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const twoPi = 2 * 3.14159265359;
    final dashAngle = dashLength / radius;
    final gapAngle = gap / radius;
    var angle = 0.0;
    while (angle < twoPi) {
      final endAngle = (angle + dashAngle).clamp(0.0, twoPi);
      if (endAngle > angle) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          angle,
          endAngle - angle,
          false,
          paint,
        );
      }
      angle += dashAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
