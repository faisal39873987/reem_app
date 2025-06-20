import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'chat_screen.dart';
import '../utils/constants.dart';

class PostDetailsScreen extends StatefulWidget {
  final String postId;
  const PostDetailsScreen({super.key, required this.postId});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  late DocumentReference _postRef;
  late CollectionReference _likesRef;
  late CollectionReference _commentsRef;

  bool _isLiked = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
    _likesRef = _postRef.collection('likes');
    _commentsRef = _postRef.collection('comments');
    _checkLiked();
  }

  Future<void> _checkLiked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await _likesRef.doc(user.uid).get();
    if (!mounted) return;
    setState(() => _isLiked = doc.exists);
  }

  void _toggleLike() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final doc = _likesRef.doc(userId);
    final exists = (await doc.get()).exists;

    if (exists) {
      await doc.delete();
      if (!mounted) return;
      setState(() => _isLiked = false);
    } else {
      await doc.set({'likedAt': Timestamp.now()});
      if (!mounted) return;
      setState(() => _isLiked = true);
    }
  }

  void _addComment() async {
    final text = _commentController.text.trim();
    final user = FirebaseAuth.instance.currentUser;
    if (text.isEmpty || user == null) return;

    await _commentsRef.add({
      'userId': user.uid,
      'userName': user.displayName ?? 'User',
      'text': text,
      'timestamp': Timestamp.now(),
    });

    _commentController.clear();
  }

  Future<void> _addReply(String commentId, String text) async {
    final user = FirebaseAuth.instance.currentUser;
    if (text.isEmpty || user == null) return;

    await _commentsRef
        .doc(commentId)
        .collection('replies')
        .add({
      'userId': user.uid,
      'userName': user.displayName ?? 'User',
      'text': text,
      'timestamp': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    const blue = kPrimaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Details", style: TextStyle(color: blue)),
        iconTheme: const IconThemeData(color: blue),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future: _postRef.get(),
        builder: (context, snapshot) {
if (snapshot.connectionState == ConnectionState.waiting) {
  return const Center(child: CircularProgressIndicator());
}
if (snapshot.hasError) {
  return const Center(child: Text("Error loading post."));
}
if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
  return const Center(child: Text("Post not found."));
}


          final data = snapshot.data!.data() as Map<String, dynamic>;
          final imageUrl = data['imageUrl'] ?? '';
          final description = data['description'] ?? '';
          final price = data['price']?.toString() ?? '0';
          final category = data['category'] ?? 'General';
          final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
          final location = data['location'];
          final creatorId = data['creatorId'] ?? '';
          final distance = location != null && location['latitude'] != null ? "~Location enabled" : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl.isNotEmpty)
                Image.network(imageUrl, width: double.infinity, height: 220, fit: BoxFit.cover),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(description, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Price: AED $price", style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text("Category: $category", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                    if (distance != null) ...[
                      const SizedBox(height: 6),
                      Text(distance, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      timestamp != null ? DateFormat.yMMMMd().add_jm().format(timestamp) : '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // ✅ زر تواصل مع صاحب البوست
                    ElevatedButton.icon(
                      onPressed: () async {
                        final currentUser = FirebaseAuth.instance.currentUser;
                        final creatorId = data['creatorId'];

                        if (currentUser == null || creatorId == '' || currentUser.uid == creatorId) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("You can't message yourself.")),
                          );
                          return;
                        }

                        final sortedIds = [currentUser.uid, creatorId]..sort();
                        final chatId = '${sortedIds[0]}_${sortedIds[1]}';

                        final userDoc = await FirebaseFirestore.instance.collection('users').doc(creatorId).get();
                        final userData = userDoc.data();

                        final receiverName = userData?['name'] ?? 'User';
                        final receiverImage = userData?['photoUrl'] ?? '';

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              chatId: chatId,
                              receiverId: creatorId,
                              receiverName: receiverName,
                              receiverImage: receiverImage,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text("Message Owner"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                          onPressed: _toggleLike,
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: _likesRef.snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data == null) return const SizedBox();
                            return Text("${snapshot.data!.docs.length} likes", style: const TextStyle(fontSize: 14));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: "Write a comment...",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: blue),
                      onPressed: _addComment,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _commentsRef.orderBy('timestamp', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) return const Center(child: CircularProgressIndicator());
                    final comments = snapshot.data!.docs;
                    if (comments.isEmpty) return const Center(child: Text("No comments yet."));
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (_, __) => const Divider(),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final commentDoc = comments[index];
                        final comment = commentDoc.data() as Map<String, dynamic>;
                        final commentId = commentDoc.id;
                        final text = comment['text'] ?? '';
                        final userName = comment['userName'] ?? 'User';
                        final time = (comment['timestamp'] as Timestamp?)?.toDate();
                        final timeText = time != null ? DateFormat('hh:mm a').format(time) : '';

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(text),
                              trailing: Text(timeText, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: _commentsRef
                                  .doc(commentId)
                                  .collection('replies')
                                  .orderBy('timestamp')
                                  .snapshots(),
                              builder: (context, replySnap) {
                                if (!replySnap.hasData || replySnap.data == null) {
                                  return const SizedBox.shrink();
                                }
                                final replies = replySnap.data!.docs;
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: replies.length,
                                  itemBuilder: (context, idx) {
                                    final reply = replies[idx].data() as Map<String, dynamic>;
                                    final rText = reply['text'] ?? '';
                                    final rUser = reply['userName'] ?? 'User';
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 32, bottom: 4),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(text: '$rUser: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                                                  TextSpan(text: rText),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () async {
                                  final controller = TextEditingController();
                                  final replyText = await showDialog<String>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Reply'),
                                      content: TextField(
                                        controller: controller,
                                        decoration: const InputDecoration(labelText: 'Write a reply'),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, controller.text.trim()),
                                          child: const Text('Send'),
                                        )
                                      ],
                                    ),
                                  );
                                  if (replyText != null && replyText.isNotEmpty) {
                                    _addReply(commentId, replyText);
                                  }
                                },
                                child: const Text('Reply'),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
