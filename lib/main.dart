import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kivi_24/screens/profile/profile_screen.dart';
import 'package:kivi_24/screens/root_screen.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'auth/auth_provider.dart';
import 'core/api_config.dart';
import 'core/language_provider.dart';
import 'screens/diet/providers/cart_provider.dart';
import 'screens/home_screen.dart';
import 'screens/signup/otp_screen.dart';
import 'providers/challenge_provider.dart';
import 'screens/signup/second_screen.dart';
import 'screens/c_by_ai/providers/c_by_ai_provider.dart';
import 'providers/navigation_provider.dart';
import 'screens/signup/sign_up_setup2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Suppress "No active stream to cancel" on hot restart (harmless platform channel quirk).
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception is PlatformException &&
        (details.exception as PlatformException).message?.contains(
              'No active stream',
            ) ==
            true) {
      return;
    }
    previousOnError?.call(details);
  };

  if (!ApiConfig.skipFirebaseInit) {
    try {
      await Firebase.initializeApp();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Firebase.initializeApp failed: $e');
        debugPrint(st.toString());
      }
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
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ChallengeProvider()),
        ChangeNotifierProvider(create: (_) => CByAiProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: '24Digi',
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
          '/profile': (_) => const ProfileScreen(),
        },
      ),
    );
  }
}
