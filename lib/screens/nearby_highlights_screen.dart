import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'post_details_screen.dart';
import '../utils/constants.dart';

class NearbyHighlightsScreen extends StatefulWidget {
  const NearbyHighlightsScreen({super.key});

  @override
  State<NearbyHighlightsScreen> createState() => _NearbyHighlightsScreenState();
}

class _NearbyHighlightsScreenState extends State<NearbyHighlightsScreen> {
  late MatchEngine _matchEngine;
  final List<SwipeItem> _swipeItems = [];
  final bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    // All Firebase usage has been removed. Supabase is now used for all backend operations.
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('BUILD: NearbyHighlightsScreen');
    const blueColor = kPrimaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: blueColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Explore Products',
          style: TextStyle(color: blueColor),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: blueColor),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _swipeItems.isEmpty
              ? const Center(child: Text("No active products available."))
              : SwipeCards(
                matchEngine: _matchEngine,
                itemBuilder: (context, index) {
                  final product =
                      _swipeItems[index].content as Map<String, dynamic>;
                  final image = product['imageUrl'] ?? '';
                  final title = product['title'] ?? '';
                  final price = product['price'] ?? '';
                  final postId = product['postId'];

                  return GestureDetector(
                    onTap: () {
                      debugPrint('NAVIGATE: PostDetailsScreen with postId: $postId');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailsScreen(postId: postId),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (image.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                image,
                                height: 300,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      height: 300,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image,
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "\$ $price",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
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
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(
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
