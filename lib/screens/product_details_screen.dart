import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_image_carousel.dart';
import '../widgets/product_details_header.dart';
import '../widgets/seller_info_row.dart';
import '../widgets/messenger_bar.dart';
import '../widgets/product_action_row.dart';
import '../widgets/product_description_section.dart';
import '../widgets/product_map_section.dart';
import '../widgets/related_products_section.dart';
import '../widgets/similar_seller_ads_section.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ProductDetailsAppBar(),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ProductImageCarousel(images: product.images),
          ProductDetailsHeader(product: product),
          SellerInfoRow(seller: product.seller),
          MessengerBar(seller: product.seller),
          ProductActionRow(product: product),
          ProductDescriptionSection(description: product.description),
          ProductMapSection(city: product.location, mapUrl: product.mapUrl),
          RelatedProductsSection(related: product.relatedProducts),
          SimilarSellerAdsSection(similar: product.similarSellerAds),
        ],
      ),
    );
  }
}

class ProductDetailsAppBar extends StatelessWidget {
  const ProductDetailsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.black, size: 28),
        onPressed: () => Navigator.of(context).pop(),
        splashRadius: 24,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black, size: 26),
          onPressed: () {},
          splashRadius: 24,
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.black, size: 26),
          onPressed: () {},
          splashRadius: 24,
        ),
        const SizedBox(width: 8),
      ],
      automaticallyImplyLeading: false,
      titleSpacing: 0,
    );
  }
}
