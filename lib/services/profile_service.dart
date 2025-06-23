import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

/// Get current user's profile
Future<Map<String, dynamic>?> getCurrentUserProfile() async {
  final user = supabase.auth.currentUser;
  if (user == null) return null;
  final res =
      await supabase.from('profiles').select().eq('id', user.id).maybeSingle();
  return res;
}

/// Update current user's profile
Future<void> updateProfile({
  String? fullName,
  String? avatarUrl,
  String? bio,
  String? phone,
}) async {
  final user = supabase.auth.currentUser;
  if (user == null) throw Exception('Not authenticated');
  await supabase
      .from('profiles')
      .update({
        if (fullName != null) 'full_name': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (bio != null) 'bio': bio,
        if (phone != null) 'phone': phone,
      })
      .eq('id', user.id);
}

// To test: call getCurrentUserProfile and updateProfile, check Supabase dashboard for changes.
