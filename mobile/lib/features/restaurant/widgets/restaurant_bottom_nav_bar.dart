import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routing/app_routes.dart';

class RestaurantBottomNavBar extends StatelessWidget {
  const RestaurantBottomNavBar({
    super.key,
    this.navigationShell,
    this.currentIndex,
    this.onTap,
  });

  final StatefulNavigationShell? navigationShell;
  final int? currentIndex;
  final ValueChanged<int>? onTap;

  static const Color primaryColor = Color(0xFF0F5A27);

  @override
  Widget build(BuildContext context) {
    final activeIndex = currentIndex ?? navigationShell?.currentIndex ?? 0;

    return BottomNavigationBar(
      currentIndex: activeIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey[600],
      showUnselectedLabels: true,
      onTap: (index) {
        if (onTap != null) {
          onTap!(index);
        } else if (navigationShell != null) {
          navigationShell!.goBranch(
            index,
            initialLocation: index == navigationShell!.currentIndex,
          );
        } else {
          switch (index) {
            case 0:
              context.go(AppRoutes.restaurantHome);
              break;
            case 1:
              context.go(AppRoutes.restaurantSearch);
              break;
            case 2:
              context.go(AppRoutes.restaurantCart);
              break;
            case 3:
              context.go(AppRoutes.restaurantChat);
              break;
            case 4:
              context.go(AppRoutes.restaurantProfile);
              break;
          }
        }
      },
      items: List.generate(5, (index) {
        final bool selected = activeIndex == index;

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
