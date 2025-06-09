import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid == null || (user?.isAnonymous ?? true)) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: kPrimaryColor),
          title: const Text('Chats', style: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          )),
        ),
        backgroundColor: Colors.white,
        body: const Center(
          child: Text("Please log in to view your chats."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: kPrimaryColor),
        title: const Text('My Chats', style: TextStyle(
          color: kPrimaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        )),
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: uid)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return const Center(child: Text('No chats found.'));
          }

          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final chat = chats[index];
              final data = chat.data() as Map<String, dynamic>;
              final participants = data['participants'];
              if (participants is! List) return const SizedBox.shrink();
              final users = List<String>.from(participants);
              if (!users.contains(uid)) return const SizedBox.shrink();
              final otherUserId = users.firstWhere((id) => id != uid, orElse: () => uid!);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData || userSnapshot.data == null) {
                    return const SizedBox.shrink();
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                  final displayName = userData['name'] ?? 'User';
                  final photoUrl = userData['photoUrl'] ?? '';
                  final lastMessage = data['lastMessage'] ?? '';
                  final timestamp = (data['lastMessageTime'] as Timestamp?)?.toDate();
                  final timeText = timestamp != null
                      ? TimeOfDay.fromDateTime(timestamp).format(context)
                      : '';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      child: photoUrl.isEmpty ? const Icon(Icons.person) : null,
                    ),
                    title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(timeText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: chat.id,
                            receiverId: otherUserId,
                            receiverName: displayName,
                            receiverImage: photoUrl,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
