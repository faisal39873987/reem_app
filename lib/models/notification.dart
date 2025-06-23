class AppNotification {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromMap(Map<String, dynamic> data) {
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

    return AppNotification(
      id: parseString(data['id']),
      title: parseString(data['title']),
      body: parseString(data['body']),
      isRead: parseBool(data['is_read']),
      createdAt: parseTimestamp(data['created_at']),
    );
  }
}
