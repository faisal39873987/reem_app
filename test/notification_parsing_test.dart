import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Notification parsing', () {
    test('parses notification map with nulls and types', () {
      final notif = {
        'id': 1,
        'title': null,
        'body': 123,
        'created_at': '2025-06-23T10:00:00Z',
        'is_read': 1,
      };
      String parseString(dynamic v) => v == null ? '' : v.toString();
      bool parseBool(dynamic v) => v == true || v == 1;
      DateTime parseTime(dynamic v) =>
          v is String ? DateTime.parse(v) : DateTime.now();
      expect(parseString(notif['id']), '1');
      expect(parseString(notif['title']), '');
      expect(parseString(notif['body']), '123');
      expect(parseBool(notif['is_read']), true);
      expect(parseTime(notif['created_at']).year, 2025);
    });
  });
}
