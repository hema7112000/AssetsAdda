// lib/widgets/theme_toggle.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme/app_theme2.dart'; // Add this import

class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return IconButton(
      icon: Icon(
        themeMode == AppThemeMode.dark 
            ? Icons.light_mode 
            : Icons.dark_mode,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onPressed: () {
        ref.read(themeProvider.notifier).toggleTheme();
      },
    );
  }
}