import 'package:flutter/material.dart';
import '../models/seller.dart';

class SellerInfoRow extends StatelessWidget {
  final Seller seller;
  const SellerInfoRow({super.key, required this.seller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(seller.avatarUrl),
            radius: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  seller.info,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          // زر المتابعة/سويف تمت إزالته بناءً على طلب العميل
        ],
      ),
    );
  }
}
