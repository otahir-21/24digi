import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'widgets/shop_top_bar.dart';
import 'widgets/shop_drawer.dart';

class ShopChatScreen extends StatelessWidget {
  const ShopChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1C1A),
      endDrawer: const ShopDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const ShopTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: Column(
                  children: [
                    SizedBox(height: 12 * s),
                    Center(
                      child: Text(
                        'HI, USER',
                        style: GoogleFonts.outfit(
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 24 * s),
                    Text(
                      'Support',
                      style: GoogleFonts.outfit(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 32 * s),

                    // Chat History
                    _BotBubble(text: 'Hello!', time: '09:00', s: s),
                    _UserBubble(text: 'Hello, please choose the number corresponding to your needs for a more efficient service.', time: '09:00', s: s),
                    _UserBubble(
                      text: '1. Order Management\n2. Payments Management\n3. Account management and profile\n4. About order tracking\n5. Safety',
                      time: '09:00',
                      s: s,
                    ),
                    _BotBubble(text: '1', time: '09:03', s: s),
                    _UserBubble(
                      text: 'You have a current order\nSport T-Shirt and Track Shoes\nOrder No. 0054752\n29 Nov, 01:20 pm',
                      time: '09:04',
                      s: s,
                      actions: ['Order Issues', 'Order not received'],
                    ),
                    
                    SizedBox(height: 48 * s),
                  ],
                ),
              ),
            ),
            
            // Bottom Input Bar
            _buildInputBar(s),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(double s) {
    return Container(
      padding: EdgeInsets.fromLTRB(20 * s, 10 * s, 20 * s, 30 * s),
      color: Colors.transparent,
      child: Row(
        children: [
          Icon(Icons.attach_file_rounded, color: Colors.white70, size: 24 * s),
          SizedBox(width: 12 * s),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16 * s),
              decoration: BoxDecoration(
                color: const Color(0xFFEFDFCF),
                borderRadius: BorderRadius.circular(12 * s),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Write Here...',
                  hintStyle: GoogleFonts.outfit(color: Colors.black.withOpacity(0.24)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 12 * s),
          Icon(Icons.mic_none_rounded, color: Colors.white70, size: 24 * s),
          SizedBox(width: 12 * s),
          Icon(Icons.send_rounded, color: Colors.white70, size: 24 * s),
        ],
      ),
    );
  }
}

class _BotBubble extends StatelessWidget {
  final String text;
  final String time;
  final double s;

  const _BotBubble({required this.text, required this.time, required this.s});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1813),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12 * s),
                bottomLeft: Radius.circular(12 * s),
                bottomRight: Radius.circular(12 * s),
              ),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(text, style: GoogleFonts.outfit(fontSize: 13 * s, color: Colors.white70)),
          ),
          Padding(
            padding: EdgeInsets.only(top: 4 * s, bottom: 16 * s),
            child: Text(time, style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.white24)),
          ),
        ],
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String text;
  final String time;
  final double s;
  final List<String>? actions;

  const _UserBubble({required this.text, required this.time, required this.s, this.actions});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2622),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12 * s),
                bottomLeft: Radius.circular(12 * s),
                bottomRight: Radius.circular(12 * s),
              ),
              border: Border.all(color: const Color(0xFFEBC17B).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: GoogleFonts.outfit(fontSize: 13 * s, color: Colors.white, height: 1.4)),
                if (actions != null) ...[
                  SizedBox(height: 12 * s),
                  Row(
                    children: actions!.map((a) => Container(
                      margin: EdgeInsets.only(right: 8 * s),
                      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(20 * s),
                      ),
                      child: Text(a, style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.white70)),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 4 * s, bottom: 16 * s),
            child: Text(time, style: GoogleFonts.outfit(fontSize: 10 * s, color: Colors.white24)),
          ),
        ],
      ),
    );
  }
}
