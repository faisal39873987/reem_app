import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class SocialLoginScreen extends StatefulWidget {
  const SocialLoginScreen({super.key});

  @override
  State<SocialLoginScreen> createState() => _SocialLoginScreenState();
}

class _SocialLoginScreenState extends State<SocialLoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _signInWithFacebook() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (!mounted) return;
      
      switch (result.status) {
        case LoginStatus.success:
          if (result.accessToken == null) {
            throw Exception('Facebook access token is null');
          }
          
          final OAuthCredential facebookAuthCredential =
              FacebookAuthProvider.credential(result.accessToken!.token);
              
          final userCredential = await _auth.signInWithCredential(facebookAuthCredential);
          if (!mounted) return;
          
          if (userCredential.user == null) {
            throw Exception('Failed to get user data from Facebook');
          }
          
          await NotificationService.initialize();
          await _setLoginFlags();
          _navigateToLanding();
          break;
          
        case LoginStatus.cancelled:
          _showError("Sign-in was cancelled");
          break;
          
        case LoginStatus.failed:
          _showError("Facebook Sign-In failed: ${result.message}");
          break;
          
        default:
          _showError("Unexpected login status: ${result.status}");
      }
    } catch (e) {
      if (!mounted) return;
      _showError("Facebook Sign-In error: ${e.toString()}");
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }


  Future<void> _signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      await _auth.signInWithCredential(oauthCredential);
      await NotificationService.initialize();
      await _setLoginFlags();
      _navigateToLanding();
    } catch (e) {
      _showError("Apple Sign-In error: $e");
    }
  }

  Future<void> _setLoginFlags() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setBool('isFirstTime', false);
  }

  void _navigateToLanding() {
    Navigator.of(context).pushReplacementNamed('/landing');
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Social Login"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo.png', height: 120),
                const SizedBox(height: 40),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _signInWithFacebook,
                            icon: Image.asset('assets/images/facebook_icon.png', height: 24),
                            label: const Text("Continue with Facebook"),
                            style: _buttonStyle(),
                          ),
                          const SizedBox(height: 12),
                          if (Platform.isIOS)
                            ElevatedButton.icon(
                              onPressed: _signInWithApple,
                              icon: const Icon(Icons.apple, size: 24),
                              label: const Text("Sign in with Apple"),
                              style: _buttonStyle(),
                            ),
                        ],
                      ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 2,
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.black26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Back to Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 2,
      minimumSize: const Size(double.infinity, 50),
      side: const BorderSide(color: Colors.black26),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
