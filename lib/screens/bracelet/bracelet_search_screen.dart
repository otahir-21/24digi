import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../widgets/digi_background.dart';
import '../../bracelet/bracelet_channel.dart';
import 'bracelet_screen.dart';

/// Brand/category keywords: only devices whose name contains (case-insensitive)
/// at least one of these are shown in the list. Edit this list to match your bracelet brand.
const List<String> _braceletCategoryKeywords = ['blue', '24', 'jstyle', 'J2208'];

/// Returns the category label for a device name (first matching keyword, or 'Bracelet').
String _categoryLabelForName(String name) {
  final lower = name.toLowerCase();
  for (final k in _braceletCategoryKeywords) {
    if (k.isNotEmpty && lower.contains(k.toLowerCase())) {
      return k.substring(0, 1).toUpperCase() + k.substring(1);
    }
  }
  return 'Bracelet';
}

/// Search for BLE bracelet devices, pair (connect), and show live data from device.
class BraceletSearchScreen extends StatefulWidget {
  const BraceletSearchScreen({super.key});

  @override
  State<BraceletSearchScreen> createState() => _BraceletSearchScreenState();
}

class _BraceletSearchScreenState extends State<BraceletSearchScreen> {
  final BraceletChannel _channel = BraceletChannel();
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<BraceletEvent>? _subscription;

  List<Map<Object?, Object?>> _scanResults = [];
  List<Map<Object?, Object?>> _retrievedDevices = [];
  String? _selectedIdentifier;
  String _connectionStatus = 'Disconnected';
  bool _isScanning = false;
  bool _realtimeActive = false;
  bool _pluginUnavailable = false;
  bool _hasReceivedAnyScanResult = false;
  bool _hasNavigatedToDashboardThisSession = false;
  final List<String> _deviceDataLog = [];
  static const int _maxLogLines = 200;

  @override
  void initState() {
    super.initState();
    _listen();
    _restoreConnectionState();
  }

