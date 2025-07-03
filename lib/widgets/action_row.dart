import 'package:flutter/material.dart';
import '../models/post.dart';
import 'like_button.dart';

class ActionRow extends StatelessWidget {
  final Post post;
  const ActionRow({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        LikeButton(
          isLiked: post.isLiked ?? false,
          likeCount: post.likeCount ?? 0,
          onTap: () {},
        ),
        _ActionIcon(
          icon: Icons.mode_comment_outlined,
          label: 'Comment',
          count: post.commentCount ?? (post.comments?.length ?? 0),
          color: Colors.grey[700],
          onTap: () {},
        ),
        _ActionIcon(
          icon: Icons.share_outlined,
          label: 'Share',
          count: 0,
          color: Colors.grey[700],
          onTap: () {},
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color? color;
  final VoidCallback? onTap;
  const _ActionIcon({
    required this.icon,
    required this.label,
    required this.count,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
            if (count > 0) ...[
              const SizedBox(width: 2),
              Text(
                count.toString(),
                style: TextStyle(color: color, fontWeight: FontWeight.w400),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
