import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bracelet/bracelet_alias_storage.dart';
import '../../bracelet/bracelet_channel.dart';
import '../../bracelet/bracelet_device_storage.dart';
import '../../core/app_constants.dart';
import 'bracelet_scaffold.dart';

class BraceletManageScreen extends StatefulWidget {
  const BraceletManageScreen({super.key});

  @override
  State<BraceletManageScreen> createState() => _BraceletManageScreenState();
}

class _BraceletManageScreenState extends State<BraceletManageScreen> {
  final BraceletChannel _channel = BraceletChannel();

  bool _connected = false;
  String? _identifier;
  String? _hardwareName;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchConnectionState();
    // Ensure device info is loaded so rename/forget work even when disconnected.
    BraceletDeviceStorage.load().then((_) async {
      final id = BraceletDeviceStorage.lastIdentifier;
      if (id != null) await BraceletAliasStorage.load(id);
      if (mounted) setState(() {});
    });
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

  Future<void> _fetchConnectionState() async {
    try {
      final st = await _channel.getConnectionState();
      if (!mounted) return;
      setState(() {
        _connected = st['connected'] == true;
        _identifier = st['identifier'] as String?;
        _hardwareName = st['name'] as String?;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? get _bestIdentifier =>
      _identifier ?? BraceletDeviceStorage.lastIdentifier;

  String get _displayName {
    final id = _bestIdentifier;
    if (id != null) {
      final alias = BraceletAliasStorage.currentAlias;
      if (alias != null && alias.isNotEmpty) return alias;
    }
    if (_hardwareName != null && _hardwareName!.isNotEmpty) return _hardwareName!;
    return BraceletDeviceStorage.lastName ?? '24DIGI Bracelet';
  }

  String _formatLastSync() {
    final t = BraceletDeviceStorage.lastSyncTime;
    if (t == null) return 'Never';
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _showRenameDialog() async {
    final id = _bestIdentifier;
    if (!mounted) return;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No device found. Connect a bracelet first.', style: GoogleFonts.inter()),
        backgroundColor: const Color(0xFF1A2332),
      ));
      return;
    }
    final current = BraceletAliasStorage.displayName(id, _hardwareName ?? '24DIGI Bracelet');
    final ctrl = TextEditingController(text: current);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Rename Device',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 30,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Enter device name',
            hintStyle: GoogleFonts.inter(color: Colors.white38),
            counterStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00F0FF))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00F0FF), width: 2)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white38)),
          ),
          if (BraceletAliasStorage.currentAlias != null)
            TextButton(
              onPressed: () async {
                await BraceletAliasStorage.clear(id);
                if (mounted) setState(() {});
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text('Reset', style: GoogleFonts.inter(color: Colors.redAccent)),
            ),
          TextButton(
            onPressed: () {
              BraceletAliasStorage.setAlias(id, ctrl.text);
              if (_connected) _channel.setDeviceName(ctrl.text);
              if (mounted) setState(() {});
              Navigator.pop(ctx);
            },
            child: Text('Save', style: GoogleFonts.inter(color: const Color(0xFF00F0FF), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _disconnect() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Disconnect Bracelet', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
        content: Text('Are you sure you want to disconnect your bracelet?', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white38))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Disconnect', style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _channel.disconnect();
      if (!mounted) return;
      setState(() => _connected = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bracelet disconnected', style: GoogleFonts.inter()), backgroundColor: const Color(0xFF1A2332)),
      );
    } catch (_) {}
  }

  Future<void> _forgetDevice() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Forget Device', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
        content: Text('This will remove the saved device. You will need to scan and reconnect.', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white38))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Forget', style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      if (_connected) await _channel.disconnect();
      final id = _bestIdentifier;
      if (id != null) await BraceletAliasStorage.clear(id);
      await BraceletDeviceStorage.clear();
    } catch (_) {}
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Device forgotten', style: GoogleFonts.inter()), backgroundColor: const Color(0xFF1A2332)),
    );
    setState(() { _connected = false; _identifier = null; _hardwareName = null; });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return BraceletScaffold(
      title: 'Manage Device',
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00F0FF)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 8 * s),

                // ── Device Card ────────────────────────────────────────
                _DeviceCard(
                  s: s,
                  displayName: _displayName,
                  connected: _connected,
                  lastSync: _formatLastSync(),
                  onRename: _showRenameDialog,
                ),
                SizedBox(height: 24 * s),

                // ── Quick Stats Row ────────────────────────────────────
                _StatsRow(s: s, lastSync: _formatLastSync(), connected: _connected),
                SizedBox(height: 24 * s),

                // ── Actions Section ────────────────────────────────────
                _SectionLabel(s: s, label: 'DEVICE ACTIONS'),
                SizedBox(height: 10 * s),
                _ActionTile(
                  s: s,
                  icon: Icons.dashboard_rounded,
                  iconColor: const Color(0xFF00F0FF),
                  title: 'Go to Dashboard',
                  subtitle: 'View health metrics and activity',
                  onTap: () => Navigator.pop(context),
                ),
                _ActionTile(
                  s: s,
                  icon: Icons.edit_rounded,
                  iconColor: const Color(0xFFC084FC),
                  title: 'Rename Device',
                  subtitle: _displayName,
                  onTap: _showRenameDialog,
                ),
                if (_connected)
                  _ActionTile(
                    s: s,
                    icon: Icons.sync_rounded,
                    iconColor: const Color(0xFF4ADE80),
                    title: 'Refresh Connection',
                    subtitle: 'Re-fetch latest data from bracelet',
                    onTap: _fetchConnectionState,
                  ),
                SizedBox(height: 16 * s),

                // ── Danger Section ─────────────────────────────────────
                _SectionLabel(s: s, label: 'CONNECTION'),
                SizedBox(height: 10 * s),
                if (_connected)
                  _ActionTile(
                    s: s,
                    icon: Icons.bluetooth_disabled_rounded,
                    iconColor: Colors.orangeAccent,
                    title: 'Disconnect',
                    subtitle: 'Pause connection to bracelet',
                    onTap: _disconnect,
                  ),
                _ActionTile(
                  s: s,
                  icon: Icons.link_off_rounded,
                  iconColor: Colors.redAccent,
                  title: 'Forget Device',
                  subtitle: 'Remove saved device and disconnect',
                  isDestructive: true,
                  onTap: _forgetDevice,
                ),
                SizedBox(height: 40 * s),
              ],
            ),
    );
  }
}

