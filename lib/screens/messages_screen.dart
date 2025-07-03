import 'package:flutter/material.dart';
import '../widgets/messages_stream_widget.dart';
import '../widgets/rv_bottom_nav_bar.dart';

/// Production-ready screen to display all messages for the current user
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // debugPrint('BUILD: MessagesScreen');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1877F2)),
          onPressed:
              () => Navigator.of(context).pushReplacementNamed('/landing'),
        ),
        titleTextStyle: const TextStyle(
          color: Color(0xFF1877F2),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: const MessagesStreamWidget(),
      bottomNavigationBar: const RVBottomNavBar(currentIndex: 3),
    );
  }
}
