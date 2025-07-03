import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius borderRadius;
  final int count;
  const SkeletonLoader({
    super.key,
    this.height = 20,
    this.width = double.infinity,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.count = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          count,
          (i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: borderRadius,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
