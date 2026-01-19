// // lib/widgets/common/app_scaffold.dart
// import 'package:flutter/material.dart';
// import 'package:real_estate_360/core/theme/app_theme2.dart';
// import 'package:real_estate_360/widgets/common/app_footer.dart';

// class AppScaffold extends StatelessWidget {
//   final String title;
//   final List<Widget>? actions;
//   final Widget? floatingActionButton;
//   final bool? showBackButton;
//   final Widget body;
//   final Widget? drawer;
//   final bool showBottomNav;

//   const AppScaffold({
//     Key? key,
//     required this.title,
//     this.actions,
//     this.floatingActionButton,
//     required this.body,
//     this.showBackButton = true,
//     this.showBottomNav = true,
//     this.drawer,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           title,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         automaticallyImplyLeading: showBackButton!,
//         backgroundColor: AppTheme.primaryColor,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: actions,
//       ),
//       backgroundColor: AppTheme.lightColor,
//       body: body,
//       bottomNavigationBar: showBottomNav ? const AppFooter() : null,
//       floatingActionButton: floatingActionButton,
//       drawer: drawer,
//     );
//   }
// }

// lib/widgets/common/app_scaffold.dart - WITH GLASS EFFECTS
import 'package:flutter/material.dart';
import 'package:real_estate_360/widgets/common/app_footer.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool? showBackButton;
  final Widget body;
  final Widget? drawer;
  final bool showBottomNav;

  const AppScaffold({
    Key? key,
    required this.title,
    this.actions,
    this.floatingActionButton,
    required this.body,
    this.showBackButton = true,
    this.showBottomNav = true,
    this.drawer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface, // Use Flutter's theme system
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: showBackButton!,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withOpacity(0.6),
                colorScheme.secondary.withOpacity(0.6),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
        ),
        actions: actions,
      ),
      backgroundColor: colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.background.withOpacity(0.95),
              colorScheme.background.withOpacity(0.98),
            ],
          ),
        ),
        child: body,
      ),
      bottomNavigationBar: showBottomNav 
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.background.withOpacity(0.8),
                    colorScheme.background.withOpacity(0.95),
                  ],
                ),
                border: Border(
                  top: BorderSide(
                    color: colorScheme.primary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: const AppFooter(),
            )
          : null,
      floatingActionButton: floatingActionButton,
      drawer: drawer,
    );
  }
}