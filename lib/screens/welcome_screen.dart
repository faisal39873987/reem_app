import 'package:flutter/material.dart';
import '../utils/constants.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          debugPrint('NAVIGATE: To /landing (from WelcomeScreen)');
          Navigator.pushReplacementNamed(context, '/landing');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('BUILD: WelcomeScreen');
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: const SafeArea(
        child: Center(
          child: Text(
            "Welcome",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
