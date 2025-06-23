import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_widget.dart';
import '../utils/constants.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<FeedProvider>(context, listen: false).fetchPosts(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feed = Provider.of<FeedProvider>(context);
    debugPrint('BUILD: MarketplaceScreen');
    return Scaffold(
      backgroundColor: kBackgroundColor,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: kPrimaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: kPrimaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: kPrimaryColor),
            onPressed: () {},
          ),
        ],
        iconTheme: const IconThemeData(color: kPrimaryColor),
      ),
      body:
          feed.loading
              ? const Center(child: CircularProgressIndicator())
              : feed.error != null
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
                onRefresh: () => feed.fetchPosts(force: true),
                child: ListView.builder(
                  itemCount: feed.posts.length,
                  itemBuilder: (context, i) => PostWidget(post: feed.posts[i]),
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
