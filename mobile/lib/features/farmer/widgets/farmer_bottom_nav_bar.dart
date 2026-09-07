import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';

class FarmerBottomNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const FarmerBottomNavBar({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      currentIndex: navigationShell.currentIndex,
      selectedItemColor: const Color(0xFF1E1E1E),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
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