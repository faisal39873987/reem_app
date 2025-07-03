import 'package:flutter_test/flutter_test.dart';
import 'package:reem_verse_rebuild/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://test.supabase.co',
      anonKey: 'test-anon-key',
    );
  });
  group('AuthService', () {
    test('signOut clears current user', () async {
      final service = AuthService();
      await service.signInAnonymously();
      expect(service.currentUser, isNotNull);
      await service.signOut(null);
      expect(service.currentUser, isNull);
    });
  });
}
