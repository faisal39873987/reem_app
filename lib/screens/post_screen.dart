import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'notification_screen.dart';
import 'chat_list_screen.dart';
import 'search_screen.dart';
import 'post_creation_screen.dart';
import 'landing_screen.dart';
import 'marketplace_screen.dart';
import 'profile_screen.dart';
import 'menu_screen.dart';
import '../services/location_service.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  Position? _userLocation;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    final pos = await LocationService.getCurrentLocation();
    setState(() => _userLocation = pos);
  }

  double? _calculateDistance(Map<String, dynamic> post) {
    if (_userLocation == null ||
        post['location'] == null ||
        post['location']['latitude'] == null ||
        post['location']['longitude'] == null) {
      return null;
    }
    final postLat = post['location']['latitude'];
    final postLng = post['location']['longitude'];
    return Geolocator.distanceBetween(
          _userLocation!.latitude,
          _userLocation!.longitude,
          postLat,
          postLng,
        ) /
        1000; // in km
  }

  void _handleProtectedNavigation(BuildContext context, Widget screen) {
    final user = FirebaseAuth.instance.currentUser;
    final isGuest = user == null || user.isAnonymous;

    if (isGuest) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Login Required"),
          content: const Text("Please log in to access this feature."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    }
  }

  @override
  Widget build(BuildContext context) {
    const blueColor = Color(0xFF1877F2);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                const Text(
                  "Posts",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: blueColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: blueColor),
                  onPressed: () => _handleProtectedNavigation(context, const NotificationScreen()),
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: blueColor),
                  onPressed: () => _handleProtectedNavigation(context, const ChatListScreen()),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: blueColor),
                  onPressed: () => _handleProtectedNavigation(context, const SearchScreen()),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No posts available.'));
                }

                final posts = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final data = posts[index].data() as Map<String, dynamic>;
                    final imageUrl = data['imageUrl'] ?? '';
                    final description = data['description'] ?? '';
                    final price = data['price']?.toString() ?? '0';
                    final showDistance = data['showDistance'] ?? false;
                    final distance = showDistance ? _calculateDistance(data) : null;

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                imageUrl,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(description, style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 4),
                                Text("AED $price", style: const TextStyle(color: Colors.black54)),
                                if (showDistance && distance != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      "~${distance.toStringAsFixed(1)} km away",
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -8),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PostCreationScreen()),
            );
          },
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
              IconButton(
                icon: const Icon(Icons.home, color: blueColor),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LandingScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.store, color: blueColor),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
                  );
                },
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: const Icon(Icons.person, color: blueColor),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.menu, color: blueColor),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
