import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PostDetailsScreen extends StatefulWidget {
  final String postId;
  const PostDetailsScreen({super.key, required this.postId});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // All Firebase usage has been removed. Supabase is now used for all backend operations.
  }

  @override
  Widget build(BuildContext context) {
    const blue = kPrimaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Details", style: TextStyle(color: blue)),
        iconTheme: const IconThemeData(color: blue),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: Center(child: Text("Post details will be shown here.")),
    );
  }
}
