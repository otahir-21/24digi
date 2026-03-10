import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';

/// First design: Private Room Creation — profile upload, room name, rules,
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
                    _buildEntryFeeAndMaxPlayers(s),
                    SizedBox(height: 16 * s),
                    _buildRoomAccess(s),
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
      child: Text(
        'HI, USER',
        style: GoogleFonts.outfit(
          fontSize: 11 * s,
          fontWeight: FontWeight.w500,
          color: Colors.white60,
          letterSpacing: 1.0,
        ),
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
        Container(
          height: 48 * s,
          decoration: BoxDecoration(
            color: fieldBg,
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(color: Colors.white12, width: 1),
          ),
          padding: EdgeInsets.symmetric(horizontal: 14 * s),
          alignment: Alignment.centerLeft,
          child: Text(
            'Select start & end dates',
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
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
                    Text(
                      '100',
                      style: GoogleFonts.outfit(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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
                    Text(
                      '∞',
                      style: GoogleFonts.outfit(
                        fontSize: 18 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 4 * s),
                    Text(
                      'Unlimited',
                      style: GoogleFonts.inter(
                        fontSize: 13 * s,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
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

  Widget _buildCreateRoomButton(double s) {
    return SizedBox(
      width: double.infinity,
      height: 52 * s,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
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
