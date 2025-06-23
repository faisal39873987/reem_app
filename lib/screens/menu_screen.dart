import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'notification_screen.dart';
import 'chat_list_screen.dart';
import 'search_screen.dart';
import 'menu/account_screen.dart';
import 'menu/privacy_policy_screen.dart';
import 'menu/contact_us_screen.dart';
import 'messages_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('BUILD: MainMenuScreen');
    _protectIfNotLoggedIn(context);
    const blueColor = kPrimaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                const Text(
                  "Menu",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: blueColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: blueColor),
                  onPressed: () {
                    debugPrint('NAVIGATE: To NotificationScreen');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: blueColor),
                  onPressed: () {
                    debugPrint('NAVIGATE: To ChatListScreen');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatListScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: blueColor),
                  onPressed: () {
                    debugPrint('NAVIGATE: To SearchScreen');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.person_outline, color: blueColor),
                    title: const Text(
                      "My Account",
                      style: TextStyle(color: blueColor),
                    ),
                    onTap: () {
                      debugPrint('NAVIGATE: To AccountScreen');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccountScreen(),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.privacy_tip_outlined,
                      color: blueColor,
                    ),
                    title: const Text(
                      "Privacy Policy",
                      style: TextStyle(color: blueColor),
                    ),
                    onTap: () {
                      debugPrint('NAVIGATE: To PrivacyPolicyScreen');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.contact_mail_outlined,
                      color: blueColor,
                    ),
                    title: const Text(
                      "Contact Us",
                      style: TextStyle(color: blueColor),
                    ),
                    onTap: () {
                      debugPrint('NAVIGATE: To ContactUsScreen');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ContactUsScreen(),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.message, color: blueColor),
                    title: const Text(
                      "Messages",
                      style: TextStyle(color: blueColor),
                    ),
                    onTap: () {
                      debugPrint('NAVIGATE: To MessagesScreen');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MessagesScreen(),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isLoggedIn', false);
                      if (!context.mounted) return;
                      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
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
