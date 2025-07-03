import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/post.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  final Post? post;

  const CommentsScreen({super.key, required this.postId, this.post});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, dynamic>> _comments = [];
  bool _isLoadingComments = false;
  bool _isSendingComment = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);

    // TODO: Load comments from backend
    // Simulate loading with dummy data
    await Future.delayed(const Duration(milliseconds: 800));

    // Add some dummy comments for demonstration
    final dummyComments = [
      {
        'id': '1',
        'content': 'This looks amazing! 😍',
        'user_name': 'Ahmed Ali',
        'user_avatar': 'https://i.pravatar.cc/150?img=1',
        'created_at':
            DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'likes': 5,
        'isLiked': false,
      },
      {
        'id': '2',
        'content': 'Great price! Is it still available?',
        'user_name': 'Sara Ahmed',
        'user_avatar': 'https://i.pravatar.cc/150?img=2',
        'created_at':
            DateTime.now()
                .subtract(const Duration(minutes: 30))
                .toIso8601String(),
        'likes': 2,
        'isLiked': true,
      },
      {
        'id': '3',
        'content': 'Can you share more details about this?',
        'user_name': 'Mohammed Hassan',
        'user_avatar': 'https://i.pravatar.cc/150?img=3',
        'created_at':
            DateTime.now()
                .subtract(const Duration(minutes: 15))
                .toIso8601String(),
        'likes': 1,
        'isLiked': false,
      },
    ];

    setState(() {
      _comments.addAll(dummyComments);
      _isLoadingComments = false;
    });
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isSendingComment = true);

    final newComment = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'content': _commentController.text.trim(),
      'user_name': 'You',
      'user_avatar': kDefaultAvatar,
      'created_at': DateTime.now().toIso8601String(),
      'likes': 0,
      'isLiked': false,
    };

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _comments.insert(0, newComment); // Add new comment at the top
      _commentController.clear();
      _isSendingComment = false;
    });

    // TODO: Send comment to backend
  }

  void _toggleLike(int index) {
    setState(() {
      final comment = _comments[index];
      final isLiked = comment['isLiked'] ?? false;
      comment['isLiked'] = !isLiked;
      comment['likes'] = (comment['likes'] ?? 0) + (isLiked ? -1 : 1);
    });

    // TODO: Update like status on backend
  }

  String _formatTime(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Comments',
          style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: kPrimaryColor),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Post preview (if available)
          if (widget.post != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      widget.post!.userAvatarUrl ?? kDefaultAvatar,
                    ),
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post!.isAnonymous
                              ? 'Anonymous User'
                              : (widget.post!.userName ?? 'User'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.post!.description,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.post!.price > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${widget.post!.price.toStringAsFixed(2)} AED',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.post!.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.post!.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
            ),

          // Comments count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.comment, color: kPrimaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${_comments.length} Comments',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Comments list
          Expanded(
            child:
                _isLoadingComments
                    ? const Center(child: CircularProgressIndicator())
                    : _comments.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No comments yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Be the first to share your thoughts!',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadComments,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _comments.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return _CommentItem(
                            comment: comment,
                            onLike: () => _toggleLike(index),
                            formatTime: _formatTime,
                          );
                        },
                      ),
                    ),
          ),

          // Comment input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundImage: NetworkImage(kDefaultAvatar),
                  radius: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                _isSendingComment
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : IconButton(
                      icon: Icon(
                        Icons.send,
                        color:
                            _commentController.text.trim().isEmpty
                                ? Colors.grey
                                : kPrimaryColor,
                      ),
                      onPressed:
                          _commentController.text.trim().isEmpty
                              ? null
                              : _addComment,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final Map<String, dynamic> comment;
  final VoidCallback onLike;
  final String Function(String) formatTime;

  const _CommentItem({
    required this.comment,
    required this.onLike,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final isLiked = comment['isLiked'] ?? false;
    final likes = comment['likes'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              comment['user_avatar'] ?? kDefaultAvatar,
            ),
            radius: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment['user_name'] ?? 'User',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment['content'] ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      formatTime(comment['created_at'] ?? ''),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: onLike,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isLiked ? Colors.red : Colors.grey,
                          ),
                          if (likes > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '$likes',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        // TODO: Reply to comment
                      },
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
