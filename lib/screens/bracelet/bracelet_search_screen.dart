import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/app_constants.dart';
import '../../providers/navigation_provider.dart';
import '../../bracelet/bracelet_channel.dart';
import '../../bracelet/bracelet_alias_storage.dart';
import '../../bracelet/bracelet_verbose_log.dart';
import '../../bracelet/data/bracelet_data_parser.dart';
import 'bracelet_scaffold.dart';
import 'bracelet_screen.dart';

/// Search for BLE bracelet devices, pair (connect), and show live data from device.
class BraceletSearchScreen extends StatefulWidget {
  const BraceletSearchScreen({super.key});

  @override
  State<BraceletSearchScreen> createState() => _BraceletSearchScreenState();
}

/// Name substrings that identify bracelet devices (case-insensitive).
/// Only devices matching one of these are shown in the scan list.
/// Index of the bracelet tab in [MainNavigationScaffold] (nested [Navigator]).
const int _kBraceletTabNavigatorIndex = 1;

const List<String> _braceletNameKeywords = [
  'bracelet',
  'jstyle',
  '2208',
  '24digi',
  'band',
  'band 2',
];

bool _isBraceletDevice(String name) {
  if (name.isEmpty || name == 'Unknown') return false;
  final lower = name.toLowerCase();
  return _braceletNameKeywords.any((k) => lower.contains(k));
}

