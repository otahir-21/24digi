import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_constants.dart';
import '../../bracelet/bracelet_channel.dart';
import 'bracelet_scaffold.dart';
import 'bracelet_screen.dart';

/// Search for BLE bracelet devices, pair (connect), and show live data from device.
class BraceletSearchScreen extends StatefulWidget {
  const BraceletSearchScreen({super.key});

  @override
  State<BraceletSearchScreen> createState() => _BraceletSearchScreenState();
}

class _BraceletSearchScreenState extends State<BraceletSearchScreen>
    with TickerProviderStateMixin {
  final BraceletChannel _channel = BraceletChannel();
  StreamSubscription<BraceletEvent>? _subscription;

  List<Map<Object?, Object?>> _scanResults = [];
  String? _selectedIdentifier;
  String _connectionStatus = 'Disconnected';
  bool _isScanning = false;
  bool _realtimeActive = false;
  bool _pluginUnavailable = false;
  bool _hasNavigatedToDashboardThisSession = false;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  bool _modalShown = false;
  final List<String> _deviceDataLog = [];
  static const int _maxLogLines = 200;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
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
              final id = e.data['identifier'] as String?;
              final name = e.data['name'] as String? ?? 'Unknown';
              final rssi = e.data['rssi'];
              if (id != null &&
                  !_scanResults.any((m) => m['identifier'] == id)) {
                _scanResults.add({
                  'identifier': id,
                  'name': name,
                  'rssi': rssi,
                });

                // Show modal automatically when results are found
                if (_isScanning && !_modalShown && _scanResults.isNotEmpty) {
                  _modalShown = true;
                  _showDeviceModal();
                }
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
            if ((e.data['state']?.toString() ?? '').toLowerCase() ==
                    'connected' &&
                mounted &&
                !_hasNavigatedToDashboardThisSession) {
              _hasNavigatedToDashboardThisSession = true;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => BraceletScreen()),
              );
            }
          } else if (e.event == 'realtimeData') {
            setState(() {
              _addLog('DEVICE DATA: ${e.data}');
            });
            // Fallback: if we're connected and getting data but still on search screen, go to dashboard
            if (mounted &&
                !_hasNavigatedToDashboardThisSession &&
                (_selectedIdentifier != null ||
                    _connectionStatus.toLowerCase().contains('connect'))) {
              _hasNavigatedToDashboardThisSession = true;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => BraceletScreen()),
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
      _deviceDataLog.insert(
        0,
        '${DateTime.now().toString().substring(11, 19)} $line',
      );
      if (_deviceDataLog.length > _maxLogLines) _deviceDataLog.removeLast();
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _scan() async {
    setState(() {
      _scanResults = [];
      _isScanning = true;
      _modalShown = false;
    });
    _addLog('Scan started.');
    try {
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      if (!mounted || !_isScanning) return;
      final retrieved = await _channel.getRetrievedDevices();
      _addLog(
        retrieved.isEmpty
            ? 'No connected/known devices. Scanning...'
            : 'Retrieved ${retrieved.length} device(s). Scanning...',
      );
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

  void _showDeviceModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _DeviceBottomSheet(
        s: AppConstants.scale(context),
        scanResults: _scanResults,
        onConnect: _connect,
        onScanToggle: () {
          if (_isScanning) {
            _stopScan();
          } else {
            _scan();
            Navigator.pop(context);
          }
        },
        isScanning: _isScanning,
      ),
    ).then((_) => _modalShown = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return BraceletScaffold(
      title: 'Pair your Device',
      scrollable: false,
      actions: [
        IconButton(
          icon: Icon(
            Icons.qr_code_scanner_rounded,
            color: Colors.white,
            size: 22 * s,
          ),
          onPressed: () {},
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_selectedIdentifier != null)
            _ConnectedView(
              s: s,
              connectionStatus: _connectionStatus,
              realtimeActive: _realtimeActive,
              deviceDataLog: _deviceDataLog,
              onStartRealtime: _startRealtime,
              onStopRealtime: _stopRealtime,
              onDisconnect: _disconnect,
            )
          else if (_isScanning)
            _ScanningView(
              s: s,
              rotationController: _rotationController,
              pulseController: _pulseController,
              onStop: _stopScan,
              onShowResults: _showDeviceModal,
              resultCount: _scanResults.length,
            )
          else
            _StartSearchView(
              s: s,
              pluginUnavailable: _pluginUnavailable,
              onScan: _scan,
            ),
        ],
      ),
    );
  }
}

