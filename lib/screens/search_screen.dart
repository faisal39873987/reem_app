import 'package:flutter/material.dart';
import 'notification_screen.dart';
import 'chat_list_screen.dart';
import 'post_creation_screen.dart';
import 'landing_screen.dart';
import '../utils/constants.dart';

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
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                LandingScreen(initialIndex: index),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const blueColor = kPrimaryColor;

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
                    icon: const Icon(
                      Icons.notifications_none,
                      color: blueColor,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: blueColor,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const ChatListScreen(),
                        ),
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
                onChanged: (value) {
                  if (!mounted) return;
                  setState(() => _searchTerm = value.trim());
                },
                decoration: const InputDecoration(
                  labelText: "Search posts and services",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child:
                  _searchTerm.isEmpty
                      ? const Center(child: Text("Enter a keyword to search"))
                      : Center(
                        child: Text("Search results for: $_searchTerm"),
                      ), // Placeholder for search results
            ),
          ],
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -8),
        child: FloatingActionButton(
          heroTag: 'fab_search',
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
