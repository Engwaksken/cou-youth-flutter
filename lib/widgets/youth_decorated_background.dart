import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// A subtle, non-interactive background used across the youth experience.
///
/// The decoration intentionally stays very light so text and controls always
/// retain strong contrast. It also contains no animation, so it is safe for
/// users who prefer reduced motion.
class YouthDecoratedBackground extends StatelessWidget {
  const YouthDecoratedBackground({
    super.key,
    required this.child,
    this.includeTopAccent = true,
  });

  final Widget child;
  final bool includeTopAccent;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceSoft,
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: CustomPaint(
              painter: _YouthBackgroundPainter(
                includeTopAccent: includeTopAccent,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _YouthBackgroundPainter extends CustomPainter {
  const _YouthBackgroundPainter({required this.includeTopAccent});

  final bool includeTopAccent;

  @override
  void paint(Canvas canvas, Size size) {
    final primarySoft = Paint()
      ..color = AppColors.primary.withValues(alpha: .045)
      ..style = PaintingStyle.fill;

    final secondarySoft = Paint()
      ..color = AppColors.secondary.withValues(alpha: .035)
      ..style = PaintingStyle.fill;

    final outline = Paint()
      ..color = AppColors.primary.withValues(alpha: .055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    if (includeTopAccent) {
      canvas.drawCircle(
        Offset(size.width * .90, -20),
        size.width * .34,
        primarySoft,
      );
      canvas.drawCircle(
        Offset(-20, size.height * .24),
        size.width * .22,
        secondarySoft,
      );
    }

    canvas.drawCircle(
      Offset(size.width * .82, size.height * .68),
      size.width * .18,
      primarySoft,
    );

    canvas.drawCircle(
      Offset(size.width * .16, size.height * .91),
      size.width * .12,
      secondarySoft,
    );

    final arcRect = Rect.fromCenter(
      center: Offset(size.width * .92, size.height * .40),
      width: size.width * .34,
      height: size.width * .34,
    );
    canvas.drawArc(arcRect, .8, 3.9, false, outline);

    final dotPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: .07)
      ..style = PaintingStyle.fill;

    const spacing = 18.0;
    for (var row = 0; row < 4; row++) {
      for (var column = 0; column < 5; column++) {
        canvas.drawCircle(
          Offset(
            22 + (column * spacing),
            size.height * .56 + (row * spacing),
          ),
          1.7,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _YouthBackgroundPainter oldDelegate) {
    return oldDelegate.includeTopAccent != includeTopAccent;
  }
}
