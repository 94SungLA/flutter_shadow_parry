import 'package:flutter/material.dart';

class InkBackground extends StatelessWidget {
  const InkBackground({
    super.key,
    required this.child,
    this.isDefeat = false,
    this.imageAsset,
  });

  final Widget child;
  final bool isDefeat;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    final baseTop = isDefeat
        ? const Color(0xFF070508)
        : const Color(0xFF10090D);
    final baseBottom = isDefeat
        ? const Color(0xFF030304)
        : const Color(0xFF1A080D);

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [baseTop, const Color(0xFF0A080A), baseBottom],
              ),
            ),
          ),
        ),
        if (imageAsset != null)
          Positioned.fill(
            child: Image.asset(
              imageAsset!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
          ),
        if (imageAsset != null)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: isDefeat ? 0.62 : 0.48),
            ),
          ),
        Positioned(
          top: -120,
          right: -90,
          child: _MistOrb(
            size: 260,
            color: const Color(0xFF7C1024).withValues(alpha: 0.22),
          ),
        ),
        Positioned(
          left: -120,
          bottom: 70,
          child: _MistOrb(
            size: 300,
            color: const Color(0xFFB33B54).withValues(alpha: 0.12),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(painter: _InkPainter(isDefeat: isDefeat)),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _MistOrb extends StatelessWidget {
  const _MistOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

class _InkPainter extends CustomPainter {
  const _InkPainter({required this.isDefeat});

  final bool isDefeat;

  @override
  void paint(Canvas canvas, Size size) {
    final mistPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDefeat ? 0.035 : 0.055)
      ..strokeWidth = 1;
    final redPaint = Paint()
      ..color = const Color(0xFFD4495C).withValues(alpha: isDefeat ? 0.14 : 0.2)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 7; i++) {
      final y = size.height * (0.18 + i * 0.09);
      canvas.drawLine(
        Offset(size.width * -0.1, y),
        Offset(size.width * 1.1, y + 20),
        mistPaint,
      );
    }

    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.28),
      Offset(size.width * 0.45, size.height * 0.08),
      redPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.72, size.height * 0.16),
      Offset(size.width * 0.92, size.height * 0.34),
      redPaint,
    );

    final groundPaint = Paint()
      ..color = const Color(0xFFC43A4D).withValues(alpha: 0.16)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(0, size.height * 0.72),
      Offset(size.width, size.height * 0.69),
      groundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _InkPainter oldDelegate) {
    return oldDelegate.isDefeat != isDefeat;
  }
}
