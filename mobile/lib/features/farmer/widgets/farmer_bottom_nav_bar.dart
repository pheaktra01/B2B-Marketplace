import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

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
          MaterialPageRoute(
            builder: (_) => screen,
          ),
        );
      },

      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.storefront_outlined),
          activeIcon: const Icon(Icons.storefront),
          label: l10n.dashboard,
        ),

        BottomNavigationBarItem(
          icon: const Icon(Icons.assignment_outlined),
          activeIcon: const Icon(Icons.assignment),
          label: l10n.orders,
        ),

        BottomNavigationBarItem(
          icon: const Icon(Icons.inventory_2_outlined),
          activeIcon: const Icon(Icons.inventory_2),
          label: l10n.inventory,
        ),

        BottomNavigationBarItem(
          icon: const Icon(Icons.chat_bubble_outline),
          activeIcon: const Icon(Icons.chat_bubble),
          label: l10n.chat,
        ),

        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: l10n.profile,
        ),
      ],
    );
  }
}