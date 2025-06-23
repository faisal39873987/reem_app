import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('BUILD: ResetPasswordScreen');
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'ميزة إعادة تعيين كلمة المرور عبر Supabase فقط متاحة حالياً. إذا كنت تريد دعم الهاتف، أضف المنطق المناسب.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
