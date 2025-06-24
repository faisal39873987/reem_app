import 'package:flutter/material.dart';
import '../models/post.dart';
import '../utils/constants.dart';

class PostWidget extends StatelessWidget {
  final Post post;
  const PostWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final double price =
        (post.price == null || post.price!.isNaN || post.price!.isInfinite)
            ? 0.0
            : post.price!;
    final String imageUrl =
        (post.imageUrl?.isNotEmpty ?? false)
            ? post.imageUrl!
            : 'https://i.pravatar.cc/300';
    final String description =
        (post.description?.isNotEmpty ?? false)
            ? post.description!
            : 'No description';
    final String category =
        (post.category?.isNotEmpty ?? false) ? post.category! : 'General';
    final String creator =
        (post.isAnonymous == true)
            ? 'Anonymous User'
            : ((post.creatorId?.isNotEmpty ?? false)
                ? post.creatorId!
                : 'User');
    final String date = post.timestamp.toLocal().toString().split(' ').first;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.broken_image)),
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
                  '${price.toStringAsFixed(2)} AED',
                  style: TextStyle(color: kPrimaryColor),
                ),
                const SizedBox(height: 8),
                Text(
                  category,
                  style: TextStyle(fontSize: 12, color: kTextLight),
                ),
                const SizedBox(height: 8),
                Text('Posted: $date'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
