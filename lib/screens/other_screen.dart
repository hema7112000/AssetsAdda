// lib/screens/other_screen.dart

import 'package:flutter/material.dart';
import 'package:real_estate_360/widgets/common/app_scaffold.dart';
import 'package:real_estate_360/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Add this import

class OtherScreen extends ConsumerWidget { // Change from StatelessWidget to ConsumerWidget
  const OtherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Now this signature is correct
    final authNotifier = ref.read(authProvider.notifier);

    return AppScaffold(
      title: 'Other',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'More Options',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Favorites'),
              subtitle: const Text('View your favorite properties'),
              onTap: () {
                // TODO: Navigate to favorites
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              subtitle: const Text('View your search history'),
              onTap: () {
                // TODO: Navigate to history
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Saved Searches'),
              subtitle: const Text('Manage your saved searches'),
              onTap: () {
                // TODO: Navigate to saved searches
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share App'),
              subtitle: const Text('Share with friends and family'),
              onTap: () {
                // TODO: Implement share functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.rate_review),
              title: const Text('Rate Us'),
              subtitle: const Text('Rate our app on the store'),
              onTap: () {
                // TODO: Open store for rating
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              subtitle: const Text('App version and information'),
              onTap: () {
                // TODO: Show about dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sign Out'),
              subtitle: const Text('Sign out of your account'),
              onTap: () {
                authNotifier.logout();
                context.go('/');
              },
            ),
          ],
        ),
      ),
    );
  }
}