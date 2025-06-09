import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/constants.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _smsController = TextEditingController();
  final _newPasswordController = TextEditingController();
  String? _verificationId;
  bool _codeSent = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Email is required')));
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reset email sent. Check your inbox.')));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    }
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Phone is required')));
      return;
    }
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
      },
      codeSent: (id, _) {
        setState(() {
          _verificationId = id;
          _codeSent = true;
        });
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<void> _verifyAndReset() async {
    final code = _smsController.text.trim();
    final newPass = _newPasswordController.text.trim();
    if (code.length < 6 || newPass.isEmpty || _verificationId == null) return;
    try {
      final cred = PhoneAuthProvider.credential(
          verificationId: _verificationId!, smsCode: code);
      final result = await FirebaseAuth.instance.signInWithCredential(cred);
      await result.user?.updatePassword(newPass);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reset Password'),
          bottom: const TabBar(tabs: [Tab(text: 'Email'), Tab(text: 'Phone')]),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _sendResetEmail,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        minimumSize: const Size(double.infinity, 50)),
                    child: const Text('Send Reset Link'),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                    const SizedBox(height: 20),
                    if (!_codeSent)
                      ElevatedButton(
                        onPressed: _sendCode,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            minimumSize: const Size(double.infinity, 50)),
                        child: const Text('Send Code'),
                      )
                    else ...[
                      TextField(
                        controller: _smsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Code'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration:
                            const InputDecoration(labelText: 'New Password'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _verifyAndReset,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            minimumSize: const Size(double.infinity, 50)),
                        child: const Text('Verify & Update'),
                      )
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
