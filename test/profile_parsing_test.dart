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
        'show_in_reem_youth': 0,
      };
      String parseString(dynamic v) => v == null ? '' : v.toString();
      bool parseBool(dynamic v) => v == true || v == 1;
      expect(parseString(profile['id']), '1');
      expect(parseString(profile['full_name']), '');
      expect(parseString(profile['bio']), '123');
      expect(parseString(profile['phone']), '');
      expect(parseString(profile['avatar_url']), '456');
      expect(parseBool(profile['show_in_reem_youth']), false);
    });
  });
}
