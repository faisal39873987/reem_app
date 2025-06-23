import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

/// Add marketplace item
Future<void> addMarketplaceItem({
  required String title,
  required String description,
  required double price,
  required String imageUrl,
}) async {
  final user = supabase.auth.currentUser;
  if (user == null) throw Exception('Not authenticated');
  await supabase.from('marketplace').insert({
    'user_id': user.id,
    'title': title,
    'description': description,
    'price': price,
    'image_url': imageUrl,
    'created_at': DateTime.now().toIso8601String(),
  });
}

/// Get all marketplace items with seller profile
Future<List<Map<String, dynamic>>> getMarketplaceItemsWithSeller() async {
  final res = await supabase
      .from('marketplace')
      .select(
        'id, user_id, title, description, price, image_url, created_at, profiles!inner(full_name, avatar_url)',
      )
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(res);
}

/// Update item
Future<void> updateMarketplaceItem(String id, Map<String, dynamic> data) async {
  await supabase.from('marketplace').update(data).eq('id', id);
}

/// Delete item
Future<void> deleteMarketplaceItem(String id) async {
  await supabase.from('marketplace').delete().eq('id', id);
}

// To test: call each function and check the Supabase dashboard for changes.
