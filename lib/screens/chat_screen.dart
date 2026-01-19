// lib/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:real_estate_360/widgets/common/app_scaffold.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Chat',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Messages',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: NetworkImage('https://picsum.photos/seed/user1/50/50.jpg'),
                    ),
                    title: const Text('John Doe'),
                    subtitle: const Text('Hey, are you available?'),
                    trailing: const Text('2:30 PM'),
                    onTap: () {
                      // TODO: Open chat with John Doe
                    },
                  ),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: NetworkImage('https://picsum.photos/seed/user2/50/50.jpg'),
                    ),
                    title: const Text('Jane Smith'),
                    subtitle: const Text('Thanks for the information!'),
                    trailing: const Text('1:15 PM'),
                    onTap: () {
                      // TODO: Open chat with Jane Smith
                    },
                  ),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: NetworkImage('https://picsum.photos/seed/user3/50/50.jpg'),
                    ),
                    title: const Text('Mike Johnson'),
                    subtitle: const Text('Can we schedule a viewing?'),
                    trailing: const Text('Yesterday'),
                    onTap: () {
                      // TODO: Open chat with Mike Johnson
                    },
                  ),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: NetworkImage('https://picsum.photos/seed/user4/50/50.jpg'),
                    ),
                    title: const Text('Sarah Williams'),
                    subtitle: const Text('I have a few questions about the property'),
                    trailing: const Text('Yesterday'),
                    onTap: () {
                      // TODO: Open chat with Sarah Williams
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Start a new chat
        },
        child: const Icon(Icons.message),
      ),
    );
  }
}