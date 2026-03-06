import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';

class SupportChatScreen extends StatelessWidget {
  const SupportChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1217),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16 * s,
                vertical: 10 * s,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 28 * s,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Support',
                    style: GoogleFonts.inter(
                      fontSize: 24 * s,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 28 * s),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 20 * s),
                decoration: BoxDecoration(
                  color: const Color(0xFF162026),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32 * s),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(24 * s),
                        children: [
                          _UserMessage(s: s, text: 'Hello!', time: '09:00'),
                          _BotMessage(
                            s: s,
                            text:
                                'Hello!, please choose the number corresponding to your needs for a more efficient service.',
                            time: '09:00',
                          ),
                          _BotMessage(
                            s: s,
                            text:
                                '1. Order Management\n2. Payments Management\n3. Account management and profile\n4. About order tracking\n5. Safety',
                            time: '09:00',
                          ),
                          _UserMessage(s: s, text: '1', time: '09:03'),
                          _BotMessage(
                            s: s,
                            time: '09:03',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'You have a current order\nStrawberry Shake and Broccoli Lasagna',
                                  style: GoogleFonts.inter(
                                    fontSize: 12 * s,
                                    color: Colors.white70,
                                  ),
                                ),
                                SizedBox(height: 8 * s),
                                Text(
                                  'Order No. 0054752\n29 Nov, 01:20 pm',
                                  style: GoogleFonts.inter(
                                    fontSize: 12 * s,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 16 * s),
                                Row(
                                  children: [
                                    _Chip(s: s, label: 'Order Issues'),
                                    SizedBox(width: 8 * s),
                                    _Chip(s: s, label: 'Order not received'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Input Area
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        20 * s,
                        10 * s,
                        20 * s,
                        24 * s,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36 * s,
                            height: 36 * s,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.attach_file,
                              color: const Color(0xFFFF6B6B),
                              size: 18 * s,
                            ),
                          ),
                          SizedBox(width: 12 * s),
                          Expanded(
                            child: Container(
                              height: 40 * s,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9F0F4),
                                borderRadius: BorderRadius.circular(20 * s),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16 * s),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Write Here...',
                                style: GoogleFonts.inter(
                                  color: Colors.grey,
                                  fontSize: 13 * s,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12 * s),
                          Container(
                            width: 36 * s,
                            height: 36 * s,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.mic_none_outlined,
                              color: const Color(0xFFFF6B6B),
                              size: 18 * s,
                            ),
                          ),
                          SizedBox(width: 12 * s),
                          Container(
                            width: 36 * s,
                            height: 36 * s,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6B6B),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 18 * s,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserMessage extends StatelessWidget {
  final double s;
  final String text;
  final String time;

  const _UserMessage({required this.s, required this.text, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 12 * s),
            decoration: BoxDecoration(
              color: const Color(0xFF35414B),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16 * s),
                bottomLeft: Radius.circular(16 * s),
                topRight: Radius.circular(16 * s),
              ),
            ),
            child: Text(
              text,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13 * s),
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            time,
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 10 * s),
          ),
        ],
      ),
    );
  }
}

class _BotMessage extends StatelessWidget {
  final double s;
  final String? text;
  final Widget? child;
  final String time;

  const _BotMessage({
    required this.s,
    this.text,
    this.child,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 12 * s),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16 * s),
                bottomRight: Radius.circular(16 * s),
                topRight: Radius.circular(16 * s),
              ),
              border: Border.all(
                color: const Color(0xFFFF6B6B).withOpacity(0.5),
              ),
            ),
            child:
                child ??
                Text(
                  text!,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 13 * s,
                    height: 1.4,
                  ),
                ),
          ),
          SizedBox(height: 4 * s),
          Text(
            time,
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 10 * s),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final double s;
  final String label;

  const _Chip({required this.s, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10 * s,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFF6B6B),
        ),
      ),
    );
  }
}
