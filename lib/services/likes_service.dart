import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

/// Service to handle post likes functionality
class LikesService {
  /// Toggle like/unlike for a post
  static Future<bool> togglePostLike(String postId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Check if user already liked this post
      final existingLike =
          await supabase
              .from('post_likes')
              .select()
              .eq('post_id', postId)
              .eq('user_id', user.id)
              .maybeSingle();

      if (existingLike != null) {
        // Unlike: remove the like
        await supabase
            .from('post_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', user.id);
        return false; // No longer liked
      } else {
        // Like: add the like
        await supabase.from('post_likes').insert({
          'post_id': postId,
          'user_id': user.id,
          'created_at': DateTime.now().toIso8601String(),
        });
        return true; // Now liked
      }
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  /// Get like count for a post
  static Future<int> getPostLikeCount(String postId) async {
    try {
      final result = await supabase
          .from('post_likes')
          .select()
          .eq('post_id', postId);
      return result.length;
    } catch (e) {
      return 0;
    }
  }

  /// Check if current user liked a post
  static Future<bool> isPostLikedByUser(String postId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;

    try {
      final result =
          await supabase
              .from('post_likes')
              .select()
              .eq('post_id', postId)
              .eq('user_id', user.id)
              .maybeSingle();
      return result != null;
    } catch (e) {
      return false;
    }
  }
}
