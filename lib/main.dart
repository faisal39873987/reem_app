import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/theme.dart'; // تأكد من وجود هذا الملف وتعريف appTheme

import 'screens/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/marketplace_add_screen.dart';
import 'screens/marketplace_details_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/post_creation_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/search_screen.dart';
import 'screens/post_details_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/onboarding_screen.dart';
import 'providers/locale_provider.dart';
import 'providers/feed_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // debugPrint('MAIN: started');
  // await dotenv.load(); // Disabled dotenv
  // debugPrint('MAIN: dotenv skipped');
  // final supabaseUrl = dotenv.env['SUPABASE_URL'];
  // final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  // debugPrint('MAIN: supabaseUrl = '
  //     '\u001b[32m$supabaseUrl\u001b[0m, supabaseAnonKey = [32m***\u001b[0m');
  await Supabase.initialize(
    url: 'https://achyjrdkriusgdbxvswl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFjaHlqcmRrcml1c2dkYnh2c3dsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkwMjE5MTIsImV4cCI6MjA2NDU5NzkxMn0.NLFeeZbuaUuTEIC6U6Dmvj04R066N8kMS2QWrLs1A58',
  );
  // debugPrint('MAIN: Supabase initialized');
  runApp(const MyApp());
  // debugPrint('MAIN: runApp called');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'Reem Verse',
            debugShowCheckedModeBanner: false,
            theme: appTheme, // ⚠️ تأكد أنه معرف في utils/theme.dart
            locale: provider.locale,
            home: AuthRedirect(),
            onGenerateRoute: (settings) {
              if (settings.name == '/post-details') {
                final args = settings.arguments as Map<String, dynamic>?;
                final postId = args?['postId'] as String?;
                if (postId != null) {
                  return MaterialPageRoute(
                    builder: (_) => PostDetailsScreen(postId: postId),
                  );
                }
              }

              if (settings.name == '/marketplace-details') {
                final args = settings.arguments as Map<String, dynamic>?;
                final productId = args?['productId'] as String?;
                if (productId != null) {
                  return MaterialPageRoute(
                    builder:
                        (_) => MarketplaceDetailsScreen(productId: productId),
                  );
                }
              }

              return null;
            },
            routes: {
              '/login': (_) => const LoginScreen(),
              '/signup': (_) => const SignupScreen(),
              '/reset': (_) => const ResetPasswordScreen(),
              '/landing': (_) => const LandingScreen(),
              '/profile': (_) => const ProfileScreen(),
              '/notifications': (_) => const NotificationScreen(),
              '/marketplace': (_) => const MarketplaceScreen(),
              '/marketplace_add': (_) => const MarketplaceAddScreen(),
              '/menu': (_) => const MenuScreen(),
              '/post': (_) => const PostCreationScreen(),
              '/messages': (_) => const MessagesScreen(),
              '/search': (_) => const SearchScreen(),
              // '/post_details': (_) => const PostDetailsScreen(), // ❌ Removed, must use MaterialPageRoute with postId
            },
          );
        },
      ),
    );
  }
}

class AuthRedirect extends StatefulWidget {
  const AuthRedirect({super.key});

  @override
  State<AuthRedirect> createState() => _AuthRedirectState();
}

class _AuthRedirectState extends State<AuthRedirect> {
  bool _loading = true;
  bool _showOnboarding = false;
  bool _showWelcome = false;
  bool? _goToLanding;

  @override
  void initState() {
    super.initState();
    // debugPrint('AUTHREDIRECT: initState');
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // debugPrint('AUTHREDIRECT: Checking onboarding flag');
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime');
    // debugPrint('AUTHREDIRECT: isFirstTime = $isFirstTime');
    if (isFirstTime == null || isFirstTime == true) {
      // debugPrint('AUTHREDIRECT: Show onboarding');
      setState(() {
        _showOnboarding = true;
        _loading = false;
      });
      return;
    }
    final wasGuest = prefs.getBool('wasGuest') ?? false;
    // debugPrint('AUTHREDIRECT: wasGuest = $wasGuest');
    final showWelcome = prefs.getBool('showWelcome') ?? true;
    // debugPrint('AUTHREDIRECT: showWelcome = $showWelcome');
    if (wasGuest) {
      // debugPrint('AUTHREDIRECT: Go to landing (wasGuest)');
      setState(() {
        _goToLanding = true;
        _loading = false;
      });
      return;
    }
    // debugPrint('SUPABASE: Fetching session...');
    final session = Supabase.instance.client.auth.currentSession;
    // debugPrint('SUPABASE: Session = $session');
    if (session != null) {
      if (showWelcome) {
        // debugPrint('AUTHREDIRECT: Show welcome');
        await prefs.setBool('showWelcome', false);
        setState(() {
          _showWelcome = true;
          _loading = false;
        });
      } else {
        // debugPrint('AUTHREDIRECT: Go to landing (session)');
        setState(() {
          _goToLanding = true;
          _loading = false;
        });
      }
    } else {
      // debugPrint('AUTHREDIRECT: Go to login (no session)');
      setState(() {
        _goToLanding = false;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint('BUILD: AuthRedirect');
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_showOnboarding) {
      return const OnboardingScreen();
    }
    if (_showWelcome) {
      return const WelcomeScreen();
    }
    if (_goToLanding == true) {
      return const LandingScreen();
    } else {
      return const LoginScreen();
    }
  }
}
