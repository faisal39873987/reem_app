import 'package:flutter/material.dart';
import '../models/post.dart';
import 'inline_comments_widget.dart';

class PostItem extends StatelessWidget {
  final Post post;

  const PostItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final String imageUrl =
        post.imageUrl.isNotEmpty ? post.imageUrl : 'https://i.pravatar.cc/300';
    final String creator = post.isAnonymous ? 'Anonymous User' : 'Known User';
    final String description = post.description;
    final String date = post.timestamp.toLocal().toString().split(' ')[0];
    final String price = post.price.toStringAsFixed(2);
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                imageUrl,
                height: 120,
                width: 120,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      height: 120,
                      width: 120,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.broken_image)),
                    ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  creator,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(description, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  '$price AED',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Posted: $date',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 12),
                InlineCommentsWidget(
                  postId: post.id,
                  comments: const [
                    {'text': 'Great post!'},
                    {'text': 'Is this still available?'},
                    {'text': 'Can you share more details?'},
                  ],
                  onSend: (text) {},
                  onViewAll: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
