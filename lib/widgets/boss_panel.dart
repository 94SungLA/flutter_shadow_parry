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
    required this.playerSpriteState,
  });

  final bool isAttacking;
  final bool isPlayerDamaged;
  final bool showParryClash;
  final bool isBroken;
  final AttackType? currentAttackType;
  final PlayerSpriteState playerSpriteState;

  @override
  State<BossPanel> createState() => _BossPanelState();
}

enum PlayerSpriteState { idle, parry, dodge, hit, execute }

class _BossPanelState extends State<BossPanel> with TickerProviderStateMixin {
  static const String _imagePath = 'assets/images/';

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
      height: 340,
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
            top: 0,
            left: 36,
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
              child: Image.asset(
                _bossSprite,
                width: 242,
                height: 310,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
                errorBuilder: _buildMissingImage,
              ),
            ),
          ),
          if (widget.currentAttackType == AttackType.perilous)
            Positioned(
              top: 0,
              left: 134,
              child: Image.asset(
                '${_imagePath}danger_kanji.png',
                width: 64,
                height: 64,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
                errorBuilder: _buildMissingImage,
              ),
            ),
          if (widget.currentAttackType == AttackType.slash)
            Positioned(
              top: 92,
              left: 158,
              child: Image.asset(
                '${_imagePath}slash_effect.png',
                width: 188,
                height: 134,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
                errorBuilder: _buildMissingImage,
              ),
            ),
          Positioned(
            top: 142,
            left: 178,
            right: 44,
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
            right: 38,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _damageController,
              builder: (context, _) {
                final value = _damageController.value;
                final shakeOffset =
                    math.sin(value * math.pi * 6) * 8 * (1 - value);

                return Transform.translate(
                  offset: Offset(shakeOffset, 0),
                  child: Image.asset(
                    _playerSprite,
                    width: 176,
                    height: 206,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                    errorBuilder: _buildMissingImage,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String get _bossSprite {
    if (widget.isBroken) {
      return '${_imagePath}boss_stagger.png';
    }

    return switch (widget.currentAttackType) {
      AttackType.slash => '${_imagePath}boss_slash.png',
      AttackType.perilous => '${_imagePath}boss_perilous.png',
      null => '${_imagePath}boss_idle.png',
    };
  }

  String get _playerSprite {
    return switch (widget.playerSpriteState) {
      PlayerSpriteState.idle => '${_imagePath}player_idle.png',
      PlayerSpriteState.parry => '${_imagePath}player_parry.png',
      PlayerSpriteState.dodge => '${_imagePath}player_dodge.png',
      PlayerSpriteState.hit => '${_imagePath}player_hit.png',
      PlayerSpriteState.execute => '${_imagePath}player_execute.png',
    };
  }

  Widget _buildMissingImage(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return const SizedBox.shrink();
  }
}
