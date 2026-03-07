import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import 'competition_list_screen.dart';

class CreateSponsorCompetitionScreen extends StatefulWidget {
  const CreateSponsorCompetitionScreen({super.key});

  @override
  State<CreateSponsorCompetitionScreen> createState() =>
      _CreateSponsorCompetitionScreenState();
}

class _CreateSponsorCompetitionScreenState
    extends State<CreateSponsorCompetitionScreen> {
  final Color themeGreen = const Color(0xFF00FF88);
  final Color bgDark = const Color(0xFF0D1217);
  final Color fieldBg = const Color(0xFF1B2228);

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final option = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF13181D),
        title: Text(
          'Select Image Source',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: themeGreen),
              title: Text(
                'Camera',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context, 0),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: themeGreen),
              title: Text(
                'Gallery',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context, 1),
            ),
          ],
        ),
      ),
    );

    if (option != null) {
      final picked = await _picker.pickImage(
        source: option == 0 ? ImageSource.camera : ImageSource.gallery,
      );
      if (picked != null) {
        setState(() => _imageFile = File(picked.path));
      }
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
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16 * s),
                      _buildHeader(s),
                      SizedBox(height: 32 * s),

                      _buildSectionLabel(s, 'Competition Image'),
                      SizedBox(height: 12 * s),
                      _buildImagePickerBox(s),
                      SizedBox(height: 24 * s),

                      _buildSectionLabel(s, 'Basic Information'),
                      SizedBox(height: 16 * s),
                      _buildInputField(
                        s,
                        'Competition Name',
                        'Enter Competition Name',
                      ),
                      _buildInputField(
                        s,
                        'Subtitle',
                        'Brief Tagline for the competition',
                      ),
                      _buildInputField(
                        s,
                        'Sponsor Name',
                        'Auto-filled from profile',
                      ),
                      _buildInputField(
                        s,
                        'Description',
                        'Describe the competition ...',
                        maxLines: 3,
                      ),
                      _buildInputField(
                        s,
                        'Competition Banner Image URL (Optional)',
                        'https://example.com/banner/jpg',
                      ),

                      SizedBox(height: 8 * s),
                      _buildSectionLabel(s, 'Rule & Conditions'),
                      SizedBox(height: 16 * s),
                      _buildInputField(
                        s,
                        'Competition Rules',
                        'List the competition rules....',
                        maxLines: 3,
                      ),
                      _buildInputField(
                        s,
                        'Terms & Conditions',
                        'Enter terms and conditions....',
                        maxLines: 3,
                      ),

                      SizedBox(height: 8 * s),
                      _buildSectionLabel(s, 'Prize Structure & Badges'),
                      SizedBox(height: 16 * s),
                      Container(
                        padding: EdgeInsets.all(16 * s),
                        decoration: BoxDecoration(
                          color: const Color(0xFF12171B).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16 * s),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          children: [
                            _buildPrizeBlock(s, '1st Place'),
                            _buildPrizeBlock(s, '2nd Place'),
                            _buildPrizeBlock(s, '3rd Place', isLast: true),
                          ],
                        ),
                      ),

                      SizedBox(height: 32 * s),
                      _buildSendButton(context, s),
                      SizedBox(height: 48 * s),
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

  Widget _buildSectionLabel(double s, String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13 * s,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  Widget _buildHeader(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Text(
            'HI, USER',
            style: GoogleFonts.outfit(
              fontSize: 12 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerBox(double s) {
    return GestureDetector(
      onTap: _pickImage,
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: themeGreen,
          radius: 16 * s,
          strokeWidth: 1.5 * s,
        ),
        child: Container(
          height: 160 * s,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16 * s),
            color: _imageFile != null ? Colors.transparent : Colors.transparent,
          ),
          child: _imageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16 * s),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.landscape_outlined,
                      color: Colors.white54,
                      size: 48 * s,
                    ),
                    SizedBox(height: 8 * s),
                    Text(
                      'Add Competition Image',
                      style: GoogleFonts.inter(
                        fontSize: 12 * s,
                        color: Colors.white54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    double s,
    String label,
    String hint, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12 * s,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8 * s),
          TextField(
            maxLines: maxLines,
            style: GoogleFonts.inter(fontSize: 13 * s, color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 12 * s,
                color: Colors.white38,
              ),
              filled: true,
              fillColor: const Color(0xFF13181D),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16 * s,
                vertical: 14 * s,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12 * s),
                borderSide: BorderSide(
                  color: themeGreen.withOpacity(0.3),
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12 * s),
                borderSide: BorderSide(
                  color: themeGreen.withOpacity(0.4),
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12 * s),
                borderSide: BorderSide(color: themeGreen, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrizeBlock(double s, String place, {bool isLast = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16 * s),
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1D242B),
        borderRadius: BorderRadius.circular(12 * s),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              place,
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
          ),
          SizedBox(height: 16 * s),
          Row(
            children: [
              Text(
                'Points:',
                style: GoogleFonts.inter(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: SizedBox(
                  height: 38 * s,
                  child: TextField(
                    style: GoogleFonts.inter(
                      fontSize: 12 * s,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter points',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 11 * s,
                        color: Colors.white38,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF263038),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16 * s,
                        vertical: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10 * s),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * s),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
            decoration: BoxDecoration(
              color: const Color(0xFF263038),
              borderRadius: BorderRadius.circular(10 * s),
              border: Border.all(
                color: themeGreen.withOpacity(0.35),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose the Badge',
                  style: GoogleFonts.inter(
                    fontSize: 12 * s,
                    color: Colors.white54,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white54,
                  size: 18 * s,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton(BuildContext context, double s) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CompetitionListScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18 * s),
        decoration: BoxDecoration(
          color: themeGreen,
          borderRadius: BorderRadius.circular(16 * s),
        ),
        alignment: Alignment.center,
        child: Text(
          'Send Sponsor Request',
          style: GoogleFonts.inter(
            fontSize: 18 * s,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double radius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashWidth = 6.0,
    this.dashSpace = 5.0,
    this.radius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final length = (distance + dashWidth) < metric.length
            ? dashWidth
            : metric.length - distance;
        canvas.drawPath(metric.extractPath(distance, distance + length), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashSpace != dashSpace ||
      oldDelegate.radius != radius;
}
