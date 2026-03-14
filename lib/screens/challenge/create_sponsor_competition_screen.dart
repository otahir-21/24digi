import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../services/challenge_service.dart';
import '../../core/app_constants.dart';
import '../profile/widgets/profile_top_bar.dart';
import '../../auth/auth_provider.dart' as app_auth;

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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _rulesController = TextEditingController();
  final TextEditingController _termsController = TextEditingController();
  final TextEditingController _bannerUrlController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _mapUrlController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _feeController = TextEditingController(
    text: "500",
  );

  final TextEditingController _p1Controller = TextEditingController();
  final TextEditingController _p2Controller = TextEditingController();
  final TextEditingController _p3Controller = TextEditingController();

  String _selectedCategory = 'Running';
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime _endDate = DateTime.now().add(const Duration(days: 7, hours: 2));

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _subtitleController.dispose();
    _descController.dispose();
    _rulesController.dispose();
    _termsController.dispose();
    _bannerUrlController.dispose();
    _locationController.dispose();
    _mapUrlController.dispose();
    _distanceController.dispose();
    _feeController.dispose();
    _p1Controller.dispose();
    _p2Controller.dispose();
    _p3Controller.dispose();
    super.dispose();
  }

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
                        controller: _nameController,
                      ),
                      _buildInputField(
                        s,
                        'Subtitle',
                        'Brief Tagline for the competition',
                        controller: _subtitleController,
                      ),
                      _buildInputField(
                        s,
                        'Sponsor Name',
                        'Auto-filled from profile',
                      ),
                      _buildInputField(
                        s,
                        'Description',
                        'Enter Competition Description',
                        controller: _descController,
                      ),
                      _buildInputField(
                        s,
                        'Competition Banner Image URL (Optional)',
                        'https://example.com/banner.jpg',
                        controller: _bannerUrlController,
                      ),
                      _buildCategoryPicker(s),
                      SizedBox(height: 24 * s),
                      _buildSectionLabel(s, 'Location & Map'),
                      SizedBox(height: 16 * s),
                      _buildInputField(
                        s,
                        'Location Name',
                        'e.g. Downtown Plaza, Dubai',
                        controller: _locationController,
                      ),
                      _buildInputField(
                        s,
                        'Static Map Image URL (Optional)',
                        'https://maps.googleapis.com/...',
                        controller: _mapUrlController,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              s,
                              'Distance (KM)',
                              '5.0',
                              controller: _distanceController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 16 * s),
                          Expanded(
                            child: _buildInputField(
                              s,
                              'Entry Fee (Pts)',
                              '500',
                              controller: _feeController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8 * s),
                      _buildSectionLabel(s, 'Schedule'),
                      SizedBox(height: 16 * s),
                      _buildDateTimePicker(
                        s,
                        'Starts At',
                        _startDate,
                        (val) => setState(() => _startDate = val),
                      ),
                      _buildDateTimePicker(
                        s,
                        'Ends At',
                        _endDate,
                        (val) => setState(() => _endDate = val),
                      ),

                      SizedBox(height: 8 * s),
                      _buildSectionLabel(s, 'Rule & Conditions'),
                      SizedBox(height: 16 * s),
                      _buildInputField(
                        s,
                        'Competition Rules',
                        'List the competition rules....',
                        maxLines: 3,
                        controller: _rulesController,
                      ),
                      _buildInputField(
                        s,
                        'Terms & Conditions',
                        'Enter terms and conditions....',
                        maxLines: 3,
                        controller: _termsController,
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
                            _buildPrizeBlock(s, '1st Place', _p1Controller),
                            _buildPrizeBlock(s, '2nd Place', _p2Controller),
                            _buildPrizeBlock(
                              s,
                              '3rd Place',
                              _p3Controller,
                              isLast: true,
                            ),
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
          child: Consumer<app_auth.AuthProvider>(
            builder: (context, auth, _) {
              final name = auth.profile?.name ?? 'USER';
              return Text(
                'HI, ${name.toUpperCase()}',
                style: GoogleFonts.outfit(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              );
            },
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
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
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
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
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

  Widget _buildCategoryPicker(double s) {
    final categories = ['Running', 'Cycling', 'Walking', 'Swimming', 'Mixed'];
    return Padding(
      padding: EdgeInsets.only(bottom: 20 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sport Category',
            style: GoogleFonts.inter(
              fontSize: 12 * s,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12 * s),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: EdgeInsets.only(right: 8 * s),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16 * s,
                        vertical: 8 * s,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? themeGreen
                            : const Color(0xFF13181D),
                        borderRadius: BorderRadius.circular(20 * s),
                        border: Border.all(
                          color: isSelected ? themeGreen : Colors.white12,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: GoogleFonts.inter(
                          fontSize: 12 * s,
                          color: isSelected ? Colors.black : Colors.white70,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePicker(
    double s,
    String label,
    DateTime current,
    Function(DateTime) onSelected,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16 * s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white70),
          ),
          GestureDetector(
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: current,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (d != null) {
                final t = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(current),
                );
                if (t != null) {
                  onSelected(
                    DateTime(d.year, d.month, d.day, t.hour, t.minute),
                  );
                }
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12 * s,
                vertical: 8 * s,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF13181D),
                borderRadius: BorderRadius.circular(8 * s),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                '${current.day}/${current.month}/${current.year}  ${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}',
                style: GoogleFonts.inter(fontSize: 12 * s, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrizeBlock(
    double s,
    String place,
    TextEditingController controller, {
    bool isLast = false,
  }) {
    String badgeAsset = 'assets/challenge/challenge_24_gold.png';
    if (place.contains('2nd'))
      badgeAsset = 'assets/challenge/challenge_24_silver.png';
    if (place.contains('3rd'))
      badgeAsset = 'assets/challenge/challenge_24_bronze.png';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                place,
                style: GoogleFonts.inter(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ),
              Image.asset(badgeAsset, width: 32 * s, height: 32 * s),
            ],
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
                    controller: controller,
                    keyboardType: TextInputType.number,
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
        ],
      ),
    );
  }

  Widget _buildSendButton(BuildContext context, double s) {
    return GestureDetector(
      onTap: _isLoading ? null : _handleSubmit,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18 * s),
        decoration: BoxDecoration(
          color: themeGreen,
          borderRadius: BorderRadius.circular(16 * s),
        ),
        alignment: Alignment.center,
        child: _isLoading
            ? SizedBox(
                height: 20 * s,
                width: 20 * s,
                child: const CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              )
            : Text(
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

  Future<void> _handleSubmit() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter competition name')),
      );
      return;
    }
    if (_descController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter description')));
      return;
    }
    if (_locationController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter location')));
      return;
    }
    if (_distanceController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter distance')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String imageUrl = _bannerUrlController.text;
      if (_imageFile != null) {
        imageUrl = await ChallengeService().uploadImage(
          imageFile: _imageFile!,
          storagePath:
              'competitions/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      await ChallengeService().createCompetition({
        'title': _nameController.text,
        'subtitle': _subtitleController.text,
        'description': _descController.text,
        'rules': _rulesController.text,
        'terms': _termsController.text,
        'bg_image': imageUrl.isNotEmpty
            ? imageUrl
            : 'assets/challenge/challenge_24_main_1.png',
        'map_image': _mapUrlController.text,
        'status': 'UPCOMING',
        'sport_type': _selectedCategory,
        'location': _locationController.text,
        'distance_km': double.tryParse(_distanceController.text) ?? 0.0,
        'entry_fee': int.tryParse(_feeController.text) ?? 0,
        'start_at': Timestamp.fromDate(_startDate),
        'end_at': Timestamp.fromDate(_endDate),
        'difficulty': 'Medium', // Could add a picker for this too
        'prize_pool': {
          '1st': _p1Controller.text,
          '1st_label': 'Gold Prize',
          '2nd': _p2Controller.text,
          '2nd_label': 'Silver Prize',
          '3rd': _p3Controller.text,
          '3rd_label': 'Bronze Prize',
        },
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Competition created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
