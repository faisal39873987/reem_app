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
      body: const Center(
        child: Text(
          "Chats will be available soon after Supabase integration.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
