import 'package:flutter/material.dart';
import '../core/app_constants.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 90 * s + bottomInset,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419), // Dark background for the bar
        border: Border(
          top: BorderSide(
            color: const Color(0xFF00F0FF).withOpacity(0.15),
            width: 1.0 * s,
          ),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── The Tabs ─────────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Row(
              children: [
                _buildNavItem(0, 'C BY AI', s),
                _buildNavItem(1, '24 Bracelet', s),
                const Spacer(flex: 1), // Space for centre logo
                _buildNavItem(3, 'Wallet', s),
                _buildNavItem(4, 'AI Models', s),
              ],
            ),
          ),

          // ── Centre Logo (Home) ────────────────────────────────────────────────
          Positioned(
            top: -25 * s,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => onTap(2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76 * s,
                    height: 76 * s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0D1519),
                      border: Border.all(
                        color: selectedIndex == 2
                            ? const Color(0xFF00D4AA)
                            : const Color(0xFF00F0FF).withOpacity(0.3),
                        width: 2 * s,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (selectedIndex == 2
                                  ? const Color(0xFF00D4AA)
                                  : const Color(0xFF00F0FF))
                              .withOpacity(0.3),
                          blurRadius: 15 * s,
                          spreadRadius: 2 * s,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(10 * s),
                    child: Image.asset(
                      'assets/24 logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 4 * s),
                  Text(
                    'Home',
                    style: TextStyle(
                      fontFamily: 'HelveticaNeue',
                      fontSize: 11 * s,
                      fontWeight:
                          selectedIndex == 2 ? FontWeight.w600 : FontWeight.w400,
                      color: selectedIndex == 2
                          ? const Color(0xFF00D4AA)
                          : const Color(0xFF6B7680),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, double s) {
    bool isSelected = selectedIndex == index;
    String iconPath = _getIconPath(index, isSelected);

    return Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (index == 0)
              _buildCByAIIcon(isSelected, s)
            else
              Image.asset(
                iconPath,
                height: 24 * s,
                fit: BoxFit.contain,
                color: isSelected ? const Color(0xFF00D4AA) : null,
              ),
            SizedBox(height: 6 * s),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'HelveticaNeue',
                fontSize: 11 * s,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? const Color(0xFF00D4AA) : const Color(0xFF6B7680),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Specialist builder for C BY AI icon as it needs extra text
  Widget _buildCByAIIcon(bool isSelected, double s) {
    return SizedBox(
      height: 24 * s,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            isSelected
                ? 'assets/bottom_nav_icon/selected_c.png'
                : 'assets/bottom_nav_icon/unselected_c.png',
            height: 24 * s,
            fit: BoxFit.contain,
            color: isSelected ? const Color(0xFF00D4AA) : null,
          ),
          Positioned(
            right: -10 * s,
            top: 6 * s,
            child: Text(
              'by AI',
              style: TextStyle(
                fontFamily: 'HelveticaNeue',
                fontSize: 6 * s,
                fontWeight: FontWeight.w400,
                color: isSelected ? const Color(0xFF00D4AA) : Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getIconPath(int index, bool isSelected) {
    String state = isSelected ? 'selected' : 'unselected';
    switch (index) {
      case 0:
        return 'assets/bottom_nav_icon/${state}_c.png';
      case 1:
        return 'assets/bottom_nav_icon/${state}_bracelet.png';
      case 3:
        return 'assets/bottom_nav_icon/${state}_wallet.png';
      case 4:
        return 'assets/bottom_nav_icon/${state}_ai.png';
      default:
        return '';
    }
  }
}
