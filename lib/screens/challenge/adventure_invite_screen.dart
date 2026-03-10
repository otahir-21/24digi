import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';

class AdventureInviteScreen extends StatefulWidget {
  final String roomName;
  const AdventureInviteScreen({super.key, required this.roomName});

  @override
  State<AdventureInviteScreen> createState() => _AdventureInviteScreenState();
}

class _AdventureInviteScreenState extends State<AdventureInviteScreen> {
  static const Color _background = Color(0xFF1E1813);
  static const Color _panel = Color(0xFF13181D);
  static const Color _gold = Color(0xFFE0A10A);

  final List<Map<String, String>> _friends = [
    {'name': 'Khalfan', 'id': '@khalfan_7'},
    {'name': 'Mohammed', 'id': '@moe_dxb'},
    {'name': 'Yahya', 'id': '@yahya_runner'},
    {'name': 'Abdullah', 'id': '@abdullah_a'},
    {'name': 'Fatima', 'id': '@fatima_z'},
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(s),
            _buildSearchBar(s),
            _buildRecentAvatars(s),
            Expanded(child: _buildFriendsList(s)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
      child: Row(
        children: [
          GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.chevron_left, color: Colors.white, size: 28 * s)),
          const Spacer(),
          Text('INVITE TO GROUP', style: GoogleFonts.outfit(fontSize: 14 * s, fontWeight: FontWeight.w700, color: Colors.white)),
          const Spacer(),
          SizedBox(width: 28 * s),
        ],
      ),
    );
  }

  Widget _buildSearchBar(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
      child: Container(
        height: 44 * s,
        padding: EdgeInsets.symmetric(horizontal: 16 * s),
        decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(12 * s), border: Border.all(color: Colors.white12)),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.white38, size: 20 * s),
            SizedBox(width: 12 * s),
            Text('Search friends...', style: GoogleFonts.inter(fontSize: 13 * s, color: Colors.white38)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAvatars(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16 * s, 16 * s, 16 * s, 12 * s),
          child: Text('RECENT SEARCHES', style: GoogleFonts.inter(fontSize: 10 * s, fontWeight: FontWeight.w700, color: Colors.white38, letterSpacing: 1.0)),
        ),
        SizedBox(
          height: 60 * s,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16 * s),
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            separatorBuilder: (_, __) => SizedBox(width: 12 * s),
            itemBuilder: (_, i) => Container(
              width: 50 * s,
              height: 50 * s,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _gold, width: 1.5), image: const DecorationImage(image: AssetImage('assets/fonts/male.png'), fit: BoxFit.cover)),
            ),
          ),
        ),
        SizedBox(height: 12 * s),
        const Divider(color: Colors.white10),
      ],
    );
  }

  Widget _buildFriendsList(double s) {
    return ListView.builder(
      padding: EdgeInsets.all(16 * s),
      itemCount: _friends.length,
      itemBuilder: (_, i) {
        final friend = _friends[i];
        return Container(
          margin: EdgeInsets.only(bottom: 12 * s),
          padding: EdgeInsets.all(12 * s),
          decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(16 * s), border: Border.all(color: Colors.white12)),
          child: Row(
            children: [
              Container(width: 44 * s, height: 44 * s, decoration: const BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: AssetImage('assets/fonts/male.png'), fit: BoxFit.cover))),
              SizedBox(width: 12 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(friend['name']!, style: GoogleFonts.inter(fontSize: 14 * s, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text(friend['id']!, style: GoogleFonts.inter(fontSize: 11 * s, color: Colors.white38)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
                decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(20 * s)),
                child: Text('Invite', style: GoogleFonts.inter(fontSize: 12 * s, fontWeight: FontWeight.w700, color: Colors.black)),
              ),
            ],
          ),
        );
      },
    );
  }
}
