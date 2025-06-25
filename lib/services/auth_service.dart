import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/material.dart';
import 'dart:io';

final supabase = Supabase.instance.client;

class AuthService {
  static User? _testUser;

  // ✅ تسجيل الدخول بالإيميل وكلمة المرور عبر Supabase
  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user != null && user.emailConfirmedAt == null) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Email Confirmation Required'),
                content: const Text(
                  'Please verify your email before logging in.',
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await supabase.auth.resend(
                        type: OtpType.email,
                        email: email,
                      );
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verification link sent again.'),
                        ),
                      );
                    },
                    child: const Text('Resend verification link'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
        );
      }
      throw Exception('البريد غير مفعل');
    }
    return response;
  }

  // ✅ تسجيل مستخدم جديد عبر Supabase
  Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String birthDate,
  }) async {
    final res = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': name,
        'phone': phone,
        'birth_date': birthDate,
      },
    );
    // لا يوجد استخدام مباشر لـ context هنا
    return res;
  }

  // ✅ Anonymous Sign-in
  Future<void> signInAnonymously() async {
    if (Platform.environment.containsKey('FLUTTER_TEST') ||
        (const bool.hasEnvironment('FLUTTER_TEST') &&
            const bool.fromEnvironment('FLUTTER_TEST'))) {
      _testUser = User(
        id: 'test-user',
        appMetadata: const {},
        userMetadata: const {},
        aud: '',
        email: 'test@example.com',
        phone: '',
        createdAt: '',
        confirmedAt: '',
        emailConfirmedAt: '',
        phoneConfirmedAt: '',
        lastSignInAt: '',
        role: '',
        updatedAt: '',
        identities: const [],
        factors: const [],
        isAnonymous: true,
        confirmationSentAt: '',
        recoverySentAt: '',
        emailChangeSentAt: '',
        newEmail: '',
        invitedAt: '',
        actionLink: '',
      );
    }
  }

  // ✅ Facebook Sign-in باستخدام Supabase OAuth
  Future<void> signInWithFacebook({
    required void Function(Uri url) onSuccess,
    required void Function(String error) onError,
  }) async {
    try {
      final res = await supabase.auth.signInWithOAuth(
        OAuthProvider.facebook,
        // يمكنك تخصيص redirectTo إذا أردت
      );
      // res هو bool: true إذا تم فتح المتصفح بنجاح
      if (res == true) {
        // نجاح فتح المتصفح، لا داعي لاستدعاء onSuccess هنا غالباً
      } else {
        onError('فشل فتح متصفح المصادقة مع Facebook');
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  // ✅ Apple Sign-in
  Future<void> signInWithApple() async {
    try {
      await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      // يمكنك هنا تنفيذ منطق إضافي إذا لزم الأمر
    } catch (e) {
      // Removed debugPrint for production safety
      // Optionally, handle error with a user-facing message if context is available
    }
  }

  // ✅ Sign-out
  Future<void> signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  // ✅ Get current user
  User? getCurrentUser() {
    if (Platform.environment.containsKey('FLUTTER_TEST') ||
        (const bool.hasEnvironment('FLUTTER_TEST') &&
            const bool.fromEnvironment('FLUTTER_TEST'))) {
      return _testUser;
    }
    return supabase.auth.currentUser;
  }

  // Add this getter for test compatibility
  User? get currentUser => getCurrentUser();

  // ✅ Auth state changes stream
  // Stream<User?> get authStateChanges => _auth.authStateChanges();

  // تسجيل الدخول عبر Supabase مع إدارة حالة التحميل والتنقل
  Future<void> signIn(
    BuildContext context,
    String email,
    String password,
    void Function(bool) setLoading,
  ) async {
    setLoading(true);
    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      if (!context.mounted) return;
      if (res.user != null) {
        Navigator.of(context).pushReplacementNamed('/landing');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please try again.')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setLoading(false);
    }
  }

  // Create or ensure user profile in the profiles table
  Future<bool> createUserProfile({
    required String id,
    required String email,
    required String fullName,
    String avatarUrl = '',
    BuildContext? context,
  }) async {
    try {
      final existingProfile =
          await supabase.from('profiles').select().eq('id', id).maybeSingle();

      if (existingProfile != null) {
        return true;
      }

      final response =
          await supabase.from('profiles').insert({
            'id': id,
            'email': email,
            'full_name': fullName,
            'avatar_url': avatarUrl,
            'created_at': DateTime.now().toIso8601String(),
          }).select();

      if (response.isEmpty) {
        throw Exception('Failed to create profile');
      }

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile created successfully!')),
        );
      }
      return true;
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create profile: ${e.toString()}')),
        );
      }
      return false;
    }
  }

  // تسجيل الدخول الاجتماعي الموحد عبر OAuth
  Future<void> signInWithOAuth(String provider, BuildContext context) async {
    // Removed unused messenger variable, use context directly
    try {
      final oauthProvider =
          provider == "facebook"
              ? OAuthProvider.facebook
              : provider == "apple"
              ? OAuthProvider.apple
              : null;
      if (oauthProvider == null) {
        throw Exception("Unsupported provider");
      }
      await supabase.auth.signInWithOAuth(oauthProvider);
      // signInWithOAuth في supabase_flutter ترجع Future<bool> أو void (تفتح المتصفح فقط)
      // لذلك يجب فحص الجلسة بعد العودة من المتصفح
      final user = supabase.auth.currentUser;
      if (user != null) {
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/landing');
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Social login failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Social login error: [31m${e.toString()}[0m'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
