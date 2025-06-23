import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final supabase = Supabase.instance.client;

class AuthService {
  // ✅ تسجيل الدخول بالإيميل وكلمة المرور عبر Supabase
  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
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
                      messenger.showSnackBar(
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
    String? name,
    String? phone,
    String? birthDate,
    BuildContext? context,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user != null) {
      await createUserProfile(
        id: user.id,
        email: user.email ?? email,
        fullName: name ?? '',
        avatarUrl: '',
        context: context,
      );
    }
    return response;
  }

  // ✅ Anonymous Sign-in
  Future<void> signInAnonymously() async {
    // Implement anonymous sign-in functionality here
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
      debugPrint('Apple sign-in error: $e');
    }
  }

  // ✅ Sign-out
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // ✅ Get current user
  User? getCurrentUser() => supabase.auth.currentUser;

  // Add this getter for test compatibility
  User? get currentUser => supabase.auth.currentUser;

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
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      // فحص اتصال الإنترنت أولاً
      final result = await InternetAddress.lookup('example.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw SocketException('No Internet');
      }
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session != null && response.user != null) {
        if (context.mounted) {
          // عند تسجيل الدخول بنجاح، امسح isGuest
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('isGuest');
          navigator.pushReplacementNamed('/landing');
        }
      } else {
        if (context.mounted) {
          showDialog(
            context: context,
            builder:
                (ctx) => AlertDialog(
                  title: const Text('Login Failed'),
                  content: const Text('Email or password is incorrect.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        }
      }
    } on SocketException catch (e) {
      debugPrint('No Internet: $e');
      if (context.mounted) {
        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('No Internet'),
                content: const Text('Please check your internet connection.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } on http.ClientException catch (e) {
      debugPrint('HTTP ClientException: $e');
      if (context.mounted) {
        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('No Internet'),
                content: const Text('Please check your internet connection.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      debugPrint('Login error: $e');
      if (context.mounted) {
        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Error'),
                content: Text(e.toString()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
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
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
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
      final response = await supabase.auth.signInWithOAuth(oauthProvider);
      debugPrint('$response');
      // signInWithOAuth في supabase_flutter ترجع Future<bool> أو void (تفتح المتصفح فقط)
      // لذلك يجب فحص الجلسة بعد العودة من المتصفح
      final user = supabase.auth.currentUser;
      if (user != null) {
        if (context.mounted) {
          navigator.pushReplacementNamed('/landing');
        }
      } else {
        if (context.mounted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Social login failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Social login error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
