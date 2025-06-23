import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('BUILD: AccountScreen');
    _protectIfNotLoggedIn(context);
    const blueColor = kPrimaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('My Account', style: TextStyle(color: blueColor)),
        iconTheme: const IconThemeData(color: blueColor),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: blueColor,
              child: Icon(Icons.person, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              "Full Name",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: "Enter your full name",
              ),
            ),
            const SizedBox(height: 16),
            const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              readOnly: true,
              decoration: const InputDecoration(hintText: "Enter your email"),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: blueColor),
                onPressed: () async {
                  // All Firebase usage has been removed. Supabase is now used for all backend operations.
                },
                child: const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _protectIfNotLoggedIn(BuildContext context) async {
    debugPrint('ACCOUNT: Checking login status');
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('isGuest') ?? false;
    final session = Supabase.instance.client.auth.currentSession;
    debugPrint('SUPABASE: Session = $session');
    if (isGuest || session == null) {
      debugPrint('NAVIGATE: To /login (from AccountScreen)');
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Login Required'),
              content: const Text('You must log in to access this page.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      ).then((_) {
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      });
    }
  }
}
