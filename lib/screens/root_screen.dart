import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import 'home_screen.dart';
import 'signup/otp_screen.dart';
import 'signup/second_screen.dart';
import 'signup/sign_up_setup2.dart';
import 'signup/welcome_screen.dart';

/// Decides initial route from auth state: welcome, login, OTP, onboarding, or home.
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, auth, _) {
      if (!auth.isInitialized) {
        return const Scaffold(
          backgroundColor: Color(0xFF020A10),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF00F0FF)),
          ),
        );
      }
      if (!auth.isLoggedIn) {
        return const WelcomeScreen();
      }
      if (auth.isProfileComplete) {
        return const HomeScreen();
      }
      return const SignUpSetup2();
    });
  }
}
