import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Message parsing', () {
    test('parses message map with nulls and types', () {
      final msg = {
        'id': 123,
        'sender_id': 456,
        'receiver_id': null,
        'content': 789,
        'created_at': '2024-01-01T12:00:00Z',
        'is_read': null,
      };
      // Simulate robust parsing as in your app
      String parseString(dynamic v) => v == null ? '' : v.toString();
      bool parseBool(dynamic v) => v == true || v == 1;
      DateTime parseTime(dynamic v) =>
          v is String ? DateTime.parse(v) : DateTime.now();
      expect(parseString(msg['id']), '123');
      expect(parseString(msg['sender_id']), '456');
      expect(parseString(msg['receiver_id']), '');
      expect(parseString(msg['content']), '789');
      expect(parseBool(msg['is_read']), false);
      expect(parseTime(msg['created_at']).year, 2024);
    });
  });
}
