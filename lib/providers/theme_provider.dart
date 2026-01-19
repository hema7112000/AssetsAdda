// lib/providers/theme_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_estate_360/core/theme/app_theme2.dart'; // Updated import


final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.dark);

  void toggleTheme() {
    state = state == AppThemeMode.dark ? AppThemeMode.light : AppThemeMode.dark;
    AppTheme.currentMode = state;
  }

  void setTheme(AppThemeMode mode) {
    state = mode;
    AppTheme.currentMode = mode;
  }
}