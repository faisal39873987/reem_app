import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'chat_screen.dart';
import 'post_details_screen.dart';

class NearbyHighlightsScreen extends StatefulWidget {
  const NearbyHighlightsScreen({super.key});

  @override
  State<NearbyHighlightsScreen> createState() => _NearbyHighlightsScreenState();
}

class _NearbyHighlightsScreenState extends State<NearbyHighlightsScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  late MatchEngine _matchEngine;
  List<SwipeItem> _swipeItems = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('posts')
          .where('status', isEqualTo: 'active')
          .get();

      final allDocs = query.docs;
      if (allDocs.isEmpty) {
        setState(() {
          _loading = false;
          _swipeItems = [];
        });
        return;
      }

      _swipeItems = allDocs.map((doc) {
        final data = doc.data();
        return SwipeItem(
          content: {
            'title': data['title'] ?? 'Untitled',
            'imageUrl': data['images'] != null && data['images'].isNotEmpty ? data['images'][0] : '',
            'description': data['description'] ?? '',
            'price': data['price']?.toString() ?? '',
            'userId': data['userId'] ?? '',
            'postId': doc.id,
          },
          likeAction: () => _startChat(data['userId']),
          nopeAction: () {},
          superlikeAction: () => _startChat(data['userId']),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _matchEngine = MatchEngine(swipeItems: _swipeItems);
          _loading = false;
        });
      }
    } catch (e) {
      print("❌ Error loading products: $e");
      setState(() => _loading = false);
    }
  }

  void _startChat(String sellerId) {
    if (uid != null && sellerId != uid) {
      final sortedIds = [uid!, sellerId]..sort();
      final chatId = '${sortedIds[0]}_${sortedIds[1]}';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            receiverId: sellerId,
            receiverName: '',
            receiverImage: '',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can't chat with yourself.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const blueColor = Color(0xFF1877F2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: blueColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Explore Products', style: TextStyle(color: blueColor)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: blueColor),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _swipeItems.isEmpty
              ? const Center(child: Text("No active products available."))
              : SwipeCards(
                  matchEngine: _matchEngine,
                  itemBuilder: (context, index) {
                    final product = _swipeItems[index].content as Map<String, dynamic>;
                    final image = product['imageUrl'] ?? '';
                    final title = product['title'] ?? '';
                    final price = product['price'] ?? '';
                    final postId = product['postId'];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostDetailsScreen(postId: postId),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (image.isNotEmpty)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: Image.network(
                                  image,
                                  height: 300,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 300,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image, size: 80, color: Colors.grey),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text("\$ $price", style: const TextStyle(fontSize: 16, color: Colors.green)),
                                  const SizedBox(height: 12),
                                  const Text("Swipe right to chat with seller"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  onStackFinished: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No more products.")),
                    );
                  },
                  itemChanged: (item, index) {},
                  upSwipeAllowed: false,
                  fillSpace: true,
                ),
    );
  }
}
