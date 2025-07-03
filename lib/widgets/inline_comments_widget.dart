import 'package:flutter/material.dart';
import '../utils/constants.dart';

class InlineCommentsWidget extends StatelessWidget {
  final String postId;
  final List<Map<String, String>> comments; // Replace with your Comment model
  final void Function(String) onSend;
  final VoidCallback? onViewAll;

  const InlineCommentsWidget({
    super.key,
    required this.postId,
    required this.comments,
    required this.onSend,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final int visibleCount = comments.length > 3 ? 3 : comments.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 140),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleCount,
            itemBuilder:
                (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: kPrimaryColor,
                        child: const Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            comments[i]['text'] ?? '',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ),
        if (comments.length > 3 && onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Text(
              'View all comments',
              style: TextStyle(color: kPrimaryColor),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Write a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                minLines: 1,
                maxLines: 2,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: kPrimaryColor),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  onSend(controller.text.trim());
                  controller.clear();
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
