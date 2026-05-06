import 'dart:math' as math;

import 'package:flutter/material.dart';

class BossPanel extends StatefulWidget {
  const BossPanel({
    super.key,
    required this.isAttacking,
    required this.isPlayerDamaged,
    required this.showParryClash,
    required this.isBroken,
  });

  final bool isAttacking;
  final bool isPlayerDamaged;
  final bool showParryClash;
  final bool isBroken;

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

    return Column(
      children: [
        AnimatedBuilder(
          animation: _attackController,
          builder: (context, child) {
            final attackValue = _attackController.value;

            return Transform.translate(
              offset: Offset(0, attackValue * 12),
              child: Transform.scale(
                scale: 1 + attackValue * 0.08,
                child: child,
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 144,
            height: 144,
            decoration: BoxDecoration(
              color: widget.isBroken
                  ? colorScheme.errorContainer
                  : colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: widget.isBroken
                    ? colorScheme.error
                    : colorScheme.outline,
                width: widget.isBroken ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.isBroken
                      ? Icons.flash_off
                      : Icons.warning_amber_rounded,
                  size: 52,
                  color: widget.isBroken
                      ? colorScheme.onErrorContainer
                      : colorScheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.isBroken ? '破防' : 'Shadow Boss',
                  style: textTheme.titleMedium?.copyWith(
                    color: widget.isBroken
                        ? colorScheme.onErrorContainer
                        : null,
                    fontWeight: widget.isBroken ? FontWeight.bold : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: Center(
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
                      style: textTheme.headlineMedium?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _damageController,
          builder: (context, child) {
            final value = _damageController.value;
            final shakeOffset = math.sin(value * math.pi * 6) * 8 * (1 - value);

            return Transform.translate(
              offset: Offset(shakeOffset, 0),
              child: child,
            );
          },
          child: AnimatedBuilder(
            animation: _damageController,
            builder: (context, _) {
              final damageValue = _damageController.value;
              final damageOpacity = (1 - damageValue).clamp(0, 1).toDouble();

              return Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Color.lerp(
                    colorScheme.surfaceContainer,
                    colorScheme.errorContainer,
                    damageOpacity,
                  ),
                  border: Border.all(
                    color:
                        Color.lerp(
                          colorScheme.outlineVariant,
                          colorScheme.error,
                          damageOpacity,
                        ) ??
                        colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 36,
                      color: Color.lerp(
                        colorScheme.primary,
                        colorScheme.error,
                        damageOpacity,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Player',
                      style: textTheme.labelLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
