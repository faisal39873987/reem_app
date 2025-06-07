import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Anonymous Sign-in
  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  // ✅ Facebook Sign-in
  Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(result.accessToken!.tokenString);

        return await _auth.signInWithCredential(facebookAuthCredential);
      } else {
        debugPrint('Facebook login failed: \${result.status}');
        return null;
      }
    } catch (e) {
      debugPrint('Facebook login error: \$e');
      return null;
    }
  }

  // ✅ Apple Sign-in
  Future<UserCredential?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      return await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      debugPrint('Apple sign-in error: \$e');
      return null;
    }
  }

  // ✅ Sign-out
  Future<void> signOut() async {
    await _auth.signOut();
    await FacebookAuth.instance.logOut();
  }

  // ✅ Get current user
  User? get currentUser => _auth.currentUser;

  // ✅ Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
