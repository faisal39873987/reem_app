import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post.dart';

class FeedService {
  final _client = Supabase.instance.client;

  // Fetch all posts (unified for feed/marketplace)
  Future<List<Post>> fetchPosts() async {
    final postsRes = await _client
        .from('posts')
        .select()
        .order('created_at', ascending: false);
    print('FEED_SERVICE: Raw posts response: ' + postsRes.toString());
    final marketplaceRes = await _client
        .from('marketplace')
        .select()
        .order('created_at', ascending: false);
    print('FEED_SERVICE: Raw marketplace response: ' + marketplaceRes.toString());
    final posts = (postsRes as List).map((e) => Post.fromMap(e['id'] ?? '', e)).toList();
    final marketplace = (marketplaceRes as List).map((e) => Post.fromMap(e['id'] ?? '', e)).toList();
    return [...posts, ...marketplace];
  }

  // Real-time stream (optional, for future use)
  Stream<List<Post>> postsStream() {
    return _client
        .from('posts')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((data) => List<Map<String, dynamic>>.from(data))
        .map(
          (list) => list.map((e) => Post.fromMap(e['id'] ?? '', e)).toList(),
        );
  }
}
