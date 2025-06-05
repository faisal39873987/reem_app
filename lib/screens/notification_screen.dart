import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null && !user!.isAnonymous) {
      _markAllAsRead();
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user!.uid)
          .where('read', isEqualTo: false)
          .get();

      for (final doc in query.docs) {
        doc.reference.update({'read': true});
      }
    } catch (e) {
      debugPrint("Error marking notifications as read: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null || user!.isAnonymous) {
      return const Scaffold(
        body: Center(
          child: Text("🔒 Please log in to view notifications."),
        ),
      );
    }

    const blue = Color(0xFF1877F2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(color: blue)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: blue),
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user!.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final notifications = snapshot.data!.docs;

          if (notifications.isEmpty) {
            return const Center(child: Text("No notifications yet."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const Divider(),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final data = notifications[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Notification';
              final body = data['body'] ?? '';
              final time = (data['timestamp'] as Timestamp?)?.toDate();
              final timeText = time != null ? DateFormat.yMMMd().add_jm().format(time) : '';

              return ListTile(
                leading: const Icon(Icons.notifications, color: blue),
                title: Text(title),
                subtitle: Text(body),
                trailing: Text(timeText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              );
            },
          );
        },
      ),
    );
  }
}
