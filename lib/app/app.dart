import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_estate_360/core/theme/app_theme2.dart';
import 'package:real_estate_360/router/app_router.dart';
import '../providers/theme_provider.dart'; 
import 'package:real_estate_360/providers/auth_provider.dart';
import 'package:real_estate_360/data/models/user_model.dart'; // <-- ADD THIS IMPORT

import 'package:real_estate_360/scaffold_messenger.dart';

// app/app.dart (alternative approach)

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeProvider);
    final authInitializer = ref.watch(initializeAuthProvider);
    final isAuthInitialized = ref.watch(isAuthInitializedProvider);
    final currentUser = ref.watch(currentUserFromServiceProvider);
    
    // Update the currentUserProvider when the user changes in the service
    ref.listen<User?>(currentUserFromServiceProvider, (previous, next) {
      ref.read(currentUserProvider.notifier).state = next;
    });
    
    // ONE base text theme — reused everywhere
    final baseTextTheme =
        GoogleFonts.poppinsTextTheme(Typography.material2021().englishLike);

    return authInitializer.when(
      data: (_) {
        return MaterialApp.router(
          title: 'Assets Adda',
          scaffoldMessengerKey: scaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          themeMode:
              themeMode == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light,
          theme: AppTheme.theme.copyWith(
            textTheme: baseTextTheme,
          ),
          darkTheme: AppTheme.theme.copyWith(
            textTheme: baseTextTheme,
          ),
          routerConfig: router,
        );
      },
      loading: () => MaterialApp(
        title: 'Assets Adda',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading...'),
              ],
            ),
          ),
        ),
      ),
      error: (error, stack) => MaterialApp(
        title: 'Assets Adda',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Error initializing app: $error',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Retry initialization
                        ref.refresh(initializeAuthProvider);
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}