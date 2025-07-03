import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/seller.dart' as seller_lib;

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
        'id, user_id, title, description, price, image_url, created_at, profiles!marketplace_user_id_fkey(full_name, avatar_url)',
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

Future<List<Product>> fetchProducts() async {
  try {
    final items = await getMarketplaceItemsWithSeller();

    // If no items from database, return dummy data for testing
    if (items.isEmpty) {
      return _getDummyProducts();
    }

    return items
        .map(
          (item) => Product(
            id: item['id'].toString(),
            title: item['title'] ?? '',
            imageUrl: item['image_url'] ?? '',
            price:
                (item['price'] is num)
                    ? (item['price'] as num).toDouble()
                    : 0.0,
            location: item['location'] ?? '',
            sellerId: item['user_id'] ?? '',
            sellerName: item['profiles']?['full_name'] ?? '',
            sellerAvatarUrl: item['profiles']?['avatar_url'] ?? '',
            postedAt:
                DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
            images: [],
            description: item['description'] ?? '',
            mapUrl: '',
            seller: seller_lib.Seller.empty(),
            timeAgo: '',
            isFree: false,
            relatedProducts: [],
            similarSellerAds: [],
          ),
        )
        .toList();
  } catch (e) {
    print('Error fetching products from database: $e');
    // Return dummy data if there's an error connecting to database
    return _getDummyProducts();
  }
}

List<Product> _getDummyProducts() {
  return [
    Product(
      id: '1',
      title: 'iPhone 14 Pro Max',
      imageUrl:
          'https://images.unsplash.com/photo-1592286002614-89b9cac12d66?w=400&h=400&fit=crop',
      price: 1200.0,
      location: 'New York, NY',
      sellerId: 'user1',
      sellerName: 'John Doe',
      sellerAvatarUrl:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
      postedAt: DateTime.now().subtract(const Duration(days: 1)),
      images: [],
      description:
          'Excellent condition iPhone 14 Pro Max, 256GB. Comes with original box and charger.',
      mapUrl: '',
      seller: seller_lib.Seller.empty(),
      timeAgo: '1 day ago',
      isFree: false,
      relatedProducts: [],
      similarSellerAds: [],
    ),
    Product(
      id: '2',
      title: 'MacBook Air M2',
      imageUrl:
          'https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?w=400&h=400&fit=crop',
      price: 999.0,
      location: 'San Francisco, CA',
      sellerId: 'user2',
      sellerName: 'Sarah Johnson',
      sellerAvatarUrl:
          'https://images.unsplash.com/photo-1494790108755-2616b332c882?w=100&h=100&fit=crop&crop=face',
      postedAt: DateTime.now().subtract(const Duration(days: 2)),
      images: [],
      description:
          'Like new MacBook Air with M2 chip. Perfect for students and professionals.',
      mapUrl: '',
      seller: seller_lib.Seller.empty(),
      timeAgo: '2 days ago',
      isFree: false,
      relatedProducts: [],
      similarSellerAds: [],
    ),
    Product(
      id: '3',
      title: 'Vintage Leather Jacket',
      imageUrl:
          'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=400&h=400&fit=crop',
      price: 85.0,
      location: 'Chicago, IL',
      sellerId: 'user3',
      sellerName: 'Mike Chen',
      sellerAvatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      postedAt: DateTime.now().subtract(const Duration(days: 3)),
      images: [],
      description:
          'Authentic vintage leather jacket from the 80s. Size Medium.',
      mapUrl: '',
      seller: seller_lib.Seller.empty(),
      timeAgo: '3 days ago',
      isFree: false,
      relatedProducts: [],
      similarSellerAds: [],
    ),
    Product(
      id: '4',
      title: 'Road Bike - Trek',
      imageUrl:
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=400&fit=crop',
      price: 450.0,
      location: 'Austin, TX',
      sellerId: 'user4',
      sellerName: 'Emily Rodriguez',
      sellerAvatarUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face',
      postedAt: DateTime.now().subtract(const Duration(days: 4)),
      images: [],
      description:
          'High-quality Trek road bike, perfect for commuting and weekend rides.',
      mapUrl: '',
      seller: seller_lib.Seller.empty(),
      timeAgo: '4 days ago',
      isFree: false,
      relatedProducts: [],
      similarSellerAds: [],
    ),
    Product(
      id: '5',
      title: 'Gaming Chair',
      imageUrl:
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=400&fit=crop',
      price: 200.0,
      location: 'Seattle, WA',
      sellerId: 'user5',
      sellerName: 'Alex Thompson',
      sellerAvatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop&crop=face',
      postedAt: DateTime.now().subtract(const Duration(days: 5)),
      images: [],
      description:
          'Ergonomic gaming chair with lumbar support. Great condition.',
      mapUrl: '',
      seller: seller_lib.Seller.empty(),
      timeAgo: '5 days ago',
      isFree: false,
      relatedProducts: [],
      similarSellerAds: [],
    ),
    Product(
      id: '6',
      title: 'Canon DSLR Camera',
      imageUrl:
          'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=400&h=400&fit=crop',
      price: 650.0,
      location: 'Miami, FL',
      sellerId: 'user6',
      sellerName: 'Lisa Park',
      sellerAvatarUrl:
          'https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?w=100&h=100&fit=crop&crop=face',
      postedAt: DateTime.now().subtract(const Duration(days: 6)),
      images: [],
      description:
          'Canon EOS DSLR camera with 18-55mm lens. Ideal for photography enthusiasts.',
      mapUrl: '',
      seller: seller_lib.Seller.empty(),
      timeAgo: '6 days ago',
      isFree: false,
      relatedProducts: [],
      similarSellerAds: [],
    ),
  ];
}

// To test: call each function and check the Supabase dashboard for changes.
