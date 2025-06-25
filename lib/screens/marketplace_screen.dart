import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feed_provider.dart';
import '../utils/constants.dart';
import '../models/post.dart';
import 'post_details_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  final List<Post>? testPosts;
  const MarketplaceScreen({super.key, this.testPosts});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  late List<Post> _posts;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.testPosts != null) {
      _posts = widget.testPosts!;
      _loading = false;
    } else {
      _fetchPosts();
    }
  }

  Future<void> _fetchPosts({bool force = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Provider.of<FeedProvider>(
        context,
        listen: false,
      ).fetchPosts(force: force);
      setState(() {
        _posts = Provider.of<FeedProvider>(context, listen: false).posts;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load posts';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('BUILD: MarketplaceScreen');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Marketplace',
          style: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: kPrimaryColor),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Marketplace is currently unavailable.',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: () => _fetchPosts(force: true),
                child:
                    _posts.isEmpty
                        ? const Center(child: Text('No posts found.'))
                        : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.7,
                              ),
                          itemCount: _posts.length,
                          itemBuilder:
                              (context, i) =>
                                  _MarketplaceGridItem(post: _posts[i]),
                        ),
              ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_marketplace',
        onPressed: () {
          // TODO: Navigate to add post screen
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _MarketplaceGridItem extends StatelessWidget {
  final Post post;
  const _MarketplaceGridItem({required this.post});

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        post.imageUrl.isNotEmpty ? post.imageUrl : 'https://i.pravatar.cc/300';
    final price = post.price.toStringAsFixed(2);
    final description =
        post.description.isNotEmpty ? post.description : 'No description';
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PostDetailsScreen(postId: post.id.toString()),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      height: 140,
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
                  Row(
                    children: [
                      const Icon(
                        Icons.storefront,
                        color: kPrimaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: kPrimaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        color: Colors.green,
                        size: 18,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        price.isNotEmpty ? '$price درهم' : '',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
