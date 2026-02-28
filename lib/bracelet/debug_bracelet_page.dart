import 'dart:async';
import 'package:flutter/material.dart';
import 'bracelet_channel.dart';

/// Minimal debug screen: buttons (Scan / Connect / Start Realtime / Stop / Disconnect)
/// and text log of incoming stream events.
class DebugBraceletPage extends StatefulWidget {
  const DebugBraceletPage({super.key});

  @override
  State<DebugBraceletPage> createState() => _DebugBraceletPageState();
}

class _DebugBraceletPageState extends State<DebugBraceletPage> {
  final BraceletChannel _channel = BraceletChannel();
  final List<String> _log = [];
  StreamSubscription<BraceletEvent>? _subscription;
  List<Map<Object?, Object?>> _scanResults = [];
  List<Map<Object?, Object?>> _retrievedDevices = [];
  String? _selectedIdentifier;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  void _listen() {
    _subscription?.cancel();
    _subscription = _channel.events.listen((BraceletEvent e) {
      _append('${e.event}: ${e.data}');
      if (e.event == 'scanResult' && e.data['identifier'] != null) {
        setState(() {
          final id = e.data['identifier'] as String?;
          final name = e.data['name'] as String? ?? 'Unknown';
          final rssi = e.data['rssi'];
          if (id != null && !_scanResults.any((m) => m['identifier'] == id)) {
            _scanResults.add({'identifier': id, 'name': name, 'rssi': rssi});
          }
        });
      }
    });
  }

  void _append(String line) {
    debugPrint(line);
    setState(() {
      _log.insert(0, line);
      if (_log.length > 500) _log.removeLast();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _scan() async {
    setState(() => _scanResults = []);
    _append('Scan started.');
    try {
      await _channel.scan();
    } catch (e) {
      _append('Scan error: $e');
    }
  }

  Future<void> _stopScan() async {
    try {
      await _channel.stopScan();
      _append('Scan stopped.');
    } catch (e) {
      _append('StopScan error: $e');
    }
  }

  Future<void> _loadRetrieved() async {
    try {
      final list = await _channel.getRetrievedDevices();
      setState(() => _retrievedDevices = list);
      _append('Retrieved devices: ${list.length}');
    } catch (e) {
      _append('getRetrievedDevices error: $e');
    }
  }

  Future<void> _connect(String identifier) async {
    _append('Connecting to $identifier');
    setState(() => _selectedIdentifier = identifier);
    try {
      await _channel.connect(identifier);
    } catch (e) {
      _append('Connect error: $e');
    }
  }

  Future<void> _startRealtime() async {
    try {
      await _channel.startRealtime(RealtimeType.stepWithTemp);
      _append('Realtime started (stepWithTemp).');
    } catch (e) {
      _append('StartRealtime error: $e');
    }
  }

  Future<void> _stopRealtime() async {
    try {
      await _channel.stopRealtime();
      _append('Realtime stopped.');
    } catch (e) {
      _append('StopRealtime error: $e');
    }
  }

  Future<void> _disconnect() async {
    try {
      await _channel.disconnect();
      _append('Disconnected.');
      setState(() => _selectedIdentifier = null);
    } catch (e) {
      _append('Disconnect error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Bracelet')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(onPressed: _scan, child: const Text('Scan')),
                ElevatedButton(onPressed: _stopScan, child: const Text('Stop Scan')),
                ElevatedButton(onPressed: _loadRetrieved, child: const Text('Retrieved')),
                ElevatedButton(onPressed: _startRealtime, child: const Text('Start Realtime')),
                ElevatedButton(onPressed: _stopRealtime, child: const Text('Stop')),
                ElevatedButton(onPressed: _disconnect, child: const Text('Disconnect')),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: [
                      const Text('Scanned / Retrieved (tap to connect)', style: TextStyle(fontWeight: FontWeight.bold)),
                      ..._scanResults.map((m) => ListTile(
                        title: Text('${m['name']} (${m['identifier']})'),
                        subtitle: Text('RSSI: ${m['rssi']}'),
                        onTap: () => _connect(m['identifier'] as String),
                      )),
                      ..._retrievedDevices.map((m) => ListTile(
                        title: Text('${m['name']} (${m['identifier']})'),
                        onTap: () => _connect(m['identifier'] as String),
                      )),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.black87,
                    padding: const EdgeInsets.all(8),
                    child: ListView.builder(
                      itemCount: _log.length,
                      itemBuilder: (_, i) => Text(_log[i], style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
