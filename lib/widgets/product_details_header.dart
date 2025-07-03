import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailsHeader extends StatelessWidget {
  final Product product;
  const ProductDetailsHeader({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                product.isFree
                    ? 'مجاني'
                    : '${product.price.toStringAsFixed(0)} د.إ.',
                style: TextStyle(
                  color:
                      product.isFree ? Colors.green : const Color(0xFF1877F2),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.location_on, color: Color(0xFF1877F2), size: 18),
              Text(
                product.location,
                style: const TextStyle(
                  color: Color(0xFF1877F2),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                product.timeAgo,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
