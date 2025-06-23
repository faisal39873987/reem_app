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

  factory Post.fromMap(String id, Map<String, dynamic> data) {
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

    double parseLatLng(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    DateTime parseTimestamp(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is int) {
        // Could be milliseconds or seconds
        if (value > 1000000000000) {
          // Milliseconds
          return DateTime.fromMillisecondsSinceEpoch(value);
        } else {
          // Seconds
          return DateTime.fromMillisecondsSinceEpoch(value * 1000);
        }
      }
      if (value is String) {
        // Try ISO8601
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

    return Post(
      id: parseString(id),
      imageUrl: parseString(data['imageUrl'] ?? data['image_url']),
      description: parseString(data['description'] ?? data['content']),
      price: parseDouble(data['price']),
      creatorId: parseString(data['creatorId'] ?? data['user_id']),
      category: parseString(data['category'] ?? data['type'] ?? data['title'] ?? 'Services'),
      isAnonymous: data['isAnonymous'] == true || data['isAnonymous'] == 1,
      latitude: parseLatLng(data['location']?['latitude'] ?? data['latitude']),
      longitude: parseLatLng(data['location']?['longitude'] ?? data['longitude']),
      timestamp: parseTimestamp(data['timestamp'] ?? data['created_at']),
    );
  }
}