// ── New Views ────────────────────────────────────────────────────────────

class _StartSearchView extends StatelessWidget {
  final double s;
  final bool pluginUnavailable;
  final VoidCallback onScan;

  const _StartSearchView({
    required this.s,
    required this.pluginUnavailable,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          const Spacer(),
          Icon(
            Icons.bluetooth_searching_rounded,
            size: 100 * s,
            color: AppColors.cyan.withAlpha(40),
          ),
          SizedBox(height: 40 * s),
          Text(
            'CONNECT YOUR BRACELET',
            style: GoogleFonts.inter(
              fontSize: 18 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 12 * s),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40 * s),
            child: Text(
              'Keep your bracelet close to your phone and make sure Bluetooth is enabled.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13 * s,
                color: AppColors.labelDim,
                height: 1.5,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * s),
            child: _PillButton(
              s: s,
              label: 'START SCANNING',
              onTap: pluginUnavailable ? () {} : onScan,
            ),
          ),
          if (pluginUnavailable) ...[
            SizedBox(height: 20 * s),
            Text(
              'Bluetooth Plugin Unavailable',
              style: TextStyle(color: Colors.redAccent, fontSize: 12 * s),
            ),
          ],
          SizedBox(height: 40 * s),
        ],
      ),
    );
  }
}

// ── Pill Button ─────────────────────────────────────────────────────────
class _PillButton extends StatelessWidget {
  final double s;
  final String label;
  final VoidCallback onTap;

  const _PillButton({
    required this.s,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54 * s,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16 * s),
          gradient: const LinearGradient(
            colors: [Color(0xFF757575), Color(0xFF424242)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 16 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanningView extends StatelessWidget {
  final double s;
  final AnimationController rotationController;
  final AnimationController pulseController;
  final VoidCallback onStop;
  final VoidCallback onShowResults;
  final int resultCount;

  const _ScanningView({
    required this.s,
    required this.rotationController,
    required this.pulseController,
    required this.onStop,
    required this.onShowResults,
    required this.resultCount,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(height: 40 * s),
          Text(
            'Searching for your Device',
            style: GoogleFonts.inter(
              fontSize: 22 * s,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFE0E0E0),
            ),
          ),
          const Spacer(),
          _RadarAnimation(
            s: s,
            rotation: rotationController,
            pulse: pulseController,
            resultCount: resultCount,
          ),
          const Spacer(flex: 2),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * s),
            child: _PillButton(
              s: s,
              label: 'Select your Device',
              onTap: onShowResults,
            ),
          ),
          SizedBox(height: 40 * s),
        ],
      ),
    );
  }
}

class _ConnectedView extends StatelessWidget {
  final double s;
  final String connectionStatus;
  final bool realtimeActive;
  final List<String> deviceDataLog;
  final VoidCallback onStartRealtime;
  final VoidCallback onStopRealtime;
  final VoidCallback onDisconnect;

  const _ConnectedView({
    required this.s,
    required this.connectionStatus,
    required this.realtimeActive,
    required this.deviceDataLog,
    required this.onStartRealtime,
    required this.onStopRealtime,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusChip(s: s, label: connectionStatus.toUpperCase()),
        SizedBox(height: 20 * s),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                s: s,
                label: realtimeActive ? 'STOP DATA' : 'START DATA',
                onTap: realtimeActive ? onStopRealtime : onStartRealtime,
                active: realtimeActive,
              ),
            ),
            SizedBox(width: 8 * s),
            Expanded(
              child: _ActionButton(
                s: s,
                label: 'DISCONNECT',
                onTap: onDisconnect,
              ),
            ),
          ],
        ),
        SizedBox(height: 20 * s),
        _DataLogPanel(s: s, lines: deviceDataLog),
        SizedBox(height: 20 * s),
        _ActionButton(
          s: s,
          label: 'GO TO DASHBOARD',
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const BraceletScreen()),
            );
          },
          active: true,
        ),
      ],
    );
  }
}

