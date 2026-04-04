import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kivi_24/auth/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../core/app_constants.dart';
import '../../widgets/digi_pill_header.dart';
import 'providers/c_by_ai_provider.dart';

enum MapState { selection, form, notSupported }

class CByAiMapPickerScreen extends StatefulWidget {
  const CByAiMapPickerScreen({super.key});

  @override
  State<CByAiMapPickerScreen> createState() => _CByAiMapPickerScreenState();
}

class _CByAiMapPickerScreenState extends State<CByAiMapPickerScreen> {
  MapState _state = MapState.selection;

  GoogleMapController? _mapController;
  late LatLng _markerPosition;
  bool _geocoding = false;
  String _geocodeTitle = 'Move the pin or tap the map';
  String _geocodeSubtitle = '';

  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _addressDetailController =
      TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notifyAreaController = TextEditingController();

  static const LatLng _defaultCenter = LatLng(24.4539, 54.3773);

  @override
  void initState() {
    super.initState();
    final provider = context.read<CByAiProvider>();
    if (provider.deliveryLatitude != null &&
        provider.deliveryLongitude != null) {
      _markerPosition = LatLng(
        provider.deliveryLatitude!,
        provider.deliveryLongitude!,
      );
    } else {
      _markerPosition = _defaultCenter;
    }
    _buildingController.text = provider.deliveryBuilding ?? '';
    _addressDetailController.text = provider.deliveryAddress ?? '';
    _floorController.text = provider.deliveryFloor ?? '';
    _landmarkController.text = provider.deliveryLandmark ?? '';
    _cityController.text = provider.deliveryCity ?? '';
    _nameController.text = provider.deliveryFullName ?? '';
    _titleController.text = provider.deliveryAddressTitle ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateGeocodeForPosition();
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _buildingController.dispose();
    _addressDetailController.dispose();
    _floorController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _nameController.dispose();
    _titleController.dispose();
    _notifyAreaController.dispose();
    super.dispose();
  }

  CameraPosition get _initialCamera => CameraPosition(
        target: _markerPosition,
        zoom: 15,
      );

  Set<Marker> get _markers => {
        Marker(
          markerId: const MarkerId('delivery_pin'),
          position: _markerPosition,
          draggable: true,
          onDragEnd: (LatLng pos) {
            setState(() => _markerPosition = pos);
            _updateGeocodeForPosition();
          },
        ),
      };

  Future<void> _updateGeocodeForPosition() async {
    setState(() => _geocoding = true);
    try {
      final list = await placemarkFromCoordinates(
        _markerPosition.latitude,
        _markerPosition.longitude,
      );
      if (!mounted) return;
      if (list.isEmpty) {
        _geocodeTitle = 'Selected location';
        _geocodeSubtitle =
            '${_markerPosition.latitude.toStringAsFixed(5)}, ${_markerPosition.longitude.toStringAsFixed(5)}';
      } else {
        final p = list.first;
        final parts = <String>[
          if (p.street != null && p.street!.trim().isNotEmpty) p.street!,
          if (p.subLocality != null && p.subLocality!.trim().isNotEmpty)
            p.subLocality!,
          if (p.locality != null && p.locality!.trim().isNotEmpty) p.locality!,
          if (p.administrativeArea != null &&
              p.administrativeArea!.trim().isNotEmpty)
            p.administrativeArea!,
          if (p.country != null && p.country!.trim().isNotEmpty) p.country!,
        ];
        _geocodeTitle = (p.name != null && p.name!.trim().isNotEmpty)
            ? p.name!
            : (p.street ?? p.subLocality ?? 'Selected area');
        _geocodeSubtitle = parts.join(', ');
        if (_cityController.text.trim().isEmpty) {
          _cityController.text =
              p.locality ?? p.subAdministrativeArea ?? p.administrativeArea ?? '';
        }
      }
    } catch (_) {
      if (mounted) {
        _geocodeTitle = 'Selected location';
        _geocodeSubtitle =
            '${_markerPosition.latitude.toStringAsFixed(5)}, ${_markerPosition.longitude.toStringAsFixed(5)}';
      }
    } finally {
      if (mounted) setState(() => _geocoding = false);
    }
  }

