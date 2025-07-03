class Post {
  final String id;
  final String imageUrl;
  final List<String> images;
  final String description;
  final double price;
  final String creatorId;
  final String category;
  final bool isAnonymous;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  // Facebook-style fields (mapped from data)
  final String? title;
  final String? userAvatarUrl;
  final String? userName;
  final String? location;
  final List<String>? tags;
  final String? caption;
  final List<Map<String, dynamic>>? comments;
  final int? likeCount;
  final int? commentCount;
  final int? shareCount;
  final bool? isLiked;

  Post({
    required this.id,
    required this.imageUrl,
    required this.images,
    required this.description,
    required this.price,
    required this.creatorId,
    required this.category,
    required this.isAnonymous,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.title,
    this.userAvatarUrl,
    this.userName,
    this.location,
    this.tags,
    this.caption,
    this.comments,
    this.likeCount,
    this.commentCount,
    this.shareCount,
    this.isLiked,
  });

  // Computed property for time ago
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.year}/${timestamp.month}/${timestamp.day}';
  }

  // For backward compatibility, add a fallback for title
  String get safeTitle => title ?? description.split(' ').take(6).join(' ');

  factory Post.fromMap(dynamic id, Map<String, dynamic> data) {
    List<String> parseImages(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      if (value is String && value.trim().isNotEmpty) {
        // Try to parse comma separated or JSON string
        if (value.trim().startsWith('[')) {
          try {
            final list = value
                .replaceAll("'", '"')
                .replaceAll('\\', '')
                .replaceAll('"[', '[')
                .replaceAll(']"', ']');
            final decoded = List<String>.from(
              (list.isNotEmpty
                  ? (list.startsWith('[')
                      ? (list.endsWith(']')
                          ? (list.length > 2
                              ? (list.substring(1, list.length - 1).split(','))
                              : [])
                          : [])
                      : [])
                  : []),
            );
            return decoded.map((e) => e.trim().replaceAll('"', '')).toList();
          } catch (_) {
            return [value];
          }
        }
        if (value.contains(',')) {
          return value.split(',').map((e) => e.trim()).toList();
        }
        return [value];
      }
      return [];
    }

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
      images: parseImages(
        data['images'] ??
            data['gallery'] ??
            data['image_urls'] ??
            data['photos'],
      ),
      description: parseString(
        data['content'] ?? data['description'] ?? data['title'] ?? '',
      ),
      price: data['price'] != null ? parseDouble(data['price']) : 0.0,
      creatorId: parseString(data['user_id'] ?? data['creatorId']),
      category: parseString(data['category'] ?? data['type'] ?? 'General'),
      isAnonymous: parseBool(data['isAnonymous'] ?? false),
      latitude: data['latitude'] != null ? parseDouble(data['latitude']) : 0.0,
      longitude:
          data['longitude'] != null ? parseDouble(data['longitude']) : 0.0,
      timestamp: parseTimestamp(data['created_at'] ?? data['timestamp']),
      title: parseString(data['title'] ?? data['content'] ?? ''),
      userAvatarUrl: parseString(data['user_avatar_url'] ?? data['avatar_url']),
      userName: parseString(
        data['user_name'] ?? data['username'] ?? 'Anonymous User',
      ),
      location: parseString(data['location'] ?? ''),
      tags: parseImages(data['tags']),
      caption: parseString(data['caption'] ?? data['content']),
      comments: data['comments'] as List<Map<String, dynamic>>?,
      likeCount:
          data['like_count'] != null
              ? int.tryParse(data['like_count'].toString()) ?? 0
              : 0,
      commentCount:
          data['comment_count'] != null
              ? int.tryParse(data['comment_count'].toString()) ?? 0
              : 0,
      shareCount:
          data['share_count'] != null
              ? int.tryParse(data['share_count'].toString()) ?? 0
              : 0,
      isLiked: parseBool(data['is_liked'] ?? false),
    );
  }
}
