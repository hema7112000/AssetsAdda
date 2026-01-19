// lib/widgets/common/main_scaffold.dart
import 'package:flutter/material.dart';
import 'package:real_estate_360/core/theme/app_theme.dart';
import 'package:real_estate_360/widgets/common/liquid_shape_painter.dart'; // Make sure this imports the new BlobPainter

class MainScaffold extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  const MainScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          // --- Background Layer 1: Farthest back, subtle ---
          Positioned(
            top: -150,
            left: -100,
            child: BlobPainter.solid(
              color: AppTheme.primaryColor.withOpacity(0.08),
            ).buildWidget(350, 350),
          ),

          // --- Background Layer 2: Right side, medium depth ---
          Positioned(
            bottom: -180,
            right: -120,
            child: BlobPainter.gradient(
              gradient: RadialGradient(
                colors: [
                  AppTheme.secondaryColor.withOpacity(0.2),
                  AppTheme.secondaryColor.withOpacity(0.05),
                ],
              ),
            ).buildWidget(400, 400),
          ),

          // --- Background Layer 3: Top-left, closer ---
          Positioned(
            top: -50,
            left: -50,
            child: BlobPainter.solid(
              color: AppTheme.secondaryColor.withOpacity(0.15),
            ).buildWidget(200, 200),
          ),
          
          // --- Background Layer 4: Bottom-right, accent ---
          Positioned(
            bottom: 50,
            right: -100,
            child: BlobPainter.solid(
              color: Colors.purpleAccent.withOpacity(0.1), // Using an accent color
            ).buildWidget(250, 250),
          ),

          // --- Main Content ---
          body,
        ],
      ),
    );
  }
}

// Extension to make creating the widget cleaner
extension on CustomPainter {
  Widget buildWidget(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: this),
    );
  }
}