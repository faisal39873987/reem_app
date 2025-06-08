import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'chat_screen.dart';

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
    if (currentUser == null) return;
    final doc = await _likesRef.doc(currentUser!.uid).get();
    if (mounted) setState(() => _isLiked = doc.exists);
  }

  void _toggleLike() async {
    final userId = currentUser?.uid;
    if (userId == null) return;

    final doc = _likesRef.doc(userId);
    final exists = (await doc.get()).exists;

    if (exists) {
      await doc.delete();
      setState(() => _isLiked = false);
    } else {
      await doc.set({'likedAt': Timestamp.now()});
      setState(() => _isLiked = true);
    }
  }

  void _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || currentUser == null) return;

    await _commentsRef.add({
      'userId': currentUser!.uid,
      'userName': currentUser!.displayName ?? 'User',
      'text': text,
      'timestamp': Timestamp.now(),
    });

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1877F2);

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
          if (!snapshot.hasData || !snapshot.data!.exists) {
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
                        final receiverImage = userData?['imageUrl'] ?? '';

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
                            if (!snapshot.hasData) return const SizedBox();
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
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final comments = snapshot.data!.docs;
                    if (comments.isEmpty) return const Center(child: Text("No comments yet."));
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (_, __) => const Divider(),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index].data() as Map<String, dynamic>;
                        final text = comment['text'] ?? '';
                        final userName = comment['userName'] ?? 'User';
                        final time = (comment['timestamp'] as Timestamp?)?.toDate();
                        final timeText = time != null ? DateFormat('hh:mm a').format(time) : '';
                        return ListTile(
                          title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(text),
                          trailing: Text(timeText, style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
