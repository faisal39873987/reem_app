import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
  final _controller = TextEditingController();
  final _uid = FirebaseAuth.instance.currentUser?.uid;
  late final DocumentReference _chatRef;
  late final CollectionReference _messagesRef;

  @override
  void initState() {
    super.initState();
    _chatRef = FirebaseFirestore.instance.collection('chats').doc(widget.chatId);
    _messagesRef = _chatRef.collection('messages');
    _setSeen();
  }

  void _setTyping(bool typing) {
    if (_uid == null) return;
    _chatRef.collection('typing').doc(_uid).set({'typing': typing});
  }

  void _setSeen() async {
    if (_uid == null) return;
    final snap = await _messagesRef.get();
    for (var doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final seen = (data['seenBy'] ?? []) as List;
      if (!seen.contains(_uid)) {
        await doc.reference.update({
          'seenBy': FieldValue.arrayUnion([_uid])
        });
      }
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (_uid == null || text.isEmpty) return;

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final chatSnap = await tx.get(_chatRef);

      final messageRef = _messagesRef.doc();
      tx.set(messageRef, {
        'text': text,
        'senderId': _uid,
        'senderName': FirebaseAuth.instance.currentUser?.displayName ?? 'User',
        'senderPhotoUrl': FirebaseAuth.instance.currentUser?.photoURL ?? '',
        'timestamp': Timestamp.now(),
        'seenBy': [_uid],
      });

      if (!chatSnap.exists) {
        tx.set(_chatRef, {
          'participants': [_uid, widget.receiverId],
          'lastMessage': text,
          'lastMessageTime': Timestamp.now(),
        });
      } else {
        tx.update(_chatRef, {
          'lastMessage': text,
          'lastMessageTime': Timestamp.now(),
        });
      }
    });

    _controller.clear();
    _setTyping(false);
  }

  @override
  Widget build(BuildContext context) {
    const blueColor = Color(0xFF1877F2);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: blueColor),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.receiverImage.isNotEmpty
                  ? NetworkImage(widget.receiverImage)
                  : null,
              child: widget.receiverImage.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _chatRef.collection('typing').doc(widget.receiverId).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Text(widget.receiverName,
                        style: const TextStyle(color: blueColor, fontWeight: FontWeight.bold));
                  }
                  final isTyping = snapshot.data!.get('typing') == true;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.receiverName,
                          style: const TextStyle(color: blueColor, fontWeight: FontWeight.bold)),
                      if (isTyping)
                        const Text("typing...",
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesRef.orderBy('timestamp', descending: false).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                if (messages.isEmpty) return const Center(child: Text('No messages yet.'));

                String? lastDate;

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == _uid;
                    final time = (data['timestamp'] as Timestamp?)?.toDate();
                    final timeString = time != null ? DateFormat('hh:mm a').format(time) : '';
                    final dateString = time != null ? DateFormat('yMMMMd').format(time) : '';

                    Widget? dateDivider;
                    if (lastDate != dateString && dateString.isNotEmpty) {
                      lastDate = dateString;
                      dateDivider = Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              dateString == DateFormat('yMMMMd').format(DateTime.now())
                                  ? 'Today'
                                  : dateString,
                              style: const TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                          ),
                        ),
                      );
                    }

                    final seenBy = List.from(data['seenBy'] ?? []);
                    final isSeen = seenBy.contains(widget.receiverId);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (dateDivider != null) dateDivider,
                        Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment:
                                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isMe)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 4),
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundImage: data['senderPhotoUrl'] != null &&
                                            data['senderPhotoUrl'].isNotEmpty
                                        ? NetworkImage(data['senderPhotoUrl'])
                                        : null,
                                    child: data['senderPhotoUrl'] == null ||
                                            data['senderPhotoUrl'].isEmpty
                                        ? const Icon(Icons.person, size: 20)
                                        : null,
                                  ),
                                ),
                              Flexible(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isMe ? Colors.blue[100] : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (!isMe && data['senderName'] != null)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Text(
                                            data['senderName'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      Text(
                                        data['text'] ?? '',
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                      if (timeString.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                timeString,
                                                style: const TextStyle(
                                                    fontSize: 11, color: Colors.black45),
                                              ),
                                              if (isMe && isSeen) ...[
                                                const SizedBox(width: 6),
                                                const Icon(Icons.done_all,
                                                    size: 14, color: Colors.blue),
                                              ],
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // 📝 حقل الكتابة
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (text) => _setTyping(text.isNotEmpty),
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: blueColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
