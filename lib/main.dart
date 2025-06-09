import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/phone_input_screen.dart';
import 'screens/auth/sms_verification_screen.dart';
import 'utils/theme.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/post_creation_screen.dart';
import 'screens/post_details_screen.dart';
import 'screens/search_screen.dart';

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
            theme: appTheme,
            locale: provider.locale,
            home: const SplashScreen(),
            routes: {
              '/login': (_) => const LoginScreen(),
              '/signup': (_) => const SignupScreen(),
              '/phone': (_) => const PhoneInputScreen(),
              '/reset': (_) => const ResetPasswordScreen(),
              '/landing': (_) => const LandingScreen(),
              '/profile': (_) => const ProfileScreen(),
              '/chat': (_) => const ChatListScreen(),
              '/notifications': (_) => const NotificationScreen(),
              '/marketplace': (_) => const MarketplaceScreen(),
              '/menu': (_) => const MainMenuScreen(),
              '/post': (_) => const PostCreationScreen(),
              '/search': (_) => const SearchScreen(),
            },
          );
        },
      ),
    );
  }
}
