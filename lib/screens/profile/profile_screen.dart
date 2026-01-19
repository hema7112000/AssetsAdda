import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_360/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final authNotifier = ref.read(authProvider.notifier);

    if (user == null) {
      // This should ideally not happen due to router redirect, but as a safeguard:
      return const Scaffold(body: Center(child: Text('User not found. Please log in.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?', style: const TextStyle(fontSize: 30, color: Colors.white)),
                ),
                
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                          user.fullName.isNotEmpty ? user.fullName : 'No Name',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          user.name.toUpperCase(),
                          style: const TextStyle(color: Colors.blueGrey),
                        ),
                                            ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            if (user.isVerified)
              const ListTile(
                leading: Icon(Icons.verified_user, color: Colors.green),
                title: Text('Verified User'),
                subtitle: Text('Your identity has been verified.'),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  authNotifier.logout();
                  context.go('/');
                  // The router will automatically redirect to login screen
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}