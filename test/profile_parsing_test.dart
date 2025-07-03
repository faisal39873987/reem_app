import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Profile parsing', () {
    test('parses profile map with nulls and types', () {
      final profile = {
        'id': 1,
        'full_name': null,
        'bio': 123,
        'phone': null,
        'avatar_url': 456,
      };
      String parseString(dynamic v) => v == null ? '' : v.toString();
      expect(parseString(profile['id']), '1');
      expect(parseString(profile['full_name']), '');
      expect(parseString(profile['bio']), '123');
      expect(parseString(profile['phone']), '');
      expect(parseString(profile['avatar_url']), '456');
    });
  });
}
