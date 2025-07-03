import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/menu/account_screen.dart';
import '../screens/marketplace_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/search_screen.dart';
import '../screens/menu/privacy_policy_screen.dart';
import '../screens/menu/contact_us_screen.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'dart:io';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _supabase = Supabase.instance.client;
  String userName = 'مستخدم';
  String userEmail = '';
  String? userAvatar;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        setState(() {
          userEmail = user.email ?? '';
        });

        // Get user profile from profiles table
        final profileData =
            await _supabase
                .from('profiles')
                .select()
                .eq('id', user.id)
                .maybeSingle();

        if (profileData != null && mounted) {
          setState(() {
            userName =
                profileData['full_name'] ??
                user.email?.split('@')[0] ??
                'مستخدم';
            userAvatar = profileData['avatar_url'];
          });
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: Column(
          children: [
            // Profile Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage:
                        userAvatar != null
                            ? NetworkImage(userAvatar!)
                            : const AssetImage('assets/images/default_user.png')
                                as ImageProvider,
                    backgroundColor: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            fontFamily: 'SF Pro',
                          ),
                        ),
                        const SizedBox(height: 6),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AccountScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 0,
                            ),
                            side: const BorderSide(color: Color(0xFF1877F2)),
                          ),
                          child: const Text(
                            'View Profile',
                            style: TextStyle(
                              color: Color(0xFF1877F2),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Navigation Section
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 0),
                children: [
                  const SizedBox(height: 8),
                  MenuItem(
                    icon: Icons.storefront,
                    label: 'Marketplace',
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MarketplaceScreen(),
                          ),
                        ),
                  ),
                  MenuItem(
                    icon: Icons.notifications_none,
                    label: 'Notifications',
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationScreen(),
                          ),
                        ),
                  ),
                  MenuItem(
                    icon: Icons.search,
                    label: 'Search',
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SearchScreen(),
                          ),
                        ),
                  ),
                  MenuItem(
                    icon: Icons.bookmark_border,
                    label: 'Saved',
                    onTap: () {},
                  ),
                  MenuItem(
                    icon: Icons.language,
                    label: 'Language',
                    onTap: () {},
                  ),
                  const Divider(height: 24),
                  MenuItem(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        ),
                  ),
                  MenuItem(
                    icon: Icons.support_agent,
                    label: 'Contact Us',
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ContactUsScreen(),
                          ),
                        ),
                  ),
                  const Divider(height: 24),
                  MenuItem(
                    icon: Icons.logout,
                    label: 'Logout',
                    onTap: () async {
                      try {
                        // Sign out from Supabase
                        await Supabase.instance.client.auth.signOut();

                        // Clear SharedPreferences
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isLoggedIn', false);

                        if (!context.mounted) return;

                        // Navigate to login screen
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/login', (route) => false);

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم تسجيل الخروج بنجاح'),
                          ),
                        );
                      } catch (e) {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('خطأ في تسجيل الخروج: $e')),
                        );
                      }
                    },
                  ),
                  MenuItem(
                    icon: Icons.delete_forever,
                    label: 'Delete Account',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _protectIfNotLoggedIn(BuildContext context) async {
    debugPrint('MENU: Checking login status');
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('isGuest') ?? false;
    final session = Supabase.instance.client.auth.currentSession;
    debugPrint('SUPABASE: Session = $session');
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (isGuest || session == null) {
      debugPrint('NAVIGATE: To /login (from MainMenuScreen)');
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Login is required to access this page')),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      navigator.pushReplacementNamed('/login');
    }
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  
  const MenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1877F2), size: 28),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'SF Pro',
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      horizontalTitleGap: 12,
      minLeadingWidth: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      hoverColor: Colors.grey[100],
      splashColor: Colors.grey[200],
    );
  }
}
