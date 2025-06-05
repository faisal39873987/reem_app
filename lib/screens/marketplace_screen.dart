import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/locale_provider.dart';
import '../services/location_service.dart';
import 'chat_list_screen.dart';
import 'post_creation_screen.dart';
import 'notification_screen.dart';
import 'search_screen.dart';
import 'nearby_highlights_screen.dart';
import 'post_details_screen.dart';
import 'chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  Position? _userLocation;
  bool _onlyNearby = false;
  String _selectedCategory = 'All';
  bool _isNavigating = false;

  final List<String> _categories = [
    'All',
    'General',
    'For Sale',
    'For Rent',
    'Public Service',
    'Advertisement',
  ];

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

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                value: _onlyNearby,
                onChanged: (val) {
                  setState(() => _onlyNearby = val);
                  Navigator.pop(context);
                },
                activeColor: Colors.blue,
                title: const Text("Show nearby posts only (10km)"),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCategory = val);
                    Navigator.pop(context);
                  }
                },
                items: _categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const blueColor = Color(0xFF1877F2);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        child: Column(
          children: [
            // 🔵 Header
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  const Text("Marketplace",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: blueColor)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _openFilterSheet,
                    icon: const Icon(Icons.filter_list, color: blueColor),
                    label: const Text("Filter", style: TextStyle(color: blueColor)),
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
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatListScreen()));
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
            // 🔵 Posts GridView
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    debugPrint("🔥 Firestore Error: ${snapshot.error}");
                    return const Center(child: Text("Error loading posts."));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allPosts = snapshot.data!.docs;

                  final filtered = allPosts.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final category = data['category'] ?? 'General';

                    if (_selectedCategory != 'All' && category != _selectedCategory) return false;

                    if (_onlyNearby) {
                      final d = _calculateDistance(data);
                      return d != null && d <= 10;
                    }

                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text("No posts found."));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final postId = doc.id;

                      final imageUrl = data['imageUrl'] ?? '';
                      final description = data['description'] ?? '';
                      final price = data['price']?.toString() ?? '0';
                      final location = data['location'];
                      final creatorId = data['creatorId'] ?? '';
                      final distance = _calculateDistance(data);

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => PostDetailsScreen(postId: postId)),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (imageUrl.isNotEmpty)
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: Image.network(
                                    imageUrl,
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 80),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      description.length > 20
                                          ? '${description.substring(0, 20)}...'
                                          : description,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text("AED $price", style: const TextStyle(color: Colors.black87)),
                                    if (distance != null)
                                      Text("~${distance.toStringAsFixed(1)} km",
                                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              // 🔘 زر تواصل
                              FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance.collection('users').doc(creatorId).get(),
                                builder: (context, userSnapshot) {
                                  final userData = userSnapshot.data?.data() as Map<String, dynamic>?;

                                  final userName = userData?['name'] ?? 'User';
                                  final userImage = userData?['imageUrl'] ?? '';
                                  final currentUser = FirebaseAuth.instance.currentUser;

                                  return Align(
                                    alignment: Alignment.bottomRight,
                                    child: IconButton(
                                      icon: const Icon(Icons.send_outlined, color: Colors.grey),
                                      onPressed: () async {
                                        if (currentUser == null ||
                                            currentUser.uid == creatorId ||
                                            _isNavigating) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Cannot message yourself.")),
                                          );
                                          return;
                                        }

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

                                        setState(() => _isNavigating = false);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
