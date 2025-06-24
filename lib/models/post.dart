class Post {
  final String id;
  final String? imageUrl;
  final String? description;
  final double? price;
  final String? creatorId;
  final String? category;
  final bool? isAnonymous;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;

  Post({
    required this.id,
    this.imageUrl,
    this.description,
    this.price,
    this.creatorId,
    this.category,
    this.isAnonymous,
    this.latitude,
    this.longitude,
    required this.timestamp,
  });

  factory Post.fromMap(dynamic id, Map<String, dynamic> data) {
    double? parseDouble(dynamic value) =>
        value == null ? null : double.tryParse(value.toString());
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
      id: id.toString(),
      imageUrl: data['image_url'] ?? data['imageUrl'],
      description: data['description'] ?? data['content'] ?? data['title'],
      price: data['price'] != null ? parseDouble(data['price']) : null,
      creatorId: data['user_id']?.toString(),
      category: data['category'] ?? data['type'] ?? data['title'],
      isAnonymous: data['isAnonymous'] == true || data['isAnonymous'] == 1,
      latitude: data['latitude'] != null ? parseDouble(data['latitude']) : null,
      longitude:
          data['longitude'] != null ? parseDouble(data['longitude']) : null,
      timestamp: parseTimestamp(data['created_at']),
    );
  }
}
