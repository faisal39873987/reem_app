import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/marketplace_service.dart';
import '../utils/constants.dart';
import '../widgets/rv_bottom_nav_bar.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 24) / 2;
    final height = width + 62;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            child: Row(
              children: [
                Text(
                  'Marketplace',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.black, size: 28),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/profile');
                  },
                  tooltip: 'Profile',
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.black, size: 28),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/search');
                  },
                  tooltip: 'Search',
                ),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Product>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading products'));
          }
          final products = snapshot.data ?? [];
          return GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: width / height,
            ),
            itemCount: products.length,
            itemBuilder: (context, i) {
              final p = products[i];
              return _FbMarketplaceProductCardFB(
                product: p,
                width: width,
                height: height,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/marketplace-details',
                    arguments: {'productId': p.id},
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: const RVBottomNavBar(currentIndex: 1),
      floatingActionButton: null,
    );
  }
}

// Facebook-style product card for Marketplace
class _FbMarketplaceProductCardFB extends StatelessWidget {
  final Product product;
  final double width;
  final double height;
  final VoidCallback? onTap;
  const _FbMarketplaceProductCardFB({
    required this.product,
    required this.width,
    required this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
<<<<<<< HEAD
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
=======
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PostDetailsScreen(postId: post.id.toString()),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        color: Colors.white,
>>>>>>> 7376d04ed9157adca11b4d81bfec7683e877da79
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
<<<<<<< HEAD
              child: SizedBox(
                width: width,
                height: width,
                child:
                    product.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: Colors.grey.shade200,
                                child: Center(
                                  child: Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                    size: width * 0.4,
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey.shade200,
                                child: Center(
                                  child: Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                    size: width * 0.4,
                                  ),
                                ),
                              ),
                        )
                        : Container(
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: width * 0.4,
                            ),
=======
              child: Image.network(
                imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      height: 140,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.broken_image)),
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.storefront,
                        color: kPrimaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: kPrimaryColor,
>>>>>>> 7376d04ed9157adca11b4d81bfec7683e877da79
                          ),
                        ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 0, right: 4),
                    child: Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 0),
                  child: Text(
                    '${product.price.toStringAsFixed(2)} AED',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey, size: 12),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      product.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
<<<<<<< HEAD
                    ),
=======
                      const SizedBox(width: 2),
                      Text(
                        price.isNotEmpty ? '$price درهم' : '',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
>>>>>>> 7376d04ed9157adca11b4d81bfec7683e877da79
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Remove global _fbPlaceholder and trailing bracket
