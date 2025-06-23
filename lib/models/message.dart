class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory Message.fromMap(Map<String, dynamic> data) {
    String parseString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is int || value is double) return value.toString();
      return value.toString();
    }

    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value == 'true' || value == '1';
      return false;
    }

    DateTime parseTimestamp(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is int) {
        // Could be ms or s
        if (value > 1000000000000) {
          return DateTime.fromMillisecondsSinceEpoch(value);
        } else {
          return DateTime.fromMillisecondsSinceEpoch(value * 1000);
        }
      }
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      if (value is Map<String, dynamic>) {
        if (value.containsKey('_seconds')) {
          return DateTime.fromMillisecondsSinceEpoch(
            (value['_seconds'] * 1000).toInt(),
          );
        }
        if (value.containsKey('millisecondsSinceEpoch')) {
          return DateTime.fromMillisecondsSinceEpoch(
            value['millisecondsSinceEpoch'],
          );
        }
      }
      return DateTime.now();
    }

    return Message(
      id: parseString(data['id']),
      senderId: parseString(data['sender_id']),
      receiverId: parseString(data['receiver_id']),
      content: parseString(data['content']),
      isRead: parseBool(data['is_read']),
      createdAt: parseTimestamp(data['created_at']),
    );
  }
}
