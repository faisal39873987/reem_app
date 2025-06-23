// lib/screens/auth/email_input_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/constants.dart';

class EmailInputScreen extends StatelessWidget {
  const EmailInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('BUILD: EmailInputScreen');
    final emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recover via Email"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Enter your registered email",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email Address",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  final email = emailController.text.trim();
                  final messenger = ScaffoldMessenger.of(context);
                  if (email.isEmpty) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text("Please enter your email")),
                    );
                    return;
                  }
                  try {
                    await Supabase.instance.client.auth.resetPasswordForEmail(
                      email,
                    );
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          "تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني",
                        ),
                      ),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text("Failed to send: $e")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Send Recovery Email"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
