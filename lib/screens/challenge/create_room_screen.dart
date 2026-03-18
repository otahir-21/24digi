import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import '../../services/challenge_service.dart';

/// First design: Private Room Creation — profile upload, room name, rules,
/// duration, entry fee, max players, room access, Create Room button.
class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final Color themeGreen = const Color(0xFF00FF88);
  final Color bgDark = const Color(0xFF0D1217);
  final Color fieldBg = const Color(0xFF1E2A31);

  File? _profileImage;
  final _roomNameController = TextEditingController();
  final _rulesController = TextEditingController();
  final _entryFeeController = TextEditingController(text: '100');
  final _maxPlayersController = TextEditingController(text: '20');
  final _prizeAmountController = TextEditingController(text: '0');
  DateTimeRange? _dateRange;
  bool _isPublic = true;
  bool _isLoading = false;

  // Location and route state (like Adventure)
  LatLng? _startPoint;
  LatLng? _endPoint;
  List<LatLng> _routePoints = [];

  @override
  void dispose() {
    _roomNameController.dispose();
    _rulesController.dispose();
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
                    _buildEntryFeeMaxPlayersAndPrize(s),
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
              lastDate: DateTime.now().add(const Duration(days: 90)),
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
              setState(() => _dateRange = picked);
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
              _dateRange == null
                  ? 'Select start & end dates'
                  : '${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}',
              style: GoogleFonts.inter(
                fontSize: 14 * s,
                color: _dateRange == null ? Colors.white38 : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEntryFeeMaxPlayersAndPrize(double s) {
    return Column(
      children: [
        Row(
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
                    child: TextField(
                      controller: _entryFeeController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.outfit(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        suffixIconConstraints: BoxConstraints(maxHeight: 22 * s),
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(left: 6 * s),
                          child: _OpIcon(s: s, themeGreen: themeGreen),
                        ),
                      ),
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
                    child: TextField(
                      controller: _maxPlayersController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.outfit(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: '20',
                        hintStyle: GoogleFonts.inter(color: Colors.white24),
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
        SizedBox(height: 16 * s),
        // Prize Amount Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prize Amount (DIGI Points)',
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
              child: TextField(
                controller: _prizeAmountController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.outfit(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter prize amount',
                  hintStyle: GoogleFonts.inter(color: Colors.white24),
                  border: InputBorder.none,
                  isDense: true,
                  suffixIconConstraints: BoxConstraints(maxHeight: 22 * s),
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(left: 6 * s),
                    child: Container(
                      width: 22 * s,
                      height: 22 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: themeGreen, width: 1.5),
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
                  ),
                ),
              ),
            ),
          ],
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
        onPressed: _isLoading ? null : _handleCreateRoom,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeGreen,
          foregroundColor: Colors.black,
          disabledBackgroundColor: themeGreen.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14 * s),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20 * s,
                width: 20 * s,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Text(
                'Create Room',
                style: GoogleFonts.inter(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }

  Future<void> _handleCreateRoom() async {
    final name = _roomNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a room name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();
      final userId = auth.firebaseUser?.uid;
      final userName = auth.profile?.name ?? 'User';
      final avatar = auth.profile?.profileImage ?? '';

      if (userId == null) throw Exception('User not logged in');

      await ChallengeService().createChallengeRoom(
        adminId: userId,
        adminName: userName,
        adminAvatar: avatar,
        name: name,
        rules: _rulesController.text.trim(),
        startAt: _dateRange?.start,
        endAt: _dateRange?.end,
        entryFee: int.tryParse(_entryFeeController.text) ?? 100,
        maxPlayers: int.tryParse(_maxPlayersController.text) ?? 20,
        prizeAmount: int.tryParse(_prizeAmountController.text) ?? 0,
        isPublic: _isPublic,
        imageFile: _profileImage,
        locationLat: _startPoint?.latitude,
        locationLng: _startPoint?.longitude,
        routePolyline: _routePoints.isNotEmpty
            ? _routePoints.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList()
            : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _RouteResult {
  final LatLng start;
  final LatLng end;
  final List<LatLng> routePoints;

  _RouteResult({required this.start, required this.end, required this.routePoints});
}

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
  int _step = 0;

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
    final target = _start ?? const LatLng(25.2048, 55.2708);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        height: 500,
        decoration: BoxDecoration(
          color: const Color(0xFF0D1217),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
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
                        style: GoogleFonts.inter(color: const Color(0xFF00FF88)),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
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
                        color: const Color(0xFF00FF88),
                        width: 6,
                        points: [_start!, _end!],
                        geodesic: true,
                        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
                      ),
                  },
                ),
              ),
            ),
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
                        final points = _interpolatePoints(_start!, _end!, 10);
                        Navigator.pop(
                          context,
                          _RouteResult(start: _start!, end: _end!, routePoints: points),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FF88),
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
