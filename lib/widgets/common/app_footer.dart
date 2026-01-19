// lib/widgets/common/app_footer.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_360/core/theme/app_theme2.dart';
import 'package:real_estate_360/providers/auth_provider.dart'; // Make sure this is imported
import 'package:real_estate_360/widgets/auth/login_modal.dart';
import 'package:real_estate_360/data/models/user_model.dart';

class AppFooter extends ConsumerWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine the selected index from the current route
    final String location = GoRouterState.of(context).uri.toString();
    int selectedIndex = 0;
    if (location.startsWith('/home')) {
      selectedIndex = 0;
    } else if (location.startsWith('/settings')) {
      selectedIndex = 1;
    } else if (location.startsWith('/favorites')) {
      selectedIndex = 2;
    } else if (location.startsWith('/other')) {
      selectedIndex = 3;
    }

    // This function shows the login modal
    void _showLoginModal(String redirectTo) {
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) => LoginModal(redirectTo: redirectTo),
      );
    }

    // This function now checks the CORRECT provider
    void _handleActionRequiringLogin(String destinationPath) {
      final User? currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        print('User is logged in. Navigating to $destinationPath');
        context.go(destinationPath);
      } else {
        print('User is not logged in. Showing login modal.');
        _showLoginModal(destinationPath);
      }
    }

    // This is called when a bottom nav item is tapped
    void _onItemTapped(int index) {
      String destinationPath;
      switch (index) {
        case 0:
          destinationPath = '/home';
          break;
        case 1:
          destinationPath = '/settings';
          break;
        case 2:
          destinationPath = '/favorites';
          break;
        case 3:
          destinationPath = '/other';
          break;
        default:
          destinationPath = '/home';
      }
      // Call our handler that checks for login
      _handleActionRequiringLogin(destinationPath);
    }

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppTheme.lightColor,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: AppTheme.darkColor.withOpacity(0.6),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      elevation: 8,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          label: 'Other',
        ),
      ],
      currentIndex: selectedIndex,
      onTap: _onItemTapped,
    );
  }
}