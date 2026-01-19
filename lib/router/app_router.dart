// lib/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_360/data/models/user_model.dart';
import 'package:real_estate_360/providers/auth_provider.dart'; // Contains authProvider and currentUserProvider
import 'package:real_estate_360/screens/auth/login_screen.dart';
import 'package:real_estate_360/screens/auth/signup_screen.dart';
import 'package:real_estate_360/screens/buyer/home_screen.dart';
import 'package:real_estate_360/screens/buyer/property_detail_screen.dart';
import 'package:real_estate_360/screens/profile/profile_screen.dart';
import 'package:real_estate_360/screens/seller/seller_dashboard_screen.dart';
import 'package:real_estate_360/screens/seller/add_property_screen.dart';
import 'package:real_estate_360/screens/seller/edit_property_screen.dart';
import 'package:real_estate_360/screens/seller/location_picker_screen.dart';
import 'package:real_estate_360/screens/chat_screen.dart';
import 'package:real_estate_360/screens/other_screen.dart';
import 'package:real_estate_360/screens/settings_screen.dart';
import 'package:real_estate_360/screens/main_home_screen.dart';
import 'package:real_estate_360/screens/favorites_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final currentUser = ref.read(currentUserProvider);

      if (authState.isLoading) return null;

      final isLoggedIn = currentUser != null;
      final currentPath = state.uri.path;

      const publicRoutes = {'/', '/login', '/signup'};
      final isPublicRoute = publicRoutes.contains(currentPath) ||
          currentPath.startsWith('/property/');

      if (!isLoggedIn && !isPublicRoute) {
        return '/login?redirectTo=${state.uri.toString()}';
      }

      if (isLoggedIn && (currentPath == '/login' || currentPath == '/signup')) {
        return currentUser!.role == UserRole.ROLE_SELLER
            ? '/seller-dashboard'
            : '/home';
      }

      return null;
    },

    routes: [
      // Main home screen (public)
      GoRoute(
        path: '/',
        builder: (context, state) => const MainHomeScreen(),
      ),
      
      // Authentication routes
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final redirectTo = state.uri.queryParameters['redirectTo'];
          return LoginScreen(redirectTo: redirectTo);
        },
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
       GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      
      // Property detail (public)
      GoRoute(
        path: '/property/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PropertyDetailScreen(propertyId: id);
        },
      ),
      
      // Protected routes (require login)
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/seller-dashboard',
        builder: (context, state) => const SellerDashboardScreen(),
      ),
      
      // Seller routes
      GoRoute(
        path: '/seller',
        builder: (context, state) => const SellerDashboardScreen(),
        routes: [
          GoRoute(
            path: 'add-property',
            builder: (context, state) => const AddPropertyScreen(),
            routes: [
              GoRoute(
                path: 'location',
                builder: (context, state) => const LocationPickerScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'edit-property/:propertyId',
            builder: (context, state) => EditPropertyScreen(propertyId: state.pathParameters['propertyId']!),
          ),
        ],
      ),
      
      // Other protected routes
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/other',
        builder: (context, state) => const OtherScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri.path}')),
    ),
  );
  ref.listen(authProvider, (_, __) => router.refresh());
  ref.listen(currentUserProvider, (_, __) => router.refresh());

  return router;
});