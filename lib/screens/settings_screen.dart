// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:real_estate_360/widgets/common/app_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Settings',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Account'),
              subtitle: const Text('Manage your account settings'),
              onTap: () {
                // TODO: Navigate to account settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              subtitle: const Text('Configure notification preferences'),
              onTap: () {
                // TODO: Navigate to notification settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy'),
              subtitle: const Text('Privacy and security settings'),
              onTap: () {
                // TODO: Navigate to privacy settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              subtitle: const Text('Get help with the app'),
              onTap: () {
                // TODO: Navigate to help & support
              },
            ),
          ],
        ),
      ),
    );
  }
}