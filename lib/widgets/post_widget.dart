import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../utils/constants.dart';
import 'comment_bubble.dart';
import 'skeleton_loader.dart';
import '../screens/comments_screen.dart';

class PostWidget extends StatelessWidget {
  final Post post;
  const PostWidget({super.key, required this.post});

  static Widget skeleton() => Card(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonLoader(
                height: 44,
                width: 44,
                borderRadius: BorderRadius.circular(22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(height: 16, width: 80),
                    const SizedBox(height: 6),
                    SkeletonLoader(height: 12, width: 60),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SkeletonLoader(height: 16, width: double.infinity),
          const SizedBox(height: 12),
          SkeletonLoader(
            height: 180,
            width: double.infinity,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              3,
              (i) => SkeletonLoader(
                height: 24,
                width: 60,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to post details when tapping on the post
        Navigator.pushNamed(
          context,
          '/post-details',
          arguments: {'postId': post.id},
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile row with avatar and name
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      post.userAvatarUrl ?? kDefaultAvatar,
                    ),
                    radius: 22,
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.isAnonymous
                              ? 'Anonymous User'
                              : (post.userName ?? 'User'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'SFPro',
                            color: kTextDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          post.timeAgo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: 'SFPro',
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.grey),
                    onPressed: () {},
                    splashRadius: 22,
                  ),
                ],
              ),

              // Post description
              if (post.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  post.description,
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'SFPro',
                    color: kTextDark,
                  ),
                ),
              ],

              // Post image
              if (post.imageUrl.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Hero(
                    tag: post.imageUrl,
                    child: Image.network(
                      post.imageUrl,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (c, e, s) => Container(
                            height: 220,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.broken_image),
                            ),
                          ),
                    ),
                  ),
                ),
              ],

              // Display price if available
              if (post.price > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withValues(alpha: 0.15),
                        Colors.green.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.attach_money,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${post.price.toStringAsFixed(2)} AED',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'SFPro',
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.verified, color: Colors.green, size: 16),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Stats Row (Likes and Comments count) - Facebook style
              if ((post.likeCount ?? 0) > 0 || (post.commentCount ?? 0) > 0)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Like count with reactions
                      if ((post.likeCount ?? 0) > 0)
                        Row(
                          children: [
                            // Multiple reaction icons stack
                            SizedBox(
                              width: 40,
                              height: 18,
                              child: Stack(
                                children: [
                                  // Like reaction icon
                                  Positioned(
                                    left: 0,
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1877F2),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.thumb_up,
                                        color: Colors.white,
                                        size: 11,
                                      ),
                                    ),
                                  ),
                                  // Love reaction icon (if we want to add more reactions later)
                                  if ((post.likeCount ?? 0) > 5)
                                    Positioned(
                                      left: 12,
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE84142),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 2,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.favorite,
                                          color: Colors.white,
                                          size: 11,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${post.likeCount}',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 15,
                                fontFamily: 'SFPro',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                      // Comments and Shares count (right side)
                      Row(
                        children: [
                          if ((post.commentCount ?? 0) > 0)
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => CommentsScreen(
                                          postId: post.id,
                                          post: post,
                                        ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Text(
                                  '${post.commentCount} comment${(post.commentCount ?? 0) > 1 ? 's' : ''}',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 15,
                                    fontFamily: 'SFPro',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          if ((post.shareCount ?? 0) > 0) ...[
                            if ((post.commentCount ?? 0) > 0)
                              Text(
                                ' • ',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            Text(
                              '${post.shareCount} share${(post.shareCount ?? 0) > 1 ? 's' : ''}',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 15,
                                fontFamily: 'SFPro',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

              const Divider(height: 1, thickness: 0.5),
              _FacebookActionsRow(post: post),
              const Divider(height: 1, thickness: 0.5),

              // لا نعرض أي نص أو زر "عرض المزيد من التعليقات" أو رسالة "لا يوجد تعليقات"، فقط نعرض آخر تعليق إذا وجد
              if ((post.comments?.isNotEmpty ?? false))
                CommentBubble(comment: Comment.fromMap(post.comments!.last)),
              const SizedBox(height: 8),
              _WriteCommentInput(postId: post.id, post: post),
            ],
          ),
        ),
      ),
    );
  }
}

class _FacebookActionsRow extends StatelessWidget {
  final Post post;
  const _FacebookActionsRow({required this.post});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon:
              (post.isLiked ?? false)
                  ? Icons.thumb_up
                  : Icons.thumb_up_outlined,
          label: 'Like',
          color:
              (post.isLiked ?? false)
                  ? const Color(0xFF1877F2)
                  : Colors.grey[700]!,
          highlight: post.isLiked ?? false,
          onTap: () {
            // TODO: Toggle like functionality
          },
        ),
        _ActionButton(
          icon: Icons.mode_comment_outlined,
          label: 'Comment',
          color: Colors.grey[700]!,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CommentsScreen(postId: post.id, post: post),
              ),
            );
          },
        ),
        _ActionButton(
          icon: Icons.share_outlined,
          label: 'Share',
          color: Colors.grey[700]!,
          onTap: () {
            // TODO: Share functionality
          },
        ),
        _ActionButton(
          icon: Icons.send_outlined,
          label: 'Send',
          color: Colors.grey[700]!,
          onTap: () {
            // TODO: Send/Message functionality
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool highlight;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.highlight = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          splashColor:
              highlight
                  ? const Color(0xFF1877F2).withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
          highlightColor:
              highlight
                  ? const Color(0xFF1877F2).withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color:
                  highlight
                      ? const Color(0xFF1877F2).withValues(alpha: 0.05)
                      : Colors.transparent,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  child: Icon(icon, size: 24, color: color),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                    fontFamily: 'SFPro',
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// تم حذف الكلاس لأنه لم يعد مستخدماً

class _WriteCommentInput extends StatefulWidget {
  final String postId;
  final Post post;
  const _WriteCommentInput({required this.postId, required this.post});

  @override
  State<_WriteCommentInput> createState() => _WriteCommentInputState();
}

class _WriteCommentInputState extends State<_WriteCommentInput> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // تم حذف حقل "Write a comment" بالكامل
  }
}
