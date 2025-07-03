// Comment model for posts
class Comment {
  final String id;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.text,
    required this.timestamp,
  });

  // Getter for backward compatibility
  String get avatarUrl => userAvatarUrl;
  String get time => timestamp.toString();

  factory Comment.fromMap(Map<String, dynamic> data) {
    return Comment(
      id: data['id']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      userName: data['userName']?.toString() ?? '',
      userAvatarUrl: data['userAvatarUrl']?.toString() ?? '',
      text: data['text']?.toString() ?? '',
      timestamp:
          DateTime.tryParse(data['timestamp']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
