import 'package:flutter/material.dart';

class ProductMapSection extends StatelessWidget {
  final String city;
  final String mapUrl;
  const ProductMapSection({
    super.key,
    required this.city,
    required this.mapUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF1877F2), size: 18),
              const SizedBox(width: 4),
              Text(
                city,
                style: const TextStyle(
                  color: Color(0xFF1877F2),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              mapUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (c, e, s) => Container(
                    height: 120,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.map,
                        color: Color(0xFF1877F2),
                        size: 40,
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
