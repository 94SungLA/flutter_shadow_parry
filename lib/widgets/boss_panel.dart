import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/attack_type.dart';

class BossPanel extends StatefulWidget {
  const BossPanel({
    super.key,
    required this.isAttacking,
    required this.isPlayerDamaged,
    required this.showParryClash,
    required this.isBroken,
    required this.currentAttackType,
  });

  final bool isAttacking;
  final bool isPlayerDamaged;
  final bool showParryClash;
  final bool isBroken;
  final AttackType? currentAttackType;

  @override
  State<BossPanel> createState() => _BossPanelState();
}

class _BossPanelState extends State<BossPanel> with TickerProviderStateMixin {
  late final AnimationController _attackController;
  late final AnimationController _damageController;
  late final AnimationController _clashController;

  @override
  void initState() {
    super.initState();
    _attackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      reverseDuration: const Duration(milliseconds: 120),
    );
    _damageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..value = 1;
    _clashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..value = 1;
  }

  @override
  void didUpdateWidget(covariant BossPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isAttacking && !oldWidget.isAttacking) {
      _attackController.forward(from: 0).then((_) {
        if (mounted) {
          _attackController.reverse();
        }
      });
    }

    if (widget.isPlayerDamaged && !oldWidget.isPlayerDamaged) {
      _damageController.forward(from: 0);
    }

    if (widget.showParryClash && !oldWidget.showParryClash) {
      _clashController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _attackController.dispose();
    _damageController.dispose();
    _clashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            left: 18,
            child: AnimatedBuilder(
              animation: _attackController,
              builder: (context, child) {
                final attackValue = _attackController.value;

                return Transform.translate(
                  offset: Offset(attackValue * 22, attackValue * 8),
                  child: Transform.scale(
                    scale: 1 + attackValue * 0.08,
                    child: child,
                  ),
                );
              },
              child: SizedBox(
                width: 170,
                height: 238,
                child: CustomPaint(
                  painter: _BossSilhouettePainter(
                    colorScheme: colorScheme,
                    isBroken: widget.isBroken,
                  ),
                ),
              ),
            ),
          ),
          if (widget.currentAttackType == AttackType.perilous)
            Positioned(
              top: 2,
              left: 82,
              child: Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  border: Border.all(color: colorScheme.onError, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '危',
                  style: textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onError,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (widget.currentAttackType == AttackType.slash)
            Positioned(
              top: 98,
              left: 118,
              child: CustomPaint(
                size: const Size(138, 96),
                painter: _SlashEffectPainter(color: colorScheme.secondary),
              ),
            ),
          Positioned(
            top: 118,
            left: 130,
            right: 92,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _clashController,
                builder: (context, _) {
                  final value = _clashController.value;

                  return Opacity(
                    opacity: (1 - value).clamp(0, 1),
                    child: Transform.scale(
                      scale: 0.9 + value * 0.35,
                      child: Text(
                        '鏘！',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium?.copyWith(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(color: colorScheme.shadow, blurRadius: 8),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            right: 24,
            bottom: 10,
            child: AnimatedBuilder(
              animation: _damageController,
              builder: (context, _) {
                final value = _damageController.value;
                final damageOpacity = (1 - value).clamp(0, 1).toDouble();
                final shakeOffset =
                    math.sin(value * math.pi * 6) * 8 * (1 - value);

                return Transform.translate(
                  offset: Offset(shakeOffset, 0),
                  child: SizedBox(
                    width: 112,
                    height: 138,
                    child: CustomPaint(
                      painter: _PlayerSilhouettePainter(
                        colorScheme: colorScheme,
                        damageOpacity: damageOpacity,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BossSilhouettePainter extends CustomPainter {
  const _BossSilhouettePainter({
    required this.colorScheme,
    required this.isBroken,
  });

  final ColorScheme colorScheme;
  final bool isBroken;

  @override
  void paint(Canvas canvas, Size size) {
    final blackPaint = Paint()..color = const Color(0xFF08070A);
    final redPaint = Paint()..color = const Color(0xFF8B1025);
    final armorPaint = Paint()..color = const Color(0xFF1A1015);

    final drop = isBroken ? size.height * 0.16 : 0.0;
    final lean = isBroken ? -size.width * 0.08 : 0.0;
    final centerX = size.width * 0.48 + lean;
    final groundY = size.height * 0.94;

    final helmet = Path()
      ..moveTo(centerX - 30, size.height * 0.16 + drop)
      ..lineTo(centerX - 10, size.height * 0.06 + drop)
      ..lineTo(centerX + 26, size.height * 0.12 + drop)
      ..lineTo(centerX + 38, size.height * 0.25 + drop)
      ..lineTo(centerX + 16, size.height * 0.31 + drop)
      ..lineTo(centerX - 28, size.height * 0.28 + drop)
      ..close();
    canvas.drawPath(helmet, blackPaint);

    canvas.drawCircle(
      Offset(centerX - 6, size.height * 0.25 + drop),
      19,
      blackPaint,
    );

    final torso = Path()
      ..moveTo(centerX - 42, size.height * 0.34 + drop)
      ..lineTo(centerX + 38, size.height * 0.33 + drop)
      ..lineTo(centerX + 55, size.height * 0.62 + drop)
      ..lineTo(centerX + 24, size.height * 0.78 + drop)
      ..lineTo(centerX - 34, size.height * 0.78 + drop)
      ..lineTo(centerX - 58, size.height * 0.60 + drop)
      ..close();
    canvas.drawPath(torso, armorPaint);

    final chestMark = Path()
      ..moveTo(centerX - 8, size.height * 0.38 + drop)
      ..lineTo(centerX + 22, size.height * 0.45 + drop)
      ..lineTo(centerX + 6, size.height * 0.71 + drop)
      ..lineTo(centerX - 16, size.height * 0.50 + drop)
      ..close();
    canvas.drawPath(chestMark, redPaint);

    final leftArm = Path()
      ..moveTo(centerX - 42, size.height * 0.39 + drop)
      ..lineTo(centerX - 76, size.height * 0.50 + drop)
      ..lineTo(centerX - 66, size.height * 0.70 + drop)
      ..lineTo(centerX - 32, size.height * 0.56 + drop)
      ..close();
    canvas.drawPath(leftArm, blackPaint);

    final rightArm = Path()
      ..moveTo(centerX + 34, size.height * 0.39 + drop)
      ..lineTo(centerX + 78, size.height * 0.46 + drop)
      ..lineTo(centerX + 68, size.height * 0.66 + drop)
      ..lineTo(centerX + 36, size.height * 0.56 + drop)
      ..close();
    canvas.drawPath(rightArm, blackPaint);

    final legLeft = Path()
      ..moveTo(centerX - 28, size.height * 0.75 + drop)
      ..lineTo(centerX - 58, groundY)
      ..lineTo(centerX - 22, groundY)
      ..lineTo(centerX - 2, size.height * 0.75 + drop)
      ..close();
    final legRight = Path()
      ..moveTo(centerX + 20, size.height * 0.75 + drop)
      ..lineTo(centerX + 42, groundY)
      ..lineTo(centerX + 78, groundY)
      ..lineTo(centerX + 34, size.height * 0.75 + drop)
      ..close();
    canvas.drawPath(legLeft, blackPaint);
    canvas.drawPath(legRight, blackPaint);

    final swordPaint = Paint()
      ..color = colorScheme.outline
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centerX + 58, size.height * 0.42 + drop),
      Offset(centerX + 98, size.height * 0.02 + drop),
      swordPaint,
    );

    if (isBroken) {
      final brokenPaint = Paint()
        ..color = colorScheme.error
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(centerX - 44, size.height * 0.15 + drop),
        Offset(centerX + 40, size.height * 0.25 + drop),
        brokenPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BossSilhouettePainter oldDelegate) {
    return oldDelegate.colorScheme != colorScheme ||
        oldDelegate.isBroken != isBroken;
  }
}

class _PlayerSilhouettePainter extends CustomPainter {
  const _PlayerSilhouettePainter({
    required this.colorScheme,
    required this.damageOpacity,
  });

  final ColorScheme colorScheme;
  final double damageOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final bodyColor = Color.lerp(
      const Color(0xFF111116),
      colorScheme.error,
      damageOpacity,
    )!;
    final bodyPaint = Paint()..color = bodyColor;
    final bladePaint = Paint()
      ..color = colorScheme.outline
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final accentPaint = Paint()..color = colorScheme.primary;

    final centerX = size.width * 0.48;
    final groundY = size.height * 0.94;

    canvas.drawCircle(Offset(centerX, size.height * 0.22), 13, bodyPaint);

    final torso = Path()
      ..moveTo(centerX - 18, size.height * 0.34)
      ..lineTo(centerX + 18, size.height * 0.32)
      ..lineTo(centerX + 26, size.height * 0.62)
      ..lineTo(centerX - 18, size.height * 0.64)
      ..close();
    canvas.drawPath(torso, bodyPaint);

    canvas.drawRect(
      Rect.fromLTWH(centerX - 18, size.height * 0.45, 34, 7),
      accentPaint,
    );

    final backLeg = Path()
      ..moveTo(centerX - 10, size.height * 0.60)
      ..lineTo(centerX - 36, groundY)
      ..lineTo(centerX - 16, groundY)
      ..lineTo(centerX + 5, size.height * 0.62)
      ..close();
    final frontLeg = Path()
      ..moveTo(centerX + 12, size.height * 0.60)
      ..lineTo(centerX + 44, groundY)
      ..lineTo(centerX + 22, groundY)
      ..lineTo(centerX - 2, size.height * 0.62)
      ..close();
    canvas.drawPath(backLeg, bodyPaint);
    canvas.drawPath(frontLeg, bodyPaint);

    canvas.drawLine(
      Offset(centerX + 18, size.height * 0.43),
      Offset(centerX - 58, size.height * 0.18),
      bladePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PlayerSilhouettePainter oldDelegate) {
    return oldDelegate.colorScheme != colorScheme ||
        oldDelegate.damageOpacity != damageOpacity;
  }
}

class _SlashEffectPainter extends CustomPainter {
  const _SlashEffectPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    final corePaint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.88),
      Offset(size.width * 0.92, size.height * 0.12),
      glowPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.12, size.height * 0.82),
      Offset(size.width * 0.88, size.height * 0.18),
      corePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SlashEffectPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