  Future<void> _goToMyLocation() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission is required to use my location.'),
          ),
        );
      }
      return;
    }
    try {
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _markerPosition = LatLng(pos.latitude, pos.longitude);
      });
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_markerPosition, 16),
      );
      await _updateGeocodeForPosition();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get location: $e')),
        );
      }
    }
  }

  void _setMapStyle(GoogleMapController controller) {}

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C0E),
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: _initialCamera,
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
                _setMapStyle(controller);
              },
              onTap: (LatLng pos) {
                setState(() => _markerPosition = pos);
                _updateGeocodeForPosition();
              },
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                children: [
                  const DigiPillHeader(),
                  SizedBox(height: 16 * s),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      final rawName = auth.profile?.name?.trim();
                      final greetingName = (rawName == null || rawName.isEmpty)
                          ? 'USER'
                          : rawName.toUpperCase();
                      return Text(
                        'HI, $greetingName',
                        style: GoogleFonts.outfit(
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_state == MapState.selection) _buildSelectionCard(s),
          if (_state == MapState.form) _buildAddressForm(s),
          if (_state == MapState.notSupported) _buildNotSupportedOverlay(s),
          if (_state == MapState.selection)
            Positioned(
              bottom: 180 * s,
              right: 16 * s,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF1B2329),
                onPressed: _goToMyLocation,
                child: const Icon(Icons.my_location, color: Color(0xFF00F0FF)),
              ),
            ),
        ],
      ),
    );
  }

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
                Icon(
                  Icons.location_on_rounded,
                  color: const Color(0xFF00F0FF),
                  size: 18 * s,
                ),
                SizedBox(width: 12 * s),
                Expanded(
                  child: _geocoding
                      ? Text(
                          'Finding address…',
                          style: GoogleFonts.outfit(
                            fontSize: 16 * s,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                          ),
                        )
                      : Text(
                          _geocodeTitle,
                          style: GoogleFonts.outfit(
                            fontSize: 16 * s,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
                GestureDetector(
                  onTap: () => _updateGeocodeForPosition(),
                  child: Text(
                    'REFRESH',
                    style: GoogleFonts.outfit(
                      fontSize: 14 * s,
                      color: const Color(0xFF00F0FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * s),
            Padding(
              padding: EdgeInsets.only(left: 6 * s),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _geocodeSubtitle.isEmpty
                      ? 'Tap the map or drag the pin, then confirm.'
                      : _geocodeSubtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 13 * s,
                    color: Colors.white38,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8 * s),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () =>
                    setState(() => _state = MapState.notSupported),
                child: Text(
                  'Area not listed?',
                  style: GoogleFonts.outfit(
                    fontSize: 12 * s,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16 * s),
            GestureDetector(
              onTap: () async {
                await _updateGeocodeForPosition();
                if (mounted) setState(() => _state = MapState.form);
              },
              child: Container(
                width: double.infinity,
                height: 54 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFF00F0FF),
                  borderRadius: BorderRadius.circular(16 * s),
                ),
                alignment: Alignment.center,
                child: Text(
                  'CONFIRM LOCATION',
                  style: GoogleFonts.outfit(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressForm(double s) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.72),
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
                child: GestureDetector(
                  onTap: () => setState(() => _state = MapState.selection),
                  child: Container(
                    width: 40 * s,
                    height: 4 * s,
                    margin: EdgeInsets.only(bottom: 16 * s),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(2 * s),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: const Color(0xFF00F0FF),
                    size: 18 * s,
                  ),
                  SizedBox(width: 8 * s),
                  Text(
                    'Delivery details',
                    style: GoogleFonts.outfit(
                      fontSize: 16 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8 * s),
              Text(
                _geocodeSubtitle.isEmpty ? _geocodeTitle : _geocodeSubtitle,
                style: GoogleFonts.outfit(
                  fontSize: 12 * s,
                  color: Colors.white38,
                ),
              ),
              SizedBox(height: 20 * s),
              _textField(
                s,
                'Building name',
                'e.g. Al Dana Tower',
                controller: _buildingController,
              ),
              SizedBox(height: 16 * s),
              _textField(
                s,
                'Apartment / flat / unit',
                'Unit number, floor detail',
                controller: _addressDetailController,
              ),
              SizedBox(height: 16 * s),
              _textField(
                s,
                'Floor',
                'Optional',
                controller: _floorController,
                isRequired: false,
              ),
              SizedBox(height: 16 * s),
              _textField(
                s,
                'Landmark',
                'e.g. Near ABC School',
                controller: _landmarkController,
                isRequired: false,
              ),
              SizedBox(height: 16 * s),
              _textField(
                s,
                'City',
                'City or area',
                controller: _cityController,
              ),
              SizedBox(height: 16 * s),
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      s,
                      'Full name',
                      'Recipient name',
                      controller: _nameController,
                    ),
                  ),
                  SizedBox(width: 16 * s),
                  Expanded(
                    child: _textField(
                      s,
                      'Address title',
                      'e.g. Home',
                      controller: _titleController,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28 * s),
              GestureDetector(
                onTap: () async {
                  final building = _buildingController.text.trim();
                  final unit = _addressDetailController.text.trim();
                  if (building.isEmpty || unit.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please enter building name and apartment / unit.',
                        ),
                      ),
                    );
                    return;
                  }
                  final provider = context.read<CByAiProvider>();
                  final ok = await provider.saveDeliveryAddress(
                    building: building,
                    address: unit,
                    floor: _floorController.text.trim().isEmpty
                        ? null
                        : _floorController.text.trim(),
                    landmark: _landmarkController.text.trim().isEmpty
                        ? null
                        : _landmarkController.text.trim(),
                    fullName: _nameController.text.trim().isEmpty
                        ? null
                        : _nameController.text.trim(),
                    addressTitle: _titleController.text.trim().isEmpty
                        ? null
                        : _titleController.text.trim(),
                    city: _cityController.text.trim().isEmpty
                        ? null
                        : _cityController.text.trim(),
                    latitude: _markerPosition.latitude,
                    longitude: _markerPosition.longitude,
                  );
                  if (!mounted) return;
                  if (!ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not save address. Try again.'),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 54 * s,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F0FF),
                    borderRadius: BorderRadius.circular(16 * s),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'SAVE ADDRESS',
                    style: GoogleFonts.outfit(
                      fontSize: 16 * s,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
              style: GoogleFonts.outfit(
                fontSize: 22 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24 * s),
            _textField(
              s,
              'City and area',
              'Where should we expand?',
              controller: _notifyAreaController,
            ),
            SizedBox(height: 16 * s),
            Text(
              'We\'re increasing our operational areas every day.\nWe will notify you when we start operations in your area.',
              style: GoogleFonts.outfit(
                fontSize: 12 * s,
                color: Colors.white38,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24 * s),
            TextButton(
              onPressed: () => setState(() => _state = MapState.selection),
              child: Text(
                'Back to map',
                style: GoogleFonts.outfit(color: const Color(0xFF00F0FF)),
              ),
            ),
            SizedBox(height: 16 * s),
            GestureDetector(
              onTap: () async {
                final area = _notifyAreaController.text.trim();
                if (area.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter your city or area.')),
                  );
                  return;
                }
                final provider = context.read<CByAiProvider>();
                final ok = await provider.saveDeliveryAddress(
                  building: 'Waitlist',
                  address: area,
                  isNotifying: true,
                );
                if (!mounted) return;
                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not save. Try again.')),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('We\'ll notify you when we\'re live in your area.')),
                );
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                height: 54 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFF4AC2CD).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(13 * s),
                ),
                alignment: Alignment.center,
                child: Text(
                  'NOTIFY ME',
                  style: GoogleFonts.outfit(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(
    double s,
    String label,
    String hint, {
    TextEditingController? controller,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13 * s,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: GoogleFonts.outfit(
                  fontSize: 13 * s,
                  color: Colors.redAccent,
                ),
              ),
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
