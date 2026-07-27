import 'package:flutter/material.dart';
import 'package:mobile/features/farmer/screens/chat_list_screen.dart';
import 'package:mobile/features/farmer/screens/farmer_dashboard_screen.dart';
import 'package:mobile/features/farmer/screens/farmer_order_management_screen.dart';
import 'package:mobile/features/farmer/screens/farmer_profile_screen.dart';
import 'package:mobile/features/farmer/screens/inventory_screen.dart';

class FarmerBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const FarmerBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF1E1E1E),
      unselectedItemColor: Colors.grey,

      onTap: (index) {
        if (index == currentIndex) return;

        Widget screen;

        switch (index) {
          case 0:
            screen = const FarmerDashboardScreen();
            break;
          case 1:
            screen = const FarmerOrderManagementScreen();
            break;
          case 2:
            screen = const InventoryScreen();
            break;
          case 3:
            screen = const ChatListScreen();
            break;
          case 4:
            screen = const FarmerProfileScreen();
            break;
          default:
            return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.storefront_outlined),
          activeIcon: Icon(Icons.storefront),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          activeIcon: Icon(Icons.chat_bubble),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Account',
        ),
      ],
    );
  }
}