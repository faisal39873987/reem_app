import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _signupError;
  final bool _signupSuccess = false;

  Future<void> _signup() async {
    debugPrint('SIGNUP: Attempting signup');
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final birthDate = _birthDateController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        name.isEmpty ||
        birthDate.isEmpty ||
        phone.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      setState(() => _isLoading = false);
      return;
    }
    try {
      final res = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
        name: name,
        phone: phone,
        birthDate: birthDate,
      );
      debugPrint('SIGNUP: Signup result = $res');
      if (res.session == null || res.user == null) {
        setState(
          () =>
              _signupError = 'Account creation failed. Please check your data.',
        );
        return;
      }
      debugPrint('NAVIGATE: To /landing (from SignupScreen)');
      navigator.pushReplacementNamed('/landing');
    } catch (e) {
      debugPrint('SIGNUP: Error = $e');
      setState(() => _signupError = e.toString());
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('BUILD: SignupScreen');
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _birthDateController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: "Birth Date (YYYY-MM-DD)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (_signupError != null) ...[
                Text(_signupError!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
              ],
              if (_signupSuccess) ...[
                const Text(
                  'Signup successful! Please check your email for verification.',
                  style: TextStyle(color: Colors.green),
                ),
                const SizedBox(height: 12),
              ],
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
