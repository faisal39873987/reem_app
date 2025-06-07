// lib/screens/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_list_screen.dart';
import 'search_screen.dart';
import 'post_creation_screen.dart';
import 'landing_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    if (uid != null) {
      _listenUnreadCount();
      _markAllAsRead();
    }
  }

  void _listenUnreadCount() {
    FirebaseFirestore.instance
        .collection('notifications')
        .doc(uid)
        .collection('list')
        .where('read', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        unreadCount = snapshot.docs.length;
      });
    });
  }

  Future<void> _markAllAsRead() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .doc(uid)
        .collection('list')
        .where('read', isEqualTo: false)
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.update({'read': true});
    }
  }

  Future<void> _refreshNotifications() async {
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications refreshed.')),
    );
  }

  void _navigateTo(int index) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => LandingScreen(initialIndex: index),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const blueColor = Color(0xFF1877F2);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.isAnonymous) {
      Future.microtask(() {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: const BackButton(color: blueColor),
        title: Row(
          children: [
            const Text("Notifications", style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: blueColor,
            )),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                "Mark all as read",
                style: TextStyle(color: blueColor),
              ),
            ),
        ],
      ),
      backgroundColor: Colors.white,
      extendBody: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshNotifications,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .doc(uid)
                    .collection('list')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No notifications yet."));
                  }
                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      return ListTile(
                        leading: Icon(
                          Icons.notifications,
                          color: data['read'] == false ? blueColor : Colors.grey,
                        ),
                        title: Text(data['title'] ?? ''),
                        subtitle: Text(data['subtitle'] ?? ''),
                      );
                    },
                  );
                },
              ),
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
                onPressed: () => _navigateTo(0),
              ),
              IconButton(
                icon: const Icon(Icons.store, color: blueColor),
                onPressed: () => _navigateTo(1),
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: const Icon(Icons.person, color: blueColor),
                onPressed: () => _navigateTo(2),
              ),
              IconButton(
                icon: const Icon(Icons.menu, color: blueColor),
                onPressed: () => _navigateTo(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
