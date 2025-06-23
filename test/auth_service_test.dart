import 'package:flutter_test/flutter_test.dart';
import 'package:reem_verse_rebuild/services/auth_service.dart';

void main() {
  group('AuthService', () {
    test('signOut clears current user', () async {
      final service = AuthService();
      await service.signInAnonymously();
      expect(service.currentUser, isNotNull);
      await service.signOut();
      expect(service.currentUser, isNull);
    });
  });
}
