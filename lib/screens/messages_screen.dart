import 'package:flutter/material.dart';
import '../widgets/messages_stream_widget.dart';

/// Production-ready screen to display all messages for the current user
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // debugPrint('BUILD: MessagesScreen');
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: const MessagesStreamWidget(),
    );
  }
}