// ── Device Card ─────────────────────────────────────────────────────────────
class _DeviceCard extends StatelessWidget {
  final double s;
  final String displayName;
  final bool connected;
  final String lastSync;
  final VoidCallback onRename;

  const _DeviceCard({
    required this.s,
    required this.displayName,
    required this.connected,
    required this.lastSync,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF111B27),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        children: [
          // Watch icon with glow
          Container(
            width: 56 * s,
            height: 56 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00F0FF).withValues(alpha: 0.08),
              border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.3), width: 1),
            ),
            child: Icon(Icons.watch_rounded, color: const Color(0xFF00F0FF), size: 28 * s),
          ),
          SizedBox(width: 16 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.inter(fontSize: 16 * s, fontWeight: FontWeight.w700, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4 * s),
                Text(
                  '24DIGI Smart Bracelet',
                  style: GoogleFonts.inter(fontSize: 11 * s, color: Colors.white38),
                ),
                SizedBox(height: 8 * s),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 3 * s),
                      decoration: BoxDecoration(
                        color: connected
                            ? const Color(0xFF4ADE80).withValues(alpha: 0.12)
                            : Colors.white12,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: connected ? const Color(0xFF4ADE80).withValues(alpha: 0.5) : Colors.white24,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6 * s,
                            height: 6 * s,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: connected ? const Color(0xFF4ADE80) : Colors.white38,
                            ),
                          ),
                          SizedBox(width: 5 * s),
                          Text(
                            connected ? 'Connected' : 'Disconnected',
                            style: GoogleFonts.inter(
                              fontSize: 10 * s,
                              fontWeight: FontWeight.w600,
                              color: connected ? const Color(0xFF4ADE80) : Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRename,
            child: Container(
              padding: EdgeInsets.all(8 * s),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10 * s),
              ),
              child: Icon(Icons.edit_outlined, color: const Color(0xFF00F0FF), size: 18 * s),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final double s;
  final String lastSync;
  final bool connected;

  const _StatsRow({required this.s, required this.lastSync, required this.connected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            s: s,
            icon: Icons.sync_rounded,
            iconColor: const Color(0xFF00F0FF),
            label: 'Last Sync',
            value: lastSync,
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: _StatCard(
            s: s,
            icon: Icons.battery_full_rounded,
            iconColor: const Color(0xFF4ADE80),
            label: 'Battery',
            value: '—',
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: _StatCard(
            s: s,
            icon: Icons.bluetooth_rounded,
            iconColor: connected ? const Color(0xFF00F0FF) : Colors.white38,
            label: 'Status',
            value: connected ? 'Active' : 'Off',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final double s;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.s,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14 * s, horizontal: 12 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF111B27),
        borderRadius: BorderRadius.circular(14 * s),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20 * s),
          SizedBox(height: 6 * s),
          Text(value, style: GoogleFonts.inter(fontSize: 13 * s, fontWeight: FontWeight.w700, color: Colors.white)),
          SizedBox(height: 2 * s),
          Text(label, style: GoogleFonts.inter(fontSize: 10 * s, color: Colors.white38)),
        ],
      ),
    );
  }
}

// ── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final double s;
  final String label;

  const _SectionLabel({required this.s, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4 * s, bottom: 2 * s),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 11 * s, fontWeight: FontWeight.w700, color: Colors.white38, letterSpacing: 1.0),
      ),
    );
  }
}

// ── Action Tile ──────────────────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final double s;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isDestructive;
  final VoidCallback onTap;

  const _ActionTile({
    required this.s,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10 * s),
        padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 14 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF111B27),
          borderRadius: BorderRadius.circular(14 * s),
          border: Border.all(
            color: isDestructive ? Colors.redAccent.withValues(alpha: 0.25) : Colors.white12,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8 * s),
              decoration: BoxDecoration(
                color: (isDestructive ? Colors.redAccent : iconColor).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10 * s),
              ),
              child: Icon(icon, color: isDestructive ? Colors.redAccent : iconColor, size: 18 * s),
            ),
            SizedBox(width: 14 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14 * s,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.redAccent : Colors.white,
                    ),
                  ),
                  SizedBox(height: 2 * s),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 11 * s, color: Colors.white38)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 20 * s),
          ],
        ),
      ),
    );
  }
}
