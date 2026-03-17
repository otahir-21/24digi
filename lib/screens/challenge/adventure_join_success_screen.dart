import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_constants.dart';
import 'adventure_room_screen.dart';

class AdventureJoinSuccessScreen extends StatelessWidget {
  final String roomId;
  final String roomName;

  const AdventureJoinSuccessScreen({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  static const Color _background = Color(0xFF1E1813);
  static const Color _gold = Color(0xFFE0A10A);

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24 * s),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 120 * s,
                height: 120 * s,
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.emoji_events_outlined, color: _gold, size: 64 * s),
              ),
              SizedBox(height: 32 * s),
              Text(
                'SUCCESSFULLY JOINED!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 24 * s,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 16 * s),
              Text(
                'You are now a member of $roomName. Get ready for the adventure!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14 * s,
                  color: Colors.white60,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54 * s,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdventureRoomScreen(
                          roomId: roomId,
                          roomName: roomName,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16 * s),
                    ),
                  ),
                  child: Text(
                    'GO TO ROOM',
                    style: GoogleFonts.inter(
                      fontSize: 16 * s,
                      fontWeight: FontWeight.w800,
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
}
