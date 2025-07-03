import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String receiverId;
  final String receiverName;
  final String receiverImage;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // TODO: Use Supabase real-time stream for messages
  // TODO: Modularize message bubble, input, and reactions
  // TODO: Add permissions for chat (block/report/admin)
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('BUILD: ChatScreen');
    const blueColor = kPrimaryColor;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: blueColor),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  widget.receiverImage.isNotEmpty
                      ? NetworkImage(widget.receiverImage)
                      : null,
              child:
                  widget.receiverImage.isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.receiverName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Center(
              // TODO: Replace with real-time message list
              child: Text(
                "Chats will be available soon after Supabase integration.",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          // TODO: Modular message input with media, emoji, reactions
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: blueColor),
                  onPressed: () {
                    // TODO: Send message logic
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
