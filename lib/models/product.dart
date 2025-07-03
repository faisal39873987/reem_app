// Product model for Marketplace

import 'seller.dart';

class Product {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final String location;
  final String sellerId;
  final String sellerName;
  final String sellerAvatarUrl;
  final DateTime postedAt;
  final List<String> images;
  final String description;
  final String mapUrl;
  final Seller seller;
  final String timeAgo;
  final bool isFree;
  final List<Product> relatedProducts;
  final List<Product> similarSellerAds;

  Product({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.location,
    required this.sellerId,
    required this.sellerName,
    required this.sellerAvatarUrl,
    required this.postedAt,
    required this.images,
    required this.description,
    required this.mapUrl,
    required this.seller,
    required this.timeAgo,
    required this.isFree,
    required this.relatedProducts,
    required this.similarSellerAds,
  });
}
