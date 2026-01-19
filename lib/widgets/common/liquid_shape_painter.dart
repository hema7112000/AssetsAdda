// lib/widgets/common/liquid_shape_painter.dart
import 'package:flutter/material.dart';

class BlobPainter extends CustomPainter {
  final Paint _paint;
  final Gradient? _gradient;

  // Private constructor for solid colors
  BlobPainter._({required Color color})
      : _paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill,
        _gradient = null;

  // Private constructor for gradients
  BlobPainter._gradient({required Gradient gradient})
      : _paint = Paint()
          ..style = PaintingStyle.fill,
        _gradient = gradient;

  // Factory to create a solid color painter
  factory BlobPainter.solid({required Color color}) {
    return BlobPainter._(color: color);
  }

  // Factory to create a gradient painter
  factory BlobPainter.gradient({required Gradient gradient}) {
    return BlobPainter._gradient(gradient: gradient);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_gradient != null) {
      _paint.shader = _gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    }

    final path = Path();

    // A more complex, 8-point path for a more organic blob
    final w = size.width;
    final h = size.height;

    path.moveTo(w * 0.2, h * 0.3);
    path.cubicTo(w * 0.05, h * 0.2, w * 0.1, h * 0.5, w * 0.2, h * 0.7);
    path.cubicTo(w * 0.15, h * 0.9, w * 0.4, h * 0.95, w * 0.6, h * 0.8);
    path.cubicTo(w * 0.8, h * 0.9, w * 0.95, h * 0.7, w * 0.9, h * 0.5);
    path.cubicTo(w * 0.95, h * 0.3, w * 0.8, h * 0.1, w * 0.6, h * 0.2);
    path.cubicTo(w * 0.4, h * 0.05, w * 0.2, h * 0.1, w * 0.2, h * 0.3);

    path.close();

    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! BlobPainter ||
        oldDelegate._gradient != _gradient ||
        oldDelegate._paint.color != _paint.color;
  }
}
// Custom painter for liquid shape effect
class LiquidShapePainter extends CustomPainter {
  final Color color;
  final double progress;
  
  LiquidShapePainter({
    required this.color,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    // Create a liquid shape path
    final double waveHeight = size.height * 0.3 * progress;
    final double waveWidth = size.width * 0.2 * progress;
    
    path.moveTo(0, size.height);
    
    // First wave
    path.quadraticBezierTo(
      waveWidth, 
      size.height - waveHeight, 
      waveWidth * 2, 
      size.height
    );
    
    // Second wave
    path.quadraticBezierTo(
      waveWidth * 3, 
      size.height - waveHeight * 0.7, 
      waveWidth * 4, 
      size.height
    );
    
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(LiquidShapePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}