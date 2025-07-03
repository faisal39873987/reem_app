import 'package:flutter/material.dart';

class FeedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FeedAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      toolbarHeight: 48,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'ReemVerse',
            style: const TextStyle(
              color: Color(0xFF1877F2),
              fontWeight: FontWeight.w900,
              fontSize: 28,
              fontFamily: 'SF Pro',
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          _FbAppBarIcon(
            icon: Icons.add,
            onTap: () => Navigator.of(context).pushNamed('/post'),
          ),
          _FbAppBarIcon(
            icon: Icons.search,
            onTap: () => Navigator.of(context).pushNamed('/search'),
          ),
          _FbAppBarIcon(
            icon: Icons.messenger_outline,
            onTap: () => Navigator.of(context).pushNamed('/messages'),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _FbAppBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _FbAppBarIcon({required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.black87, size: 26),
      splashRadius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      onPressed: onTap,
      tooltip: '',
    );
  }
}
