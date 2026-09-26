import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Soft, non-interactive artwork behind the youth experience.
///
/// Decoration is intentionally low-contrast so content stays easy to read,
/// while the tinted canvas gives white cards clear separation.
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
      color: AppColors.background,
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
      ..color = AppColors.primary.withValues(alpha: .055)
      ..style = PaintingStyle.fill;

    final primaryFainter = Paint()
      ..color = AppColors.primary.withValues(alpha: .028)
      ..style = PaintingStyle.fill;

    final secondarySoft = Paint()
      ..color = AppColors.secondary.withValues(alpha: .045)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: .065)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    if (includeTopAccent) {
      canvas.drawCircle(
        Offset(size.width * .93, -26),
        size.width * .31,
        primarySoft,
      );

      canvas.drawCircle(
        Offset(-34, size.height * .28),
        size.width * .24,
        secondarySoft,
      );
    }

    canvas.drawCircle(
      Offset(size.width * .84, size.height * .67),
      size.width * .20,
      primaryFainter,
    );

    canvas.drawCircle(
      Offset(size.width * .12, size.height * .88),
      size.width * .15,
      secondarySoft,
    );

    final topArc = Rect.fromCenter(
      center: Offset(size.width * .92, size.height * .34),
      width: size.width * .42,
      height: size.width * .42,
    );
    canvas.drawArc(topArc, .75, 3.7, false, linePaint);

    final bottomArc = Rect.fromCenter(
      center: Offset(size.width * .06, size.height * .72),
      width: size.width * .32,
      height: size.width * .32,
    );
    canvas.drawArc(bottomArc, 4.1, 2.5, false, linePaint);

    final dotPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: .085)
      ..style = PaintingStyle.fill;

    const spacing = 17.0;
    for (var row = 0; row < 4; row++) {
      for (var column = 0; column < 5; column++) {
        canvas.drawCircle(
          Offset(
            20 + (column * spacing),
            size.height * .53 + (row * spacing),
          ),
          1.55,
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
