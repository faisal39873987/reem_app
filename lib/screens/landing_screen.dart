import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

import '../screens/profile_screen.dart';
import '../screens/marketplace_screen.dart';
import '../screens/post_creation_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/menu_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/search_screen.dart';
import '../screens/nearby_highlights_screen.dart';
import '../screens/login_screen.dart';
import '../screens/post_details_screen.dart';
import '../widgets/intro_overlay.dart';
import '../utils/constants.dart';

class LandingScreen extends StatefulWidget {
  final int initialIndex;
  const LandingScreen({super.key, this.initialIndex = 0});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late int _selectedIndex;
  bool _showIntro = false;

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
    if (_selectedIndex == 0) _checkIntro();
  }

  Future<void> _checkIntro() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('intro_done') ?? false;
    if (!seen) {
      setState(() => _showIntro = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => IntroOverlay(
            animatedKeys: [homeKey, reemYouthKey, marketKey, addKey],
              onFinish: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('intro_done', true);
                if (!mounted) return;
                setState(() => _showIntro = false);
                Navigator.of(context).pop();
              },
          ),
        );
      });
    }
  }

  void _goToAddPost() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PostCreationScreen()),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    const blueColor = kPrimaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(child: _pages[_selectedIndex]),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -8),
        child: FloatingActionButton(
          key: addKey,
          onPressed: _goToAddPost,
          backgroundColor: blueColor,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, "Home", 0),
              _buildNavItem(Icons.store, "Market", 1, key: marketKey),
              const SizedBox(width: 40),
              _buildNavItem(Icons.person, "Profile", 2),
              _buildNavItem(Icons.menu, "Menu", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, {Key? key}) {
    const blueColor = kPrimaryColor;
    return GestureDetector(
      key: key,
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: blueColor),
          Text(label, style: const TextStyle(color: blueColor, fontSize: 12)),
        ],
      ),
    );
  }
}
class HomePageContent extends StatefulWidget {
  final GlobalKey homeKey;
  final GlobalKey reemYouthKey;

  const HomePageContent({super.key, required this.homeKey, required this.reemYouthKey});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  Position? _userLocation;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() => _userLocation = pos);
    } catch (e) {
      debugPrint("📍 Location error: $e");
    }
  }

  Future<void> _toggleLike(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final likeRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(user.uid);

    final doc = await likeRef.get();
    final isLiked = doc.exists;

    if (isLiked) {
      await likeRef.delete();
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      await likeRef.set({'liked': true});
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likesCount': FieldValue.increment(1),
      });
    }
  }

  double? _calculateDistance(Map<String, dynamic> post) {
    if (_userLocation == null ||
        post['location'] == null ||
        post['location']['latitude'] == null ||
        post['location']['longitude'] == null) return null;

    return Geolocator.distanceBetween(
      _userLocation!.latitude,
      _userLocation!.longitude,
      post['location']['latitude'],
      post['location']['longitude'],
    ) / 1000;
  }

  @override
  Widget build(BuildContext context) {
    const blueColor = kPrimaryColor;

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
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: blueColor),
              ),
              const Spacer(),
              IconButton(
                key: widget.reemYouthKey,
                icon: const Icon(Icons.people_alt, color: blueColor),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NearbyHighlightsScreen()));
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: blueColor),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationScreen()));
                },
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: blueColor),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ChatScreen(
                            chatId: 'demo',
                            receiverId: 'none',
                            receiverName: 'Guest',
                            receiverImage: '',
                          )));
                },
              ),
              IconButton(
                icon: const Icon(Icons.search, color: blueColor),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .where('category', whereIn: ['General', 'For Sale', 'For Rent', 'Public Service', 'Advertisement'])
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                debugPrint("🔥 Firestore Error in Landing Page: ${snapshot.error}");
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final posts = snapshot.data!.docs;

              if (posts.isEmpty) {
                return const Center(child: Text("No posts yet."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  try {
                    final doc = posts[index];
                    final postId = doc.id;
                    final data = doc.data() as Map<String, dynamic>;
                    final imageUrl = data['imageUrl'] ?? '';
                    final price = data['price']?.toString() ?? '0';
                    final category = data['category'] ?? 'General';
                    final creatorId = data['creatorId'] ?? '';
                    final showDistance = data['showDistance'] ?? false;
                    final distance = showDistance ? _calculateDistance(data) : null;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(creatorId).get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData || userSnapshot.data == null) return SizedBox.shrink();
                        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;

                        final userName = userData?['name'] ?? 'User';
                        final userImage = userData?['photoUrl'] ?? '';

                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => PostDetailsScreen(postId: postId)),
                                );
                              },
                              child: Card(
                                color: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.only(bottom: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      ListTile(
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        leading: CircleAvatar(
                                          backgroundImage: userImage.isNotEmpty
                                              ? NetworkImage(userImage)
                                              : const AssetImage('assets/images/default_user.png') as ImageProvider,
                                          radius: 20,
                                        ),
                                      title: Text(
                                        userName,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    if (imageUrl.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                        child: Image.network(
                                          imageUrl,
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.broken_image, size: 100),
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return const Center(child: CircularProgressIndicator());
                                          },
                                        ),
                                      ),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade100,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  category,
                                                  style: const TextStyle(fontSize: 12, color: kPrimaryColor),
                                                ),
                                              ),
                                              const Spacer(),
                                              Text("AED $price", style: const TextStyle(color: Colors.black54)),
                                            ],
                                          ),
                                          if (showDistance && distance != null)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 6),
                                              child: Text(
                                                "~${distance.toStringAsFixed(1)} km away",
                                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                              ),
                                            ),

                                          const SizedBox(height: 8),

                                          // ❤️ عدد اللايكات
                                          FutureBuilder<DocumentSnapshot>(
                                            future: FirebaseFirestore.instance.collection('posts').doc(postId).get(),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData || snapshot.data == null) return const SizedBox.shrink();
                                              final postData = snapshot.data!.data() as Map<String, dynamic>;
                                              final count = postData['likesCount'] ?? 0;
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 6),
                                                child: Text("❤️ $count Likes",
                                                    style: const TextStyle(color: Colors.grey)),
                                              );
                                            },
                                          ),

                                          const SizedBox(height: 8),

                                          // 🔘 أزرار التفاعل
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.thumb_up_alt_outlined, color: Colors.grey),
                                                onPressed: () => _toggleLike(postId),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.comment_outlined, color: Colors.grey),
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) => PostDetailsScreen(postId: postId),
                                                    ),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.send_outlined, color: Colors.grey),
                                                onPressed: () async {
                                                  final currentUser = FirebaseAuth.instance.currentUser;
                                                  if (currentUser == null ||
                                                      currentUser.uid == creatorId ||
                                                      _isNavigating) return;

                                                  setState(() => _isNavigating = true);

                                                  final sortedIds = [currentUser.uid, creatorId]..sort();
                                                  final chatId = '${sortedIds[0]}_${sortedIds[1]}';

                                                  await Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) => ChatScreen(
                                                        chatId: chatId,
                                                        receiverId: creatorId,
                                                        receiverName: userName,
                                                        receiverImage: userImage,
                                                      ),
                                                    ),
                                                  );
                                                  if (!mounted) return;

                                                  setState(() => _isNavigating = false);
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(
                              height: 24,
                              thickness: 1,
                              indent: 12,
                              endIndent: 12,
                              color: Color(0xFFE0E0E0),
                            ),
                          ],
                        );
                      },
                    );
                  } catch (e) {
                    debugPrint("⚠️ Error rendering post: $e");
                    return const SizedBox.shrink();
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