// ── Custom Animations ──────────────────────────────────────────────────

class _RadarAnimation extends StatelessWidget {
  final double s;
  final Animation<double> rotation;
  final Animation<double> pulse;
  final int resultCount;

  const _RadarAnimation({
    required this.s,
    required this.rotation,
    required this.pulse,
    required this.resultCount,
  });

  @override
  Widget build(BuildContext context) {
    final size = 300.0 * s;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dark Background Circle
          Container(
            width: size * 0.9,
            height: size * 0.9,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF121212),
            ),
          ),

          // Sublte Radar Rings
          ...List.generate(3, (i) {
            return Container(
              width: size * 0.9 * (1.0 - (i + 1) * 0.25),
              height: size * 0.9 * (1.0 - (i + 1) * 0.25),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10, width: 0.5),
              ),
            );
          }),

          // Spinning Radar Sweep
          RotationTransition(
            turns: rotation,
            child: Container(
              width: size * 0.9,
              height: size * 0.9,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Colors.transparent,
                    Color.fromRGBO(124, 252, 0, 0.4),
                    Colors.transparent,
                  ],
                  stops: [0.45, 0.5, 0.55],
                ),
              ),
            ),
          ),

          // Center Circle with count
          Container(
            width: 70 * s,
            height: 70 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              border: Border.all(color: Colors.white12, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(100),
                  blurRadius: 10 * s,
                  spreadRadius: 2 * s,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$resultCount',
                style: GoogleFonts.inter(
                  fontSize: 26 * s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // "Device Found" text below center
          Positioned(
            top: size / 2 + 45 * s,
            child: Text(
              'Device Found',
              style: GoogleFonts.inter(
                fontSize: 14 * s,
                color: const Color(0xFF9E9E9E),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Sheet ─────────────────────────────────────────────────────────

class _DeviceBottomSheet extends StatefulWidget {
  final double s;
  final List<Map<Object?, Object?>> scanResults;
  final Function(String) onConnect;
  final VoidCallback onScanToggle;
  final bool isScanning;

  const _DeviceBottomSheet({
    required this.s,
    required this.scanResults,
    required this.onConnect,
    required this.onScanToggle,
    required this.isScanning,
  });

  @override
  State<_DeviceBottomSheet> createState() => _DeviceBottomSheetState();
}

class _DeviceBottomSheetState extends State<_DeviceBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark grey from screenshot
        borderRadius: BorderRadius.vertical(top: Radius.circular(36 * s)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20 * s,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12 * s),
          // Top Bar with Title and Scan Icon
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 8 * s),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select your Device',
                  style: GoogleFonts.inter(
                    fontSize: 20 * s,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 24 * s,
                ),
              ],
            ),
          ),

          SizedBox(height: 12 * s),

          Expanded(
            child: widget.scanResults.isEmpty
                ? Center(
                    child: Text(
                      'No devices found...',
                      style: TextStyle(
                        color: AppColors.labelDim,
                        fontSize: 14 * s,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20 * s),
                    itemCount: widget.scanResults.length,
                    itemBuilder: (context, index) {
                      final m = widget.scanResults[index];
                      return _DeviceTile(
                        s: s,
                        name: m['name'] as String? ?? 'Unknown',
                        identifier: m['identifier'] as String? ?? '',
                        onTap: () {
                          widget.onConnect(m['identifier'] as String);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
          SizedBox(height: 10 * s),
        ],
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
  final VoidCallback onTap;

  const _DeviceTile({
    required this.s,
    required this.name,
    required this.identifier,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12 * s),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16 * s),
          decoration: BoxDecoration(
            color: Colors.black, // From screenshot
            borderRadius: BorderRadius.circular(16 * s),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 15 * s,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      identifier,
                      style: GoogleFonts.inter(
                        fontSize: 11 * s,
                        color: Colors.white38,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8 * s),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF7CFC00).withAlpha(30), // Green glow
                ),
                child: Icon(
                  Icons.wifi_rounded,
                  color: const Color(0xFF7CFC00),
                  size: 20 * s,
                ),
              ),
            ],
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
      height: 220 * s,
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
              padding: EdgeInsets.only(bottom: 4 * s),
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
