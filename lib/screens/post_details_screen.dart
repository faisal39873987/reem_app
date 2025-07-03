import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/likes_service.dart';
import '../widgets/consistent_loading.dart';

class PostDetailsScreen extends StatefulWidget {
  final String postId;
  final bool openComments;

  const PostDetailsScreen({
    super.key,
    required this.postId,
    this.openComments = false,
  });

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final _supabase = Supabase.instance.client;
  final _commentController = TextEditingController();

  Post? _post;
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isLiked = false;
  int _likeCount = 0;
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _loadPostDetails();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadPostDetails() async {
    try {
      // Load post with user profile data
      final postResponse =
          await _supabase
              .from('posts')
              .select('''
            *,
            profiles!posts_user_id_fkey (
              full_name,
              avatar_url
            )
          ''')
              .eq('id', widget.postId)
              .single();

      // Add profile data to post data
      final postData = Map<String, dynamic>.from(postResponse);
      final profile = postData['profiles'];
      if (profile != null) {
        postData['user_name'] = profile['full_name'];
        postData['user_avatar_url'] = profile['avatar_url'];
      }

      // Get like status and count
      final likesRes = await _supabase
          .from('post_likes')
          .select()
          .eq('post_id', widget.postId);
      postData['like_count'] = likesRes.length;

      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null) {
        final userLikeRes =
            await _supabase
                .from('post_likes')
                .select()
                .eq('post_id', widget.postId)
                .eq('user_id', currentUser.id)
                .maybeSingle();
        postData['is_liked'] = userLikeRes != null;
      }

      // Load comments
      final commentsResponse = await _supabase
          .from('comments')
          .select('''
            *,
            profiles!comments_user_id_fkey (
              full_name,
              avatar_url
            )
          ''')
          .eq('post_id', widget.postId)
          .order('created_at', ascending: true);

      setState(() {
        _post = Post.fromMap(postData['id'].toString(), postData);
        _isLiked = _post?.isLiked ?? false;
        _likeCount = _post?.likeCount ?? 0;
        _comments =
            (commentsResponse as List).map((c) {
              final commentData = Map<String, dynamic>.from(c);
              final profile = commentData['profiles'];
              if (profile != null) {
                commentData['user_name'] = profile['full_name'];
                commentData['user_avatar_url'] = profile['avatar_url'];
              }
              return Comment.fromMap(commentData);
            }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading post details: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleLike() async {
    if (_post == null) return;

    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    try {
      final newLikedState = await LikesService.togglePostLike(_post!.id);
      if (newLikedState != _isLiked) {
        setState(() {
          _isLiked = newLikedState;
          _likeCount += newLikedState ? 1 : -1;
        });
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _isLiked = !_isLiked;
        _likeCount += _isLiked ? 1 : -1;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to update like')));
      }
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty || _post == null) return;

    setState(() => _isSubmittingComment = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final commentData = {
        'post_id': int.parse(_post!.id),
        'user_id': user.id,
        'content': _commentController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('comments').insert(commentData);

      _commentController.clear();
      await _loadPostDetails(); // Reload to get the new comment

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added successfully')),
        );
      }
    } catch (e) {
      print('Error submitting comment: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to add comment')));
      }
    } finally {
      setState(() => _isSubmittingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Post Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body:
          _isLoading
              ? const ConsistentLoading()
              : _post == null
              ? const Center(child: Text('Post not found'))
              : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Post Content
                          Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // User Info Header
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundImage:
                                          _post!.userAvatarUrl != null &&
                                                  _post!
                                                      .userAvatarUrl!
                                                      .isNotEmpty
                                              ? NetworkImage(
                                                _post!.userAvatarUrl!,
                                              )
                                              : null,
                                      backgroundColor: Colors.grey.shade300,
                                      child:
                                          (_post!.userAvatarUrl == null ||
                                                  _post!.userAvatarUrl!.isEmpty)
                                              ? const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                              )
                                              : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _post!.userName ?? 'Anonymous User',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            _post!.timeAgo,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                // Post Content
                                if (_post!.description.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    _post!.description,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],

                                // Post Images
                                if (_post!.images.isNotEmpty ||
                                    _post!.imageUrl.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  _buildPostImages(),
                                ],

                                const SizedBox(height: 12),

                                // Like and Comment Stats
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (_likeCount > 0)
                                      Text(
                                        '$_likeCount ${_likeCount == 1 ? 'like' : 'likes'}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    if (_comments.isNotEmpty)
                                      Text(
                                        '${_comments.length} ${_comments.length == 1 ? 'comment' : 'comments'}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                  ],
                                ),

                                const Divider(height: 20),

                                // Action Buttons
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildActionButton(
                                      icon:
                                          _isLiked
                                              ? Icons.thumb_up
                                              : Icons.thumb_up_outlined,
                                      label: 'Like',
                                      onPressed: _toggleLike,
                                      color:
                                          _isLiked
                                              ? const Color(0xFF1877F2)
                                              : null,
                                    ),
                                    _buildActionButton(
                                      icon: Icons.mode_comment_outlined,
                                      label: 'Comment',
                                      onPressed: () {},
                                    ),
                                    _buildActionButton(
                                      icon: Icons.share_outlined,
                                      label: 'Share',
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Comments Section
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Comments (${_comments.length})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ..._comments.map(
                                  (comment) => _buildCommentItem(comment),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 80), // Space for comment input
                        ],
                      ),
                    ),
                  ),

                  // Comment Input
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Write a comment...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: const Color(0xFF1877F2),
                          child:
                              _isSubmittingComment
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : IconButton(
                                    icon: const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                    ),
                                    onPressed: _submitComment,
                                    padding: EdgeInsets.zero,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildPostImages() {
    final images = _post!.images.isNotEmpty ? _post!.images : [_post!.imageUrl];

    if (images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: images.first,
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => Container(
                height: 300,
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator()),
              ),
          errorWidget:
              (context, url, error) => Container(
                height: 300,
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image, size: 48),
              ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 8,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image),
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    final buttonColor = color ?? Colors.grey.shade600;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: buttonColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage:
                comment.userAvatarUrl.isNotEmpty
                    ? NetworkImage(comment.userAvatarUrl)
                    : null,
            backgroundColor: Colors.grey.shade300,
            child:
                comment.userAvatarUrl.isEmpty
                    ? Icon(Icons.person, size: 16, color: Colors.grey.shade600)
                    : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(comment.text, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimeAgo(comment.timestamp),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }
}
