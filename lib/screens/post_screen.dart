import 'package:flutter/material.dart';
import 'notification_screen.dart';
import 'chat_list_screen.dart';
import 'search_screen.dart';
import 'post_creation_screen.dart';
import 'marketplace_screen.dart';
import '../utils/constants.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('BUILD: PostScreen');
    const blueColor = kPrimaryColor;

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
                  onPressed: () {
                    debugPrint('NAVIGATE: NotificationScreen');
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
                    debugPrint('NAVIGATE: ChatListScreen');
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ChatListScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: blueColor),
                  onPressed: () {
                    debugPrint('NAVIGATE: SearchScreen');
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: Center(child: Text('No posts available.'))),
        ],
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -8),
        child: FloatingActionButton(
          heroTag: 'fab_post',
          onPressed: () {
            debugPrint('NAVIGATE: PostCreationScreen');
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
                  debugPrint('NAVIGATE: LandingPage');
                  Navigator.of(context).pushReplacementNamed('/landing');
                },
              ),
              IconButton(
                icon: const Icon(Icons.store, color: blueColor),
                onPressed: () {
                  debugPrint('NAVIGATE: MarketplaceScreen');
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder:
                          (context, animation, secondaryAnimation) =>
                              const MarketplaceScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: const Icon(Icons.person, color: blueColor),
                onPressed: () {
                  debugPrint('NAVIGATE: ProfilePage');
                  Navigator.of(context).pushReplacementNamed('/profile');
                },
              ),
              IconButton(
                icon: const Icon(Icons.menu, color: blueColor),
                onPressed: () {
                  debugPrint('NAVIGATE: MenuPage');
                  Navigator.of(context).pushReplacementNamed('/menu');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
