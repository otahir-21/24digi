import 'package:flutter/material.dart';
import '../../../../core/app_constants.dart';

import '../profile_screen.dart';

class ProfileTopBar extends StatelessWidget {
  const ProfileTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 16 * s),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30 * s),
        gradient: const LinearGradient(
          colors: [Color(0xFF00F0FF), Color(0xFFB161FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D1217),
          borderRadius: BorderRadius.circular(30 * s),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.all(4 * s),
                child: Icon(
                  Icons.chevron_left,
                  color: const Color(0xFF00F0FF),
                  size: 28 * s,
                ),
              ),
            ),
            Image.asset(
              'assets/images/digi_logo.png',
              height: 38 * s,
              fit: BoxFit.contain,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: Container(
                width: 32 * s,
                height: 32 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/fonts/male.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
