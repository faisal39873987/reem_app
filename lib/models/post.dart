class Post {
  final String id;
  final String imageUrl;
  final String description;
  final double price;
  final String creatorId;
  final String category;
  final bool isAnonymous;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  Post({
    required this.id,
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.creatorId,
    required this.category,
    required this.isAnonymous,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory Post.fromMap(dynamic id, Map<String, dynamic> data) {
    String parseString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is int || value is double) return value.toString();
      return value.toString();
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
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
      return DateTime.now();
    }

    return Post(
      id: parseString(id),
      imageUrl: parseString(data['image_url'] ?? data['imageUrl']),
      description: parseString(
        data['description'] ?? data['content'] ?? data['title'],
      ),
      price: data['price'] != null ? parseDouble(data['price']) : 0.0,
      creatorId: parseString(data['user_id'] ?? data['creatorId']),
      category:
          parseString(
                data['category'] ?? data['type'] ?? data['title'],
              ).isNotEmpty
              ? parseString(data['category'] ?? data['type'] ?? data['title'])
              : 'Services',
      isAnonymous: parseBool(data['isAnonymous']),
      latitude: data['latitude'] != null ? parseDouble(data['latitude']) : 0.0,
      longitude:
          data['longitude'] != null ? parseDouble(data['longitude']) : 0.0,
      timestamp: parseTimestamp(data['timestamp'] ?? data['created_at']),
    );
  }
}