  /// If bracelet is still connected (e.g. app was in background), restore UI and go to dashboard.
  Future<void> _restoreConnectionState() async {
    if (_pluginUnavailable) return;
    try {
      final state = await _channel.getConnectionState();
      final connected = state['connected'] == true;
      if (!connected || !mounted) return;
      final id = state['identifier'] as String?;
      final name = state['name'] as String? ?? 'Bracelet';
      setState(() {
        _connectionStatus = 'Connected';
        _selectedIdentifier = id;
        if (id != null && !_scanResults.any((m) => m['identifier'] == id)) {
          _scanResults.add({'identifier': id, 'name': name, 'rssi': null});
        }
      });
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BraceletScreen()),
        );
      }
    } catch (_) {}
  }

  void _markPluginUnavailable() {
    if (!_pluginUnavailable) {
      setState(() => _pluginUnavailable = true);
      _addLog('Bracelet plugin not available on this build.');
    }
  }

  void _listen() {
    _subscription?.cancel();
    try {
      _subscription = _channel.events.listen(
        (BraceletEvent e) {
          _addLog('${e.event}: ${e.data}');
          if (e.event == 'scanResult' && e.data['identifier'] != null) {
            setState(() {
              _hasReceivedAnyScanResult = true;
              final id = e.data['identifier'] as String?;
              final name = e.data['name'] as String? ?? 'Unknown';
              final rssi = e.data['rssi'];
              if (id != null && !_scanResults.any((m) => m['identifier'] == id)) {
                _scanResults.add({'identifier': id, 'name': name, 'rssi': rssi});
              }
            });
          } else if (e.event == 'connectionState') {
            setState(() {
              final state = e.data['state']?.toString() ?? '';
              _connectionStatus = state;
              if (state.toLowerCase().contains('disconnect') || state == '0') {
                _selectedIdentifier = null;
                _realtimeActive = false;
                _hasNavigatedToDashboardThisSession = false;
              }
            });
            // When connected, navigate to bracelet dashboard
            if ((e.data['state']?.toString() ?? '').toLowerCase() == 'connected' && mounted && !_hasNavigatedToDashboardThisSession) {
              _hasNavigatedToDashboardThisSession = true;
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BraceletScreen()),
              );
            }
          } else if (e.event == 'realtimeData') {
            setState(() {
              _addLog('DEVICE DATA: ${e.data}');
            });
            // Fallback: if we're connected and getting data but still on search screen, go to dashboard
            if (mounted && !_hasNavigatedToDashboardThisSession && (_selectedIdentifier != null || _connectionStatus.toLowerCase().contains('connect'))) {
              _hasNavigatedToDashboardThisSession = true;
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BraceletScreen()),
              );
            }
          }
        },
        onError: (Object e, StackTrace st) {
          if (e is MissingPluginException) _markPluginUnavailable();
          _addLog('Event error: $e');
        },
        cancelOnError: false,
      );
    } on MissingPluginException catch (_) {
      _markPluginUnavailable();
    }
  }

  void _addLog(String line) {
    debugPrint(line);
    setState(() {
      _deviceDataLog.insert(0, '${DateTime.now().toString().substring(11, 19)} $line');
      if (_deviceDataLog.length > _maxLogLines) _deviceDataLog.removeLast();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    setState(() {
      _scanResults = [];
      _isScanning = true;
    });
    _addLog('Scan started.');
    try {
      // Give Bluetooth central time to be ready (especially after app start / hot restart)
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      if (!mounted || !_isScanning) return;
      // Include connected/retrieved devices so they still show while scanning
      final retrieved = await _channel.getRetrievedDevices();
      setState(() => _retrievedDevices = retrieved);
      _addLog(retrieved.isEmpty
          ? 'No connected/known devices. Scanning...'
          : 'Retrieved ${retrieved.length} device(s). Scanning...');
      await _channel.scan();
    } on MissingPluginException catch (_) {
      _markPluginUnavailable();
      setState(() => _isScanning = false);
    } catch (e) {
      _addLog('Scan error: $e');
      setState(() => _isScanning = false);
    }
  }

  Future<void> _stopScan() async {
    try {
      await _channel.stopScan();
      _addLog('Scan stopped.');
    } on MissingPluginException catch (_) {
      _markPluginUnavailable();
    } catch (e) {
      _addLog('StopScan error: $e');
    }
    setState(() => _isScanning = false);
  }

  Future<void> _loadRetrieved() async {
    try {
      final list = await _channel.getRetrievedDevices();
      setState(() => _retrievedDevices = list);
      _addLog('Retrieved devices: ${list.length}');
    } on MissingPluginException catch (_) {
      _markPluginUnavailable();
    } catch (e) {
      _addLog('getRetrievedDevices error: $e');
    }
  }

  Future<void> _connect(String identifier) async {
    _addLog('Connecting to $identifier');
    setState(() {
      _selectedIdentifier = identifier;
      _connectionStatus = 'Connecting...';
    });
    try {
      await _channel.connect(identifier);
    } on MissingPluginException catch (_) {
      _markPluginUnavailable();
      setState(() {
        _selectedIdentifier = null;
        _connectionStatus = 'Disconnected';
      });
    } catch (e) {
      _addLog('Connect error: $e');
      setState(() {
        _selectedIdentifier = null;
        _connectionStatus = 'Disconnected';
      });
    }
  }

  Future<void> _startRealtime() async {
    try {
      await _channel.startRealtime(RealtimeType.stepWithTemp);
      _addLog('Realtime started (step + temp).');
      setState(() => _realtimeActive = true);
    } on MissingPluginException catch (_) {
      _markPluginUnavailable();
    } catch (e) {
      _addLog('StartRealtime error: $e');
    }
  }

  Future<void> _stopRealtime() async {
    try {
      await _channel.stopRealtime();
      _addLog('Realtime stopped.');
      setState(() => _realtimeActive = false);
    } on MissingPluginException catch (_) {
      _markPluginUnavailable();
    } catch (e) {
      _addLog('StopRealtime error: $e');
    }
  }

  Future<void> _disconnect() async {
    try {
      await _channel.disconnect();
      _addLog('Disconnected.');
      setState(() {
        _selectedIdentifier = null;
        _connectionStatus = 'Disconnected';
        _realtimeActive = false;
      });
    } on MissingPluginException catch (_) {
      _markPluginUnavailable();
    } catch (e) {
      _addLog('Disconnect error: $e');
    }
  }

  List<Map<Object?, Object?>> get _allDevices {
    final combined = <Map<Object?, Object?>>[];
    final seen = <String>{};
    for (final m in _scanResults) {
      final id = m['identifier'] as String?;
      if (id != null && seen.add(id)) combined.add(m);
    }
    for (final m in _retrievedDevices) {
      final id = m['identifier'] as String?;
      if (id != null && seen.add(id)) combined.add(m);
    }
    return combined;
  }

  /// Only show devices in the bracelet category (name matches keywords).
  List<Map<Object?, Object?>> get _braceletDevices {
    if (_braceletCategoryKeywords.isEmpty) return _allDevices;
    return _allDevices.where((m) {
      final name = (m['name'] as String? ?? '').toLowerCase();
      return _braceletCategoryKeywords.any((k) => k.isNotEmpty && name.contains(k.toLowerCase()));
    }).toList();
  }

  List<Map<Object?, Object?>> get _filteredDevices {
    final from = _braceletDevices;
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return from;
    return from.where((m) {
      final name = (m['name'] as String? ?? '').toLowerCase();
      final id = (m['identifier'] as String? ?? '').toLowerCase();
      return name.contains(query) || id.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final s = mq.size.width / AppConstants.figmaW;
    final hPad = 16.0 * s;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: DigiBackground(
        logoOpacity: 0,
        showCircuit: false,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top bar ─────────────────────────────────────────────
              _TopBar(s: s),
              SizedBox(height: 12 * s),

              // ── Full run required (hot restart never loads BLE / native code) ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 6 * s),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 12 * s),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10 * s),
                    color: const Color(0x22E65100),
                    border: Border.all(color: const Color(0xFFE65100), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: const Color(0xFFE65100), size: 24 * s),
                          SizedBox(width: 10 * s),
                          Expanded(
                            child: Text(
                              'List empty? You must do a FULL RUN.',
                              style: GoogleFonts.inter(fontSize: 13 * s, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8 * s),
                      Text(
                        'Hot restart does NOT load BLE code. Stop the app, then in Terminal run:\nflutter run\n\nOr in Xcode: open ios/Runner.xcworkspace and press Run (▶).',
                        style: GoogleFonts.inter(fontSize: 11 * s, color: AppColors.textLight, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Plugin unavailable banner ────────────────────────────
              if (_pluginUnavailable)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8 * s),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 12 * s),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12 * s),
                      color: const Color(0x22FF9800),
                      border: Border.all(color: const Color(0xFFFF9800), width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: const Color(0xFFFF9800), size: 22 * s),
                        SizedBox(width: 10 * s),
                        Expanded(
                          child: Text(
                            'Bracelet SDK is not set up on this build. Add the native bracelet plugin (iOS/Android) to enable device search and pairing.',
                            style: GoogleFonts.inter(
                              fontSize: 12 * s,
                              color: AppColors.textLight,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Search bar ────────────────────────────────────
                    _SearchBar(
                      s: s,
                      controller: _searchController,
                      hint: 'Search devices by name...',
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: 12 * s),

                    // ── Scan / Stop / Retrieved ──────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            s: s,
                            label: _isScanning ? 'Stop scan' : 'Scan',
                            onTap: _pluginUnavailable ? () {} : (_isScanning ? _stopScan : _scan),
                            active: _isScanning,
                          ),
                        ),
                        SizedBox(width: 8 * s),
                        Expanded(
                          child: _ActionButton(
                            s: s,
                            label: 'Retrieved',
                            onTap: _pluginUnavailable ? () {} : _loadRetrieved,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10 * s),

                    // ── Connection status ────────────────────────────
                    _StatusChip(s: s, label: _connectionStatus),
                    SizedBox(height: 12 * s),

                    // ── Device list ───────────────────────────────────
                    Text(
                      'Devices (tap to pair)',
                      style: GoogleFonts.inter(
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w600,
                        color: AppColors.labelDim,
                      ),
                    ),
                    SizedBox(height: 8 * s),
                  ],
                ),
              ),

              // Scrollable: device list + when connected: realtime controls + data log
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ..._filteredDevices.map((m) => _DeviceTile(
                            s: s,
                            name: m['name'] as String? ?? 'Unknown',
                            identifier: m['identifier'] as String? ?? '',
                            categoryLabel: _categoryLabelForName(m['name'] as String? ?? ''),
                            rssi: m['rssi'],
                            isSelected: _selectedIdentifier == m['identifier'],
                            onTap: () => _connect(m['identifier'] as String),
                          )),
                      if (_filteredDevices.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 24 * s),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _isScanning ? 'Scanning...' : 'Tap Scan to find devices',
                                  style: GoogleFonts.inter(
                                    fontSize: 13 * s,
                                    color: AppColors.labelDim,
                                  ),
                                ),
                                if (!_isScanning) ...[
                                  SizedBox(height: 8 * s),
                                  Text(
                                    'Bracelet on & in range. Use full run (not hot restart)\nafter BLE/native changes.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 11 * s,
                                      color: AppColors.labelDimmer,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                      // ── When connected: realtime + disconnect + data ──
                      if (_selectedIdentifier != null) ...[
                        SizedBox(height: 20 * s),
                        Text(
                          'Device data',
                          style: GoogleFonts.inter(
                            fontSize: 12 * s,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cyan,
                          ),
                        ),
                        SizedBox(height: 8 * s),
                        Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                s: s,
                                label: _realtimeActive ? 'Stop data' : 'Start data',
                                onTap: _realtimeActive ? _stopRealtime : _startRealtime,
                                active: _realtimeActive,
                              ),
                            ),
                            SizedBox(width: 8 * s),
                            Expanded(
                              child: _ActionButton(
                                s: s,
                                label: 'Disconnect',
                                onTap: _disconnect,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12 * s),
                        _DataLogPanel(s: s, lines: _deviceDataLog),
                        SizedBox(height: 16 * s),
                        _ActionButton(
                          s: s,
                          label: 'Open Bracelet dashboard',
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const BraceletScreen()),
                          ),
                        ),
                        SizedBox(height: 24 * s),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Top bar ─────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final double s;
  const _TopBar({required this.s});

  @override
  Widget build(BuildContext context) {
    final pillH = 52.0 * s;
    final radius = pillH / 2;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: radius),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: ColoredBox(
            color: const Color(0xFF060E16),
            child: SizedBox(
              height: pillH,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14 * s),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.cyan,
                        size: 20 * s,
                      ),
                    ),
                    SizedBox(width: 12 * s),
                    Text(
                      'Search device',
                      style: GoogleFonts.inter(
                        fontSize: 15 * s,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Search bar ───────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final double s;
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.s,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SmoothGradientBorder(radius: 10 * s),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10 * s),
        child: ColoredBox(
          color: const Color(0xFF060E16),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 4 * s),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: AppColors.labelDim, size: 18 * s),
                SizedBox(width: 8 * s),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: GoogleFonts.inter(fontSize: 13 * s, color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: GoogleFonts.inter(fontSize: 13 * s, color: AppColors.labelDim),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10 * s),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Action button ────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final double s;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _ActionButton({
    required this.s,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10 * s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10 * s),
          color: active ? AppColors.cyanTint18 : const Color(0xFF0A1820),
          border: Border.all(
            color: active ? AppColors.cyan : const Color(0xFF1E3040),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12 * s,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.cyan : AppColors.textLight,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Status chip ───────────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final double s;
  final String label;

  const _StatusChip({required this.s, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * s),
        color: const Color.fromRGBO(0, 240, 255, 0.1),
        border: Border.all(color: AppColors.cyan, width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11 * s,
          fontWeight: FontWeight.w500,
          color: AppColors.cyan,
        ),
      ),
    );
  }
}

// ── Device tile ──────────────────────────────────────────────────────────
class _DeviceTile extends StatelessWidget {
  final double s;
  final String name;
  final String identifier;
  final String categoryLabel;
  final Object? rssi;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeviceTile({
    required this.s,
    required this.name,
    required this.identifier,
    required this.categoryLabel,
    this.rssi,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * s),
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: SmoothGradientBorder(radius: 12 * s),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12 * s),
            child: ColoredBox(
              color: isSelected ? AppColors.cyanTint8 : const Color(0xFF060E16),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 12 * s),
                child: Row(
                  children: [
                    Icon(
                      Icons.watch_rounded,
                      size: 24 * s,
                      color: isSelected ? AppColors.cyan : AppColors.labelDim,
                    ),
                    SizedBox(width: 12 * s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.inter(
                              fontSize: 14 * s,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 2 * s),
                                decoration: BoxDecoration(
                                  color: AppColors.cyan.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4 * s),
                                  border: Border.all(color: AppColors.cyan.withValues(alpha: 0.5), width: 1),
                                ),
                                child: Text(
                                  categoryLabel,
                                  style: GoogleFonts.inter(
                                    fontSize: 10 * s,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.cyan,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8 * s),
                              Expanded(
                                child: Text(
                                  identifier,
                                  style: GoogleFonts.inter(
                                    fontSize: 11 * s,
                                    color: AppColors.labelDim,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (rssi != null)
                      Text(
                        'RSSI: $rssi',
                        style: GoogleFonts.inter(
                          fontSize: 11 * s,
                          color: AppColors.labelDimmer,
                        ),
                      ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: AppColors.cyan, size: 20 * s),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Device data log panel ─────────────────────────────────────────────────
class _DataLogPanel extends StatelessWidget {
  final double s;
  final List<String> lines;

  const _DataLogPanel({required this.s, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12 * s),
        color: const Color(0xFF0A0E12),
        border: Border.all(color: const Color(0xFF1E3040), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12 * s),
        child: ListView.builder(
          padding: EdgeInsets.all(10 * s),
          itemCount: lines.length,
          reverse: true,
          itemBuilder: (_, i) {
            final line = lines[lines.length - 1 - i];
            final isDeviceData = line.contains('DEVICE DATA:');
            return Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                line,
                style: GoogleFonts.inter(
                  fontSize: 11 * s,
                  color: isDeviceData ? AppColors.cyan : AppColors.textLight,
                  fontWeight: isDeviceData ? FontWeight.w500 : FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
      ),
    );
  }
}
