import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kivi_24/screens/ai_model/ai_model_dashboard.dart';
import 'package:kivi_24/screens/bracelet/bracelet_search_screen.dart';
import 'package:kivi_24/screens/c_by_ai/welcome_c_by_ai_screen.dart';
import 'package:kivi_24/screens/home_screen.dart';
import 'package:kivi_24/screens/wallet/views/main_parent_screen.dart';
import '../providers/navigation_provider.dart';
import '../widgets/bottom_nav_bar.dart';

class MainNavigationScaffold extends StatefulWidget {
  const MainNavigationScaffold({super.key});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  void _onItemTapped(int index, NavigationProvider nav) {
    if (index == nav.selectedIndex) {
      nav.resetTab(index);
    } else {
      nav.setIndex(index);
    }
  }

  Widget _buildTab(int index, Widget rootPage, NavigationProvider nav) {
    return Offstage(
      offstage: nav.selectedIndex != index,
      child: Navigator(
        key: nav.navigatorKeys[index],
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) => rootPage,
            settings: settings,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final navigator = nav.navigatorKeys[nav.selectedIndex].currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
        } else {
          // If we are at the root of a tab that is NOT Home, switch to Home
          if (nav.selectedIndex != 2) {
            nav.setIndex(2);
          } else {
            // Already on Home root screen, minimize or exit.
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            _buildTab(0, const WelcomeCByAIScreen(), nav), // C BY AI
            _buildTab(1, const BraceletSearchScreen(), nav), // Bracelet
            _buildTab(2, const HomeScreen(), nav), // Home
            _buildTab(3, const MainParentScreen(), nav), // Wallet
            _buildTab(4, const AiModelDashboard(), nav), // AI Models
          ],
        ),
        bottomNavigationBar: (nav.isNavBarVisible && nav.selectedIndex != 1)
            ? BottomNavBar(
                selectedIndex: nav.selectedIndex,
                onTap: (index) => _onItemTapped(index, nav),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
