import 'package:flutter/material.dart';
import '../models/product.dart';

class FbMarketplaceProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  const FbMarketplaceProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageUrl.isNotEmpty ? product.imageUrl : null;
    final price = product.price.toStringAsFixed(2);
    final location = product.location ?? '';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                child:
                    imageUrl != null
                        ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          cacheHeight: 300,
                          cacheWidth: 300,
                          errorBuilder:
                              (context, error, stackTrace) => _placeholder(),
                          loadingBuilder:
                              (context, child, progress) =>
                                  progress == null ? child : _placeholder(),
                        )
                        : _placeholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                        fontFamily: 'SFPro',
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$price AED',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'SFPro',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 13,
                    color: Color(0xFFB0B3B8),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFB0B3B8),
                        fontFamily: 'SFPro',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF0F2F5),
      child: const Center(
        child: Icon(Icons.image, color: Color(0xFFB0B3B8), size: 40),
      ),
    );
  }
}
