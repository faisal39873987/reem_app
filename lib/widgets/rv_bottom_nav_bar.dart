import 'package:flutter/material.dart';
import '../screens/post_creation_screen.dart';
import '../screens/marketplace_add_screen.dart';

class RVBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const RVBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavBarItem(
        icon: Icons.home,
        label: 'Home',
        active: currentIndex == 0,
        onTap: () {
          if (currentIndex != 0) {
            Navigator.of(context).pushReplacementNamed('/landing');
          }
        },
      ),
      _NavBarItem(
        icon: Icons.storefront,
        label: 'Marketplace',
        active: currentIndex == 1,
        onTap: () {
          if (currentIndex != 1) {
            Navigator.of(context).pushReplacementNamed('/marketplace');
          }
        },
      ),
      _NavBarItem(
        icon: Icons.add_circle,
        label: 'Create',
        active: currentIndex == 2,
        onTap: () {
          Widget page;
          if (currentIndex == 0) {
            // إذا كان في اللاندينج بيج (Home)
            page = const PostCreationScreen();
          } else if (currentIndex == 1) {
            // إذا كان في الماركت بليس
            page = const MarketplaceAddScreen();
          } else {
            page = const PostCreationScreen();
          }
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => page,
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
        },
      ),
      _NavBarItem(
        icon: Icons.chat_bubble_outline,
        label: 'Messages',
        active: currentIndex == 3,
        onTap: () {
          if (currentIndex != 3) {
            Navigator.of(context).pushReplacementNamed('/messages');
          }
        },
      ),
      _NavBarItem(
        icon: Icons.person,
        label: 'Profile',
        active: currentIndex == 4,
        onTap: () {
          if (currentIndex != 4) {
            Navigator.of(context).pushReplacementNamed('/profile');
          }
        },
      ),
    ];
    return Container(
      height: 62,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE1E8ED), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) => Expanded(child: items[i])),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF1877F2) : Colors.grey[600];

    // Special design for add button
    if (icon == Icons.add_circle) {
      return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF1877F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: active ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                  fontFamily: 'SF Pro',
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Default design for other icons
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
                fontFamily: 'SF Pro',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
