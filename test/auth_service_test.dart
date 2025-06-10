import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:reem_verse_rebuild/services/auth_service.dart';

void main() {
  group('AuthService', () {
    test('signInAnonymously returns a user', () async {
      final auth = MockFirebaseAuth();
      final service = AuthService(firebaseAuth: auth);
      final credential = await service.signInAnonymously();
      expect(credential.user, isNotNull);
      expect(auth.currentUser, isNotNull);
    });

    test('signOut clears current user', () async {
      final auth = MockFirebaseAuth();
      final service = AuthService(firebaseAuth: auth);
      await service.signInAnonymously();
      expect(auth.currentUser, isNotNull);
      await service.signOut();
      expect(auth.currentUser, isNull);
    });
  });
}
