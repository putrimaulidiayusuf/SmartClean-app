import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vibeco_app/core/constants/app_colors.dart';

/// Custom animated widget that simulates a Lottie-style AI processing animation
class AiProcessingAnimation extends StatefulWidget {
  final double size;
  final String? label;

  const AiProcessingAnimation({
    super.key,
    this.size = 200,
    this.label,
  });

  @override
  State<AiProcessingAnimation> createState() => _AiProcessingAnimationState();
}

class _AiProcessingAnimationState extends State<AiProcessingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _rotationController,
              _pulseController,
              _particleController,
            ]),
            builder: (context, _) {
              return CustomPaint(
                painter: _AiProcessingPainter(
                  rotation: _rotationController.value,
                  pulse: _pulseController.value,
                  particle: _particleController.value,
                ),
              );
            },
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Opacity(
                opacity: 0.5 + (_pulseController.value * 0.5),
                child: child,
              );
            },
            child: Text(
              widget.label!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AiProcessingPainter extends CustomPainter {
  final double rotation;
  final double pulse;
  final double particle;

  _AiProcessingPainter({
    required this.rotation,
    required this.pulse,
    required this.particle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Outer pulsing ring
    final outerPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.15 + pulse * 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, maxRadius * (0.85 + pulse * 0.1), outerPaint);

    // Rotating arcs
    for (int i = 0; i < 3; i++) {
      final arcPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.3 + (i * 0.15))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      final arcRadius = maxRadius * (0.55 + i * 0.12);
      final startAngle = rotation * 2 * pi + (i * pi / 3);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: arcRadius),
        startAngle,
        pi * 0.8,
        false,
        arcPaint,
      );
    }

    // Center brain icon circle
    final centerPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary,
          AppColors.accent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 0.3));
    canvas.drawCircle(center, maxRadius * (0.25 + pulse * 0.05), centerPaint);

    // AI text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'AI',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    // Floating particles
    for (int i = 0; i < 8; i++) {
      final angle = (particle + i / 8) * 2 * pi;
      final radius = maxRadius * 0.7;
      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius;
      final particlePaint = Paint()
        ..color = AppColors.accent.withValues(alpha: 0.4 + sin(angle) * 0.3);
      canvas.drawCircle(Offset(x, y), 3 + sin(angle + particle * 2 * pi), particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AiProcessingPainter oldDelegate) => true;
}
