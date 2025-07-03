import 'package:flutter/material.dart';
import '../models/post.dart';
import 'skeleton_loader.dart';

import '../utils/constants.dart';

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  static Widget skeleton() => Card(
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 1.5,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
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
          const SizedBox(height: 10),
          SkeletonLoader(height: 16, width: double.infinity),
          const SizedBox(height: 10),
          SkeletonLoader(
            height: 180,
            width: double.infinity,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المنشور في الأعلى
            if (post.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                child: AspectRatio(
                  aspectRatio: 0.75, // ثابتة لعرض صورة عمودية
                  child: Image.network(
                    post.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.broken_image)),
                        ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صف المستخدم والتاريخ
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          (post.userAvatarUrl != null &&
                                  post.userAvatarUrl!.isNotEmpty)
                              ? post.userAvatarUrl!
                              : kDefaultAvatar,
                        ),
                        backgroundColor: Colors.grey[200],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (post.userName != null &&
                                      post.userName!.isNotEmpty)
                                  ? post.userName!
                                  : 'User',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                fontFamily: 'SFPro',
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              post.timeAgo,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
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
                  if (post.description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      post.description,
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'SFPro',
                        color: Colors.black87,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  _FacebookActionsRow(post: post),
                  if (post.comments != null && post.comments!.isNotEmpty) ...[
                    const Divider(height: 18),
                    ...post.comments!
                        .take(2)
                        .map((c) => _CommentPreview(comment: c)),
                  ],
                ],
              ),
            ),
          ],
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
          icon: Icons.thumb_up_alt_outlined,
          label: 'Like',
          count: post.likeCount ?? 0,
          color:
              (post.isLiked ?? false)
                  ? const Color(0xFF1877F2)
                  : Colors.grey[700],
          highlight: post.isLiked ?? false,
          onTap: () {},
        ),
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          label: 'Comment',
          count: post.commentCount ?? 0,
          color: Colors.grey[700],
          onTap: () {},
        ),
        _ActionButton(
          icon: Icons.share_outlined,
          label: 'Share',
          color: Colors.grey[700],
          onTap: () {},
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? count;
  final Color? color;
  final bool highlight;
  final VoidCallback? onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    this.count,
    this.color,
    this.highlight = false,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        splashColor: const Color(0x221877F2),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  fontFamily: 'SFPro',
                  color: color,
                ),
              ),
              if (count != null && count! > 0) ...[
                const SizedBox(width: 4),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    fontFamily: 'SFPro',
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentPreview extends StatelessWidget {
  final dynamic comment;
  const _CommentPreview({required this.comment});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage(comment.avatarUrl ?? ''),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black),
                children: [
                  TextSpan(
                    text: comment.userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '  '),
                  TextSpan(text: comment.text),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
