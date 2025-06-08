import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/search_screen.dart';
import 'screens/social_login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/welcome_screen.dart';
import 'providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: Consumer<LocaleProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'Reem Verse',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(primarySwatch: Colors.blue),
            locale: provider.locale,
            initialRoute: '/splash',
            routes: {
              '/splash': (_) => const SplashScreen(),
              '/login': (_) => const LoginScreen(),
              '/landing': (_) => const LandingScreen(),
              '/profile': (_) => const ProfileScreen(),
              '/menu': (_) => const MainMenuScreen(),
              '/search': (_) => const SearchScreen(),
              '/social': (_) => const SocialLoginScreen(),
              '/onboarding': (_) => const OnboardingScreen(),
              '/welcome': (_) => const WelcomeScreen(),
            },
          );
        },
      ),
    );
  }
}
