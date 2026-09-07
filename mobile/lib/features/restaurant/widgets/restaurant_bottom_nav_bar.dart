import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RestaurantBottomNavBar extends StatelessWidget {
  const RestaurantBottomNavBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static const Color primaryColor = Color(0xFF0F5A27);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: navigationShell.currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey[600],
      showUnselectedLabels: true,
      onTap: (index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      items: List.generate(5, (index) {
        final bool selected = navigationShell.currentIndex == index;

        return BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: selected
                  ? primaryColor.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(_icons[index]),
          ),
          label: _labels[index],
        );
      }),
    );
  }

  static const List<IconData> _icons = [
    Icons.home,
    Icons.search,
    Icons.shopping_bag_outlined,
    Icons.chat_bubble_outline,
    Icons.person_outline,
  ];

  static const List<String> _labels = [
    'Home',
    'Search',
    'Orders',
    'Chat',
    'Profile',
  ];
}
