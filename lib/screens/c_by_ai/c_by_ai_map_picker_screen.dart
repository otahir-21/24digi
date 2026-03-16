import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/app_constants.dart';
import '../shop/widgets/shop_top_bar.dart';
import 'providers/c_by_ai_provider.dart';

enum MapState { selection, form, notSupported }

class CByAiMapPickerScreen extends StatefulWidget {
  const CByAiMapPickerScreen({super.key});

  @override
  State<CByAiMapPickerScreen> createState() => _CByAiMapPickerScreenState();
}

class _CByAiMapPickerScreenState extends State<CByAiMapPickerScreen> {
  MapState _state = MapState.selection;
  
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(24.4539, 54.3773), // Abu Dhabi
    zoom: 14,
  );

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<CByAiProvider>();
    _addressController.text = provider.deliveryAddress ?? '';
    _landmarkController.text = provider.deliveryLandmark ?? '';
    _nameController.text = provider.deliveryFullName ?? '';
    _titleController.text = provider.deliveryAddressTitle ?? '';
  }

  @override
  void dispose() {
    _addressController.dispose();
    _landmarkController.dispose();
    _nameController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C0E),
      body: Stack(
        children: [
          // Google Map Background
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              mapType: MapType.normal, 
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              onMapCreated: (controller) {
                // Set map style to dark
                _setMapStyle(controller);
              },
            ),
          ),
          
          // Top Bar Overlay
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Column(
                children: [
                   const ShopTopBar(),
                   SizedBox(height: 16 * s),
                   Text(
                    'HI, USER',
                    style: GoogleFonts.outfit(
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Conditional UI Overlays
          if (_state == MapState.selection) _buildSelectionCard(s),
          if (_state == MapState.form) _buildAddressForm(s),
          if (_state == MapState.notSupported) _buildNotSupportedOverlay(s),

          // Map Search/Controls (Optional but seen in design)
          if (_state == MapState.selection)
            Positioned(
              bottom: 180 * s,
              right: 16 * s,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF1B2329),
                onPressed: () {},
                child: const Icon(Icons.my_location, color: Color(0xFF00F0FF)),
              ),
            ),
        ],
      ),
    );
  }

  void _setMapStyle(GoogleMapController controller) {
    // Standard dark map style JSON would go here
  }

  // --- Image 2: Selection Card ---
  Widget _buildSelectionCard(double s) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 24 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2329),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32 * s)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_rounded, color: const Color(0xFF00F0FF), size: 18 * s),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Text(
                    'Some location',
                    style: GoogleFonts.outfit(fontSize: 16 * s, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _state = MapState.notSupported), // Simulate "area not supported"
                  child: Text(
                    'CHANGE',
                    style: GoogleFonts.outfit(fontSize: 14 * s, color: const Color(0xFF00F0FF), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16 * s),
            Padding(
              padding: EdgeInsets.only(left: 30 * s),
              child: Text(
                'Apartment number, Street Number/Name,\nCity Name, Emirate, UAE',
                style: GoogleFonts.outfit(fontSize: 13 * s, color: Colors.white38, height: 1.4),
              ),
            ),
            SizedBox(height: 32 * s),
            GestureDetector(
              onTap: () => setState(() => _state = MapState.form),
              child: Container(
                width: double.infinity, height: 54 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFF00F0FF),
                  borderRadius: BorderRadius.circular(16 * s),
                ),
                alignment: Alignment.center,
                child: Text('CONFIRM LOCATION', style: GoogleFonts.outfit(fontSize: 16 * s, fontWeight: FontWeight.w900, color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Image 3: Address Form ---
  Widget _buildAddressForm(double s) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 24 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2329),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32 * s)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40 * s, height: 4 * s,
                  margin: EdgeInsets.only(bottom: 24 * s),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2 * s)),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.location_on_rounded, color: const Color(0xFF00F0FF), size: 18 * s),
                  SizedBox(width: 8 * s),
                  Text('Apartment Name', style: GoogleFonts.outfit(fontSize: 16 * s, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
              SizedBox(height: 8 * s),
              Text('AL Dana Building, AL MADAR2, Umm Al Quwain', style: GoogleFonts.outfit(fontSize: 12 * s, color: Colors.white38)),
              
              SizedBox(height: 24 * s),
              _textField(s, 'Address', 'House Number / Flat / Block No.', controller: _addressController),
              SizedBox(height: 20 * s),
              _textField(s, 'Landmark', 'e.g. Near ABC School', controller: _landmarkController),
              SizedBox(height: 20 * s),
              Row(
                children: [
                  Expanded(child: _textField(s, 'Full Name', 'Enter Name', controller: _nameController)),
                  SizedBox(width: 16 * s),
                  Expanded(child: _textField(s, 'Address Title', 'e.g. Home', controller: _titleController)),
                ],
              ),
              
              SizedBox(height: 32 * s),
              GestureDetector(
                onTap: () async {
                  final provider = context.read<CByAiProvider>();
                  await provider.saveDeliveryAddress(
                    building: 'AL Dana Building', // Dummy or from Map selection
                    address: _addressController.text,
                    landmark: _landmarkController.text,
                    fullName: _nameController.text,
                    addressTitle: _titleController.text,
                  );
                  if (mounted) Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity, height: 54 * s,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F0FF),
                    borderRadius: BorderRadius.circular(16 * s),
                  ),
                  alignment: Alignment.center,
                  child: Text('SAVE ADDRESS', style: GoogleFonts.outfit(fontSize: 16 * s, fontWeight: FontWeight.w900, color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Image 4: Not Supported ---
  Widget _buildNotSupportedOverlay(double s) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 32 * s, vertical: 40 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2329).withValues(alpha: 0.95),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32 * s)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sorry! We aren\'t there yet.',
              style: GoogleFonts.outfit(fontSize: 22 * s, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            SizedBox(height: 24 * s),
            _textField(s, 'City and Area', 'Al Ain'),
            SizedBox(height: 16 * s),
            Text(
              'We\'re increasing our operational areas everyday.\nWe will notify you when we start operations in\nyour area.',
              style: GoogleFonts.outfit(fontSize: 12 * s, color: Colors.white38, height: 1.5),
            ),
            SizedBox(height: 40 * s),
            GestureDetector(
              onTap: () async {
                final provider = context.read<CByAiProvider>();
                await provider.saveDeliveryAddress(
                  building: 'AL Dana Building', 
                  address: 'N/A',
                  isNotifying: true,
                );
                if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('notification set')),
                  );
                  Navigator.pop(context);
                }
              },
              child: Container(
                width: double.infinity, height: 54 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFF4AC2CD).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(13 * s),
                ),
                alignment: Alignment.center,
                child: Text('NOTIFY ME', style: GoogleFonts.outfit(fontSize: 16 * s, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(double s, String label, String hint, {TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: GoogleFonts.outfit(fontSize: 13 * s, fontWeight: FontWeight.w500, color: Colors.white)),
            Text(' *', style: GoogleFonts.outfit(fontSize: 13 * s, color: Colors.redAccent)),
          ],
        ),
        SizedBox(height: 10 * s),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16 * s),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.outfit(fontSize: 14 * s, color: Colors.white12),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
