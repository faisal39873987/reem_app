import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../screens/profile_screen.dart';
import '../screens/marketplace_screen.dart';
import '../screens/post_creation_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/menu_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/search_screen.dart';
import '../screens/nearby_highlights_screen.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_widget.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/constants.dart';

class LandingScreen extends StatefulWidget {
  final int initialIndex;
  const LandingScreen({super.key, this.initialIndex = 0});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int _selectedIndex = 0;

  final homeKey = GlobalKey();
  final reemYouthKey = GlobalKey();
  final marketKey = GlobalKey();
  final addKey = GlobalKey();

  List<Widget> get _pages => [
    HomePageContent(homeKey: homeKey, reemYouthKey: reemYouthKey),
    const MarketplaceScreen(),
    const ProfileScreen(),
    const MainMenuScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _goToAddPost() async {
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('isGuest') ?? false;
    if (isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login is required to access this page')),
      );
      return;
    }
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PostCreationScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(child: _pages[_selectedIndex]),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -8),
        child: FloatingActionButton(
          heroTag: 'fab_landing',
          onPressed: _goToAddPost,
          backgroundColor: kPrimaryColor,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) async {
          final prefs = await SharedPreferences.getInstance();
          final isGuest = prefs.getBool('isGuest') ?? false;
          if ((index == 2 || index == 3) && isGuest) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login is required to access this page'),
              ),
            );
            return;
          }
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  final GlobalKey homeKey;
  final GlobalKey reemYouthKey;

  const HomePageContent({
    super.key,
    required this.homeKey,
    required this.reemYouthKey,
  });

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  @override
  void initState() {
    super.initState();
    // جلب المنشورات عند أول تحميل
    Future.microtask(
      () => Provider.of<FeedProvider>(context, listen: false).fetchPosts(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const blueColor = kPrimaryColor;
    final feed = Provider.of<FeedProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            children: [
              Text(
                key: widget.homeKey,
                "ReemVerse",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: blueColor,
                ),
              ),
              const Spacer(),
              IconButton(
                key: widget.reemYouthKey,
                icon: const Icon(Icons.people_alt, color: blueColor),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NearbyHighlightsScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: blueColor),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: blueColor),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => const ChatScreen(
                            chatId: 'demo',
                            receiverId: 'none',
                            receiverName: 'Guest',
                            receiverImage: '',
                          ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.search, color: blueColor),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child:
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
                          'Feed is currently unavailable.',
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
                      itemBuilder:
                          (context, i) => PostWidget(post: feed.posts[i]),
                    ),
                  ),
        ),
      ],
    );
  }
}
