import 'package:flutter/material.dart';

class DottedBorder extends StatelessWidget {
  final double strokeWidth;
  final Color color;
  final Widget child;

  DottedBorder({
    required this.strokeWidth,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DottedBorderPainter(strokeWidth: strokeWidth, color: color),
      child: child,
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final Paint _paint;

  DottedBorderPainter({required this.strokeWidth, required this.color})
      : _paint = Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    final double dashLength = 5;
    final double gapLength = 5;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawPath(
        Path()
          ..moveTo(startX, 0)
          ..lineTo(startX + dashLength, 0),
        _paint,
      );
      startX += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(DottedBorderPainter oldPainter) {
    return oldPainter.strokeWidth != strokeWidth || oldPainter.color != color;
  }
}
