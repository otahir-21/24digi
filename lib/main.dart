import 'package:flutter/material.dart';
import 'screens/signup/welcome_screen.dart';
import 'screens/signup/second_screen.dart';
import 'screens/signup/otp_screen.dart';
import 'screens/signup/sign_up_setup2.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const DigiApp());
}

class DigiApp extends StatelessWidget {
  const DigiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '24Kivi',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF020A10),
        brightness: Brightness.dark,
      ),
      home: const WelcomeScreen(),
      routes: {
        '/second': (_) => const SecondScreen(),
        '/otp': (_) => const OtpScreen(),
        '/setup2': (_) => const SignUpSetup2(),
        '/home': (_) => HomeScreen(),
      },
    );
  }
}