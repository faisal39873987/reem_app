// lib/screens/auth/sms_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/constants.dart';

class SmsVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const SmsVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<SmsVerificationScreen> createState() => _SmsVerificationScreenState();
}

class _SmsVerificationScreenState extends State<SmsVerificationScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyCode() async {
    final smsCode = _codeController.text.trim();

    if (smsCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the 6-digit code")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Capture context for navigation and snackbars
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.sms,
        token: smsCode,
        phone: widget.phoneNumber,
      );
      if (response.user != null && response.session != null) {
        navigator.pushReplacementNamed('/landing');
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text("Invalid code or verification failed.")),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text("Verification failed: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Code"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "A verification code was sent to:",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                widget.phoneNumber,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Enter Code",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Verify"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// All Firebase usage has been removed. Supabase is now used for all backend operations.
