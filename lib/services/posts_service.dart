import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

/// Add post
Future<void> addPost({
  required String title,
  required String content,
  required String imageUrl,
}) async {
  final user = supabase.auth.currentUser;
  if (user == null) throw Exception('Not authenticated');
  await supabase.from('posts').insert({
    'user_id': user.id,
    'title': title,
    'content': content,
    'image_url': imageUrl,
    'created_at': DateTime.now().toIso8601String(),
  });
}

/// Get all posts (real-time)
Stream<List<Map<String, dynamic>>> postsStream() {
  return supabase
      .from('posts')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .map((data) => List<Map<String, dynamic>>.from(data));
}

/// Update post
Future<void> updatePost(String id, Map<String, dynamic> data) async {
  await supabase.from('posts').update(data).eq('id', id);
}

/// Delete post
Future<void> deletePost(String id) async {
  await supabase.from('posts').delete().eq('id', id);
}

// To test: call addPost, updatePost, deletePost, and listen to postsStream for real-time updates.
