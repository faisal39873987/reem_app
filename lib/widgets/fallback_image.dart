import 'package:flutter/material.dart';

class FallbackImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BoxFit fit;
  final Widget? fallback;
  const FallbackImage({
    super.key,
    required this.imageUrl,
    this.height = 120,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      height: height,
      width: width,
      fit: fit,
      errorBuilder:
          (context, error, stackTrace) =>
              fallback ??
              Container(
                height: height,
                width: width,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                ),
              ),
    );
  }
}
