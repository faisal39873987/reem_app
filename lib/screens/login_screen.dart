import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import 'package:reem_verse_rebuild/screens/auth/signup_screen.dart';
import 'package:reem_verse_rebuild/screens/auth/email_input_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  void _login() async {
    // debugPrint('LOGIN: Attempting login');
    await _authService.signIn(
      context,
      _emailController.text.trim(),
      _passwordController.text.trim(),
      (loading) => setState(() => _isLoading = loading),
    );
  }

  void _navigateToSignUp() {
    // debugPrint('NAVIGATE: To /signup (from LoginScreen)');
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SignupScreen()));
  }

  void _navigateToForgotPassword() {
    // debugPrint('NAVIGATE: To /reset (from LoginScreen)');
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const EmailInputScreen()));
  }

  void _continueAsGuest() async {
    // debugPrint('LOGIN: Continue as guest');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGuest', true);
    if (!mounted) return;
    // debugPrint('NAVIGATE: To /landing (guest from LoginScreen)');
    Navigator.of(context).pushReplacementNamed('/landing');
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint('BUILD: LoginScreen');
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Center(
                  child: Image.asset('assets/images/logo.png', height: 90),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _navigateToSignUp,
                      child: const Text(
                        "Don't have an account? Sign up",
                        style: TextStyle(fontSize: 14, color: kPrimaryColor),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _navigateToForgotPassword,
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(fontSize: 14, color: kPrimaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'or continue with',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialIconButton(
                      icon: Image.asset(
                        'assets/images/facebook_icon.png',
                        height: 28,
                      ),
                      onTap: () {
                        _authService.signInWithOAuth("facebook", context);
                      },
                    ),
                    if (Theme.of(context).platform == TargetPlatform.iOS)
                      const SizedBox(width: 18),
                    if (Theme.of(context).platform == TargetPlatform.iOS)
                      _SocialIconButton(
                        icon: Icon(Icons.apple, color: Colors.black, size: 28),
                        onTap: () {
                          _authService.signInWithOAuth("apple", context);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _continueAsGuest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue as Guest',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;
  const _SocialIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black12),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.04 * 255).toInt()),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }
}
