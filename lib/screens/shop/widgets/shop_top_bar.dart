import 'package:flutter/material.dart';
import '../../../core/app_constants.dart';

class ShopTopBar extends StatelessWidget {
  const ShopTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 16 * s),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30 * s),
        border: Border.all(
          color: const Color(0xFF26313A),
          width: 1,
        ),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1B2329).withOpacity(0.6),
            const Color(0xFF26313A).withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              color: Colors.transparent,
              child: Icon(
                Icons.chevron_left,
                color: const Color(0xFF00F0FF),
                size: 28 * s,
              ),
            ),
          ),
          Image.asset(
            'assets/24 logo.png',
            height: 24 * s,
            fit: BoxFit.contain,
          ),
          Container(
            width: 32 * s,
            height: 32 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00F0FF), width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/fonts/male.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
