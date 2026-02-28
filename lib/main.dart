import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api_config.dart';
import 'auth/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/root_screen.dart';
import 'screens/signup/otp_screen.dart';
import 'screens/signup/second_screen.dart';
import 'screens/signup/sign_up_setup2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!ApiConfig.skipFirebaseInit) {
    try {
      await Firebase.initializeApp();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Firebase.initializeApp failed: $e');
        debugPrint(st.toString());
      }
      // App still runs; phone auth will use backend OTP if useFirebasePhoneAuth is false
    }
  }

  runApp(const DigiApp());
}

/// Used by BraceletScreen to pause realtime polling when user leaves the bracelet section.
final RouteObserver<ModalRoute<void>> braceletRouteObserver =
    RouteObserver<ModalRoute<void>>();

class DigiApp extends StatelessWidget {
  const DigiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '24Kivi',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFF020A10),
          brightness: Brightness.dark,
        ),
        navigatorObservers: [braceletRouteObserver],
        home: const RootScreen(),
        routes: {
          '/second': (_) => const SecondScreen(),
          '/otp': (_) => const OtpScreen(),
          '/setup2': (_) => const SignUpSetup2(),
          '/home': (_) => const HomeScreen(),
        },
      ),
    );
  }
}
