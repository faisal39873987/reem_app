import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_screen.dart';
import 'chat_list_screen.dart';
import 'post_creation_screen.dart';
import 'landing_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  void _navigateTo(BuildContext context, int index) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => LandingScreen(initialIndex: index),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Stream<List<QueryDocumentSnapshot>> _getCombinedResults(String term) async* {
    final posts = await FirebaseFirestore.instance
        .collection('posts')
        .where('description', isGreaterThanOrEqualTo: term)
        .where('description', isLessThanOrEqualTo: '$term\uf8ff')
        .get();

    final services = await FirebaseFirestore.instance
        .collection('services')
        .where('title', isGreaterThanOrEqualTo: term)
        .where('title', isLessThanOrEqualTo: '$term\uf8ff')
        .get();

    yield [...posts.docs, ...services.docs];
  }

  @override
  Widget build(BuildContext context) {
    const blueColor = Color(0xFF1877F2);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ الشريط العلوي مع سهم الرجوع
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: blueColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Search",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: blueColor),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const NotificationScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, color: blueColor),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const ChatListScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchTerm = value.trim()),
                decoration: const InputDecoration(
                  labelText: "Search posts and services",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: _searchTerm.isEmpty
                  ? const Center(child: Text("Enter a keyword to search"))
                  : StreamBuilder<List<QueryDocumentSnapshot>>(
                      stream: _getCombinedResults(_searchTerm),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text("No results found"));
                        }
                        final results = snapshot.data!;
                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: results.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final doc = results[index];
                            final isPost = doc.reference.path.contains('posts');
                            final data = doc.data() as Map<String, dynamic>;
                            return ListTile(
                              leading: Icon(
                                isPost ? Icons.post_add : Icons.home_repair_service,
                                color: blueColor,
                              ),
                              title: Text(data['title'] ?? data['description'] ?? ''),
                              subtitle: Text("${isPost ? 'Post' : 'Service'} | AED ${data['price'] ?? 'N/A'}"),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
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
                onPressed: () => _navigateTo(context, 0),
              ),
              IconButton(
                icon: const Icon(Icons.store, color: blueColor),
                onPressed: () => _navigateTo(context, 1),
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: const Icon(Icons.person, color: blueColor),
                onPressed: () => _navigateTo(context, 2),
              ),
              IconButton(
                icon: const Icon(Icons.menu, color: blueColor),
                onPressed: () => _navigateTo(context, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
