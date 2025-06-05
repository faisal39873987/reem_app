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
  });

  factory Post.fromMap(String id, Map<String, dynamic> data) {
    return Post(
      id: id,
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      creatorId: data['creatorId'] ?? '',
      category: data['category'] ?? 'Services',
      isAnonymous: data['isAnonymous'] ?? false,
      latitude: data['location']?['latitude'] ?? 0.0,
      longitude: data['location']?['longitude'] ?? 0.0,
    );
  }
}
