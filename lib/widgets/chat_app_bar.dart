import 'package:flutter/material.dart';
import '../models/seller.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Seller seller;
  const ChatAppBar({super.key, required this.seller});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: BackButton(color: Colors.black),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(seller.avatarUrl),
            radius: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              seller.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 18,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onPressed: () {},
        ),
      ],
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
