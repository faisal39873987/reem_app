// lib/screens/auth/phone_input_screen.dart
import 'package:flutter/material.dart';
import 'sms_verification_screen.dart';
import '../../utils/constants.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendCode() async {
    final phoneNumber = _phoneController.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (phoneNumber.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Please enter your phone number")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // All Firebase usage has been removed. Supabase is now used for all backend operations.

    setState(() => _isLoading = false);
    navigator.push(
      MaterialPageRoute(
        builder:
            (_) => SmsVerificationScreen(
              phoneNumber: phoneNumber,
              verificationId: '', // أضف معرف التحقق هنا لاحقًا
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phone Verification"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Enter your phone number",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  hintText: "+971 50 123 4567",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _sendCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Send Code"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
