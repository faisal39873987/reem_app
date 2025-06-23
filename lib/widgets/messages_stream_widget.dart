import 'package:flutter/material.dart';
import '../services/messages_service.dart';
import '../models/message.dart';

/// Widget to display all messages for the current user in real-time
/// Handles all states: loading, error, empty, data
class MessagesStreamWidget extends StatelessWidget {
  const MessagesStreamWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: userMessagesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading messages: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        final messages = snapshot.data;
        if (messages == null || messages.isEmpty) {
          return const Center(child: Text('No messages yet'));
        }
        return ListView.separated(
          itemCount: messages.length,
          separatorBuilder: (context, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final msg = messages[i];
            return ListTile(
              title: Text(msg.content),
              subtitle: Text(
                'From: ${msg.senderId}  To: ${msg.receiverId}',
              ),
              trailing:
                  msg.isRead == true
                      ? const Icon(Icons.done_all, color: Colors.blue, size: 18)
                      : const Icon(Icons.done, color: Colors.grey, size: 18),
            );
          },
        );
      },
    );
  }
}