class _BraceletSearchScreenState extends State<BraceletSearchScreen>
    with TickerProviderStateMixin {
  final BraceletChannel _channel = BraceletChannel();
  StreamSubscription<BraceletEvent>? _subscription;

  List<Map<Object?, Object?>> _scanResults = [];
  String? _selectedIdentifier;
  /// Hardware device name (from BLE scan). Alias is stored in [BraceletAliasStorage].
  String _connectedHardwareName = 'Bracelet';
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
  /// Request device data every 1s when connected (so data flows even on search screen).
  Timer? _refreshTimer;
  /// When true, show only a connecting dialog; do not show the pair/connected screen until connected.
  bool _connectingDialogVisible = false;
  String? _connectingDeviceName;
  /// After connect: wait for first type 24/25 before navigating so dashboard has initialRealtimeData.
  bool _waitingForFirstPayload = false;
  Timer? _navigateAfterConnectTimeout;

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
    BraceletAliasStorage.revision.addListener(_onAliasChanged);
    _listen();
    _restoreConnectionState();
  }

  void _onAliasChanged() {
    if (mounted) setState(() {});
  }

  /// If bracelet is still connected (e.g. app was in background), restore UI, start 1s refresh, and go to dashboard.
  Future<void> _restoreConnectionState() async {
    if (_pluginUnavailable) return;
    try {
      final state = await _channel.getConnectionState();
      final connected = state['connected'] == true;
      if (!connected || !mounted) return;
      final id = state['identifier'] as String?;
      final name = state['name'] as String? ?? 'Bracelet';
      await BraceletAliasStorage.load(id);
      setState(() {
        _connectionStatus = 'Connected';
        _selectedIdentifier = id;
        _connectedHardwareName = name;
        if (id != null && !_scanResults.any((m) => m['identifier'] == id)) {
          _scanResults.add({'identifier': id, 'name': name, 'rssi': null});
        }
      });
      _startRefreshTimer();
      // Route through _navigateToDashboard so the _hasNavigatedToDashboardThisSession
      // flag is set atomically — prevents a second navigation if a realtimeData event
      // fires during the async gap above and already scheduled a push.
      _navigateToDashboard(null);
    } catch (_) {}
  }

  /// Request device data every 1 second when connected (runs on search screen until we navigate).
  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    void tick() async {
      if (!mounted) return;
      try {
        final state = await _channel.getConnectionState();
        if (state['connected'] == true) {
          braceletVerboseLog(
            '[Bracelet] Request data (search) @ ${DateTime.now().toString().substring(11, 19)}',
          );
          // Do not call startRealtime every second — it floods BLE and prevents type 25/26 responses.
          await _channel.requestTotalActivityData();
          await Future<void>.delayed(const Duration(milliseconds: 150));
          if (!mounted) return;
          await _channel.requestDetailActivityData();
        }
      } catch (_) {}
    }
    tick();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  void _stopRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Request data immediately and navigate when first type 24/25 arrives, or after timeout.
  void _requestDataAndScheduleNavigate() {
    braceletVerboseLog('[Bracelet Request] Starting data request & schedule navigate');
    _navigateAfterConnectTimeout?.cancel();
    _waitingForFirstPayload = true;
    braceletVerboseLog('[Bracelet Request] Set _waitingForFirstPayload = true');
    void requestNow() async {
      if (!mounted) return;
      try {
        final state = await _channel.getConnectionState();
        if (state['connected'] == true) {
          braceletVerboseLog('[Bracelet Request] Connected, requesting realtime data');
          await _channel.startRealtime(RealtimeType.step);
          await _channel.requestTotalActivityData();
          await Future<void>.delayed(const Duration(milliseconds: 150));
          if (!mounted) return;
          await _channel.requestDetailActivityData();
        }
      } catch (_) {}
    }
    requestNow();
    _navigateAfterConnectTimeout = Timer(const Duration(milliseconds: 2500), () {
      braceletVerboseLog('[Bracelet Request] Navigate timeout fired');
      if (!mounted || _hasNavigatedToDashboardThisSession) return;
      _navigateToDashboard(null);
    });
  }

  /// Cancel our event subscription before pushReplacement so the dashboard stays the
  /// active realtime listener. Otherwise the new route is built first (dashboard
  /// subscribes), then this screen is disposed; native EventChannel removes the last
  /// sink (LIFO) and drops the dashboard's stream, so type-24 stops after pairing.
  void _cancelSubscriptionBeforeNavigate() {
    braceletVerboseLog(
      '[Bracelet Stream] search: cancelling subscription before navigate channel=${_channel.hashCode}',
    );
    BraceletChannel.cancelBraceletSubscription(_subscription);
    _subscription = null;
  }

  /// Pushes [BraceletScreen] on the bracelet tab's nested navigator, replacing the
  /// whole tab stack. Required because [BraceletSearchScreen] lives under
  /// [MainNavigationScaffold]'s per-tab [Navigator], not the root route.
  void _pushBraceletDashboard(Map<String, dynamic>? initialData) {
    if (!mounted) return;
    final navProvider = context.read<NavigationProvider>();
    final tabNav =
        navProvider.navigatorKeys[_kBraceletTabNavigatorIndex].currentState;
    final navigator = tabNav ?? Navigator.of(context);
    final route = MaterialPageRoute<void>(
      builder: (_) => initialData != null && initialData.isNotEmpty
          ? BraceletScreen(initialRealtimeData: initialData)
          : const BraceletScreen(),
    );
    navigator.pushAndRemoveUntil(route, (Route<dynamic> r) => false);
  }

  /// After [showDialog] / [Navigator.pop], the navigator can still be locked for
  /// one frame; use two post-frame callbacks before pushing.
  void _scheduleBraceletDashboardNavigation(
    Map<String, dynamic>? initialData, {
    VoidCallback? onFailure,
  }) {
    if (!mounted) return;
    braceletVerboseLog('[Bracelet Navigate] Scheduling post-frame navigation (2 frames)');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        braceletVerboseLog('[Bracelet Navigate] Executing pushAndRemoveUntil on tab navigator');
        try {
          _pushBraceletDashboard(initialData);
          braceletVerboseLog('[Bracelet Navigate] Navigation succeeded');
        } catch (error, stack) {
          braceletVerboseLog('[Bracelet Navigate] Navigation failed: $error');
          debugPrintStack(stackTrace: stack);
          onFailure?.call();
        }
      });
    });
  }

  void _navigateToDashboard(Map<String, dynamic>? initialData) {
    braceletVerboseLog('[Bracelet Navigate] _navigateToDashboard called with data: ${initialData != null ? 'YES' : 'NO'}, hasNavigated: $_hasNavigatedToDashboardThisSession');
    if (_hasNavigatedToDashboardThisSession) {
      braceletVerboseLog('[Bracelet Navigate] Already navigated, skipping');
      return;
    }
    _hasNavigatedToDashboardThisSession = true;
    _waitingForFirstPayload = false;
    _navigateAfterConnectTimeout?.cancel();
    _navigateAfterConnectTimeout = null;

    // showDialog uses useRootNavigator:true by default, so the dialog sits on
    // the ROOT navigator — not the nested tab navigator. We must pop from root.
    if (_connectingDialogVisible && mounted) {
      final rootNav = Navigator.of(context, rootNavigator: true);
      if (rootNav.canPop()) rootNav.pop();
      setState(() {
        _connectingDialogVisible = false;
        _connectingDeviceName = null;
      });
    }

    _cancelSubscriptionBeforeNavigate();
    if (!mounted) {
      _hasNavigatedToDashboardThisSession = false;
      return;
    }
    _scheduleBraceletDashboardNavigation(
      initialData,
      onFailure: () {
        if (mounted) _hasNavigatedToDashboardThisSession = false;
      },
    );
  }

  void _onManualGoToDashboard() {
    _cancelSubscriptionBeforeNavigate();
    if (!mounted) return;
    _scheduleBraceletDashboardNavigation(null);
  }

  Future<void> _showRenameDialog() async {
    final identifier = _selectedIdentifier;
    if (identifier == null || !mounted) return;
    final currentDisplay = BraceletAliasStorage.displayName(
      identifier,
      _connectedHardwareName,
    );
    final controller = TextEditingController(text: currentDisplay);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Rename Bracelet',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 30,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: _connectedHardwareName,
            hintStyle: GoogleFonts.inter(color: AppColors.labelDim),
            counterStyle: GoogleFonts.inter(color: AppColors.labelDim, fontSize: 11),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.cyan),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.cyan, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.labelDim),
            ),
          ),
          if (BraceletAliasStorage.currentAlias != null)
            TextButton(
              onPressed: () {
                BraceletAliasStorage.clear(identifier);
                if (mounted) setState(() {});
                Navigator.of(ctx).pop();
              },
              child: Text(
                'Reset',
                style: GoogleFonts.inter(color: Colors.redAccent),
              ),
            ),
          TextButton(
            onPressed: () {
              BraceletAliasStorage.setAlias(identifier, controller.text);
              if (mounted) setState(() {});
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                color: AppColors.cyan,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    // controller is intentionally not disposed here: the dialog's dismiss
    // animation runs for one more frame after showDialog returns and Flutter
    // would call addListener on an already-disposed controller → crash.
    // Short-lived dialog controllers are safely GC'd without explicit dispose.
  }

  void _markPluginUnavailable() {
    if (!_pluginUnavailable) {
      setState(() => _pluginUnavailable = true);
      _addLog('Bracelet plugin not available on this build.');
    }
  }

  void _listen() {
    _subscription?.cancel();
    braceletVerboseLog(
      '[Bracelet Stream] search: subscribe channel=${_channel.hashCode}',
    );
    try {
      _subscription = _channel.events.listen(
        (BraceletEvent e) {
          if (e.event == 'scanResult') {
            final n = e.data['name'] as String? ?? '';
            if (_isBraceletDevice(n)) {
              _addLog('scanResult: ${e.data}');
            }
          } else {
            _addLog('${e.event}: ${e.data}');
          }
          if (e.event == 'scanResult' && e.data['identifier'] != null) {
            setState(() {
              final id = e.data['identifier'] as String?;
              final name = e.data['name'] as String? ?? 'Unknown';
              final rssi = e.data['rssi'];
              // Only show bracelet devices in the list (filter out other BLE devices)
              if (id != null &&
                  _isBraceletDevice(name) &&
                  !_scanResults.any((m) => m['identifier'] == id)) {
                _scanResults.add({
                  'identifier': id,
                  'name': name,
                  'rssi': rssi,
                });
                // Load alias from disk so the scan modal shows the user's
                // chosen name instead of the raw hardware name.
                if (id != BraceletAliasStorage.currentIdentifier) {
                  unawaited(BraceletAliasStorage.load(id));
                }

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
              braceletVerboseLog('[Bracelet Connection] State changed to: $state');
              if (state.toLowerCase().contains('disconnect') || state == '0') {
                _selectedIdentifier = null;
                _realtimeActive = false;
                _hasNavigatedToDashboardThisSession = false;
                _stopRefreshTimer();
                braceletVerboseLog('[Bracelet Connection] Disconnected, reset nav flag');
              } else if (state.toLowerCase().contains('connect')) {
                _startRefreshTimer();
                braceletVerboseLog('[Bracelet Connection] Starting refresh timer');
              }
            });
            // When connected: request data and wait for first type 24/25 so dashboard opens with initialRealtimeData.
            if ((e.data['state']?.toString() ?? '').toLowerCase() ==
                    'connected' &&
                mounted &&
                !_hasNavigatedToDashboardThisSession) {
              braceletVerboseLog('[Bracelet Connect] Device connected, requesting data');
              _requestDataAndScheduleNavigate();
            }
          } else if (e.event == 'realtimeData') {
            setState(() {
              if (kDebugMode) {
                final type = BraceletDataParser.dataTypeAsInt(e.data['dataType']);
                if (type != 38 && type != 42 && type != 43 && type != 57) {
                  _addLog('DEVICE DATA: ${e.data}');
                }
              }
            });
            final dic = e.data['dicData'];
            braceletVerboseLog('[Bracelet Realtime] Got realtimeData, checking nav conditions: waiting=$_waitingForFirstPayload, hasNav=$_hasNavigatedToDashboardThisSession, dic=${dic != null ? 'yes' : 'no'}');
            if (dic != null && dic is Map && _waitingForFirstPayload && !_hasNavigatedToDashboardThisSession) {
              braceletVerboseLog('[Bracelet Realtime] Condition 1 met: parsing data');
              final dicMap = Map<String, dynamic>.from(
                (dic as Map<Object?, Object?>).map(
                  (k, v) => MapEntry(k?.toString() ?? '', v),
                ),
              );
              final dataType = e.data['dataType'];
              final type = BraceletDataParser.dataTypeAsInt(dataType);
              Map<String, dynamic>? initialData;
              if (type == 24) {
                initialData = dicMap;
              } else if (type == 25) {
                initialData = BraceletDataParser.parseTotalActivityData(dicMap);
              }
              braceletVerboseLog('[Bracelet Realtime] Parsed type=$type, hasData=${initialData != null && initialData.isNotEmpty}');
              if (initialData != null && initialData.isNotEmpty) {
                braceletVerboseLog('[Bracelet Realtime] Calling _navigateToDashboard from condition 1');
                _navigateToDashboard(initialData);
              }
            }
            // Hot-restart path: already connected, got realtimeData; navigate with usable payload if we have one.
            final canNavigateFromState = _selectedIdentifier != null ||
                _connectionStatus.toLowerCase().contains('connect');
            braceletVerboseLog('[Bracelet Realtime] Checking condition 2: canNav=$canNavigateFromState, waiting=$_waitingForFirstPayload, hasNav=$_hasNavigatedToDashboardThisSession');
            if (mounted && !_hasNavigatedToDashboardThisSession && !_waitingForFirstPayload && canNavigateFromState && dic != null && dic is Map) {
              braceletVerboseLog('[Bracelet Realtime] Condition 2 met: hot-restart path');
              final dicMap = Map<String, dynamic>.from(
                (dic as Map<Object?, Object?>).map(
                  (k, v) => MapEntry(k?.toString() ?? '', v),
                ),
              );
              final dataType = e.data['dataType'];
              final type = BraceletDataParser.dataTypeAsInt(dataType);
              final Map<String, dynamic>? dataToPass = type == 24
                  ? dicMap
                  : (type == 25
                      ? BraceletDataParser.parseTotalActivityData(dicMap)
                      : dicMap);
              if (dataToPass != null && dataToPass.isNotEmpty) {
                _navigateToDashboard(dataToPass);
              }
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
    braceletVerboseLog(
      '[Bracelet Stream] search: dispose unsubscribe channel=${_channel.hashCode}',
    );
    BraceletAliasStorage.revision.removeListener(_onAliasChanged);
    _navigateAfterConnectTimeout?.cancel();
    _navigateAfterConnectTimeout = null;
    _stopRefreshTimer();
    _rotationController.dispose();
    _pulseController.dispose();
    BraceletChannel.cancelBraceletSubscription(_subscription);
    _subscription = null;
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

  Future<void> _connect(String identifier, [String? deviceName]) async {
    _addLog('Connecting to $identifier');
    final name = deviceName ?? 'Bracelet';
    unawaited(BraceletAliasStorage.load(identifier));
    setState(() {
      _selectedIdentifier = identifier;
      _connectedHardwareName = name;
      _connectionStatus = 'Connecting...';
      _connectingDialogVisible = true;
      _connectingDeviceName = name;
    });
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Connecting',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Connecting to $name...',
                style: GoogleFonts.inter(color: AppColors.labelDim, fontSize: 14),
              ),
              SizedBox(height: 20),
              const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
            ],
          ),
        ),
      ),
    );
    try {
      await _channel.connect(identifier);
    } on MissingPluginException catch (_) {
      _markPluginUnavailable();
      if (mounted && _connectingDialogVisible) {
        Navigator.of(context).pop();
      }
      setState(() {
        _selectedIdentifier = null;
        _connectionStatus = 'Disconnected';
        _connectingDialogVisible = false;
        _connectingDeviceName = null;
      });
    } catch (e) {
      _addLog('Connect error: $e');
      if (mounted && _connectingDialogVisible) {
        Navigator.of(context).pop();
      }
      setState(() {
        _selectedIdentifier = null;
        _connectionStatus = 'Disconnected';
        _connectingDialogVisible = false;
        _connectingDeviceName = null;
      });
      _stopRefreshTimer();
    }
  }

  Future<void> _startRealtime() async {
    try {
      await _channel.startRealtime(RealtimeType.step);
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
      _stopRefreshTimer();
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
        onConnect: (identifier, name) {
          Navigator.pop(context);
          _connect(identifier, name);
        },
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
          // While connecting, do not show the pair/connected screen; only the connecting dialog is shown.
          if (_selectedIdentifier != null && !_connectingDialogVisible)
            _ConnectedView(
              s: s,
              connectionStatus: _connectionStatus,
              realtimeActive: _realtimeActive,
              deviceDataLog: _deviceDataLog,
              deviceDisplayName: BraceletAliasStorage.displayName(
                _selectedIdentifier,
                _connectedHardwareName,
              ),
              onStartRealtime: _startRealtime,
              onStopRealtime: _stopRealtime,
              onDisconnect: _disconnect,
              onGoToDashboard: _onManualGoToDashboard,
              onRename: _showRenameDialog,
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
  final String deviceDisplayName;
  final VoidCallback onStartRealtime;
  final VoidCallback onStopRealtime;
  final VoidCallback onDisconnect;
  final VoidCallback onGoToDashboard;
  final VoidCallback onRename;

  const _ConnectedView({
    required this.s,
    required this.connectionStatus,
    required this.realtimeActive,
    required this.deviceDataLog,
    required this.deviceDisplayName,
    required this.onStartRealtime,
    required this.onStopRealtime,
    required this.onDisconnect,
    required this.onGoToDashboard,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusChip(s: s, label: connectionStatus.toUpperCase()),
        SizedBox(height: 16 * s),
        // ── Device name row ──────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                deviceDisplayName,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16 * s,
                ),
              ),
            ),
            SizedBox(width: 6 * s),
            GestureDetector(
              onTap: onRename,
              child: Icon(
                Icons.edit_outlined,
                color: AppColors.cyan,
                size: 18 * s,
              ),
            ),
          ],
        ),
        SizedBox(height: 16 * s),
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
          onTap: onGoToDashboard,
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
  final void Function(String identifier, String name) onConnect;
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
  void initState() {
    super.initState();
    BraceletAliasStorage.revision.addListener(_onAliasChanged);
  }

  @override
  void dispose() {
    BraceletAliasStorage.revision.removeListener(_onAliasChanged);
    super.dispose();
  }

  void _onAliasChanged() {
    if (mounted) setState(() {});
  }

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
                      final identifier = m['identifier'] as String? ?? '';
                      final hardwareName = m['name'] as String? ?? 'Unknown';
                      // Show alias if the user has renamed this device, otherwise the hardware name.
                      final displayName = BraceletAliasStorage.displayName(
                        identifier,
                        hardwareName,
                      );
                      return _DeviceTile(
                        s: s,
                        name: displayName,
                        identifier: identifier,
                        onTap: () {
                          // Always pass the hardware name to _connect so the
                          // alias dialog shows the real fallback name.
                          widget.onConnect(identifier, hardwareName);
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
