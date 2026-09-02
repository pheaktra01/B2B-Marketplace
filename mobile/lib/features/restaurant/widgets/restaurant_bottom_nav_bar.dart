import 'package:flutter/material.dart';
import 'package:mobile/features/chat/screens/chat_list_screen.dart';
import 'package:mobile/features/restaurant/screens/home_screen.dart';
import 'package:mobile/features/cart/screens/cart_screen.dart';
import 'package:mobile/features/restaurant/screens/search_market_screen.dart';
import 'package:mobile/features/restaurant/screens/user_profile_screen.dart';

class RestaurantBottomNavBar extends StatelessWidget {
  const RestaurantBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  static const Color primaryColor = Color(0xFF0F5A27);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey[600],
      showUnselectedLabels: true,

      onTap: (index) {
        if (index == currentIndex) return;

        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              ),
            );
            break;

          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SearchMarketScreen()),
            );
            break;

          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
            break;

          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ChatListScreen()),
            );
            break;

          case 4:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserProfileScreen()),
            );
            break;
        }
      },

      items: List.generate(5, (index) {
        final bool selected = currentIndex == index;

        return BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
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