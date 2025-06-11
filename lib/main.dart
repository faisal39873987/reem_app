import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'utils/theme.dart'; // تأكد من وجود هذا الملف وتعريف appTheme
import 'dart:ui';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/post_creation_screen.dart';
import 'screens/post_details_screen.dart';
import 'screens/search_screen.dart';
import 'providers/locale_provider.dart';

/// 🧠 Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseCrashlytics.instance.log('Background message: ${message.messageId ?? "no-id"}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Firebase Initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Firebase Crashlytics Setup
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  // ✅ Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.requestPermission();

  // ✅ Local Notifications Init
  await NotificationService.initialize();

  // ✅ Firebase Analytics (فعليًا يمكن استخدامه لاحقًا)
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  analytics.logEvent(name: 'app_start');

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
            theme: appTheme, // ⚠️ تأكد أنه معرف في utils/theme.dart
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
              '/post_details': (_) => const PostDetailsScreen(),
            },
          );
        },
      ),
    );
  }
}
