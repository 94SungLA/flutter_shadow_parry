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

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 18,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  colorScheme.error.withValues(alpha: 0.45),
                  colorScheme.outlineVariant.withValues(alpha: 0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 28,
          bottom: 0,
          child: _CharacterShadow(
            width: 220,
            color: colorScheme.error.withValues(alpha: 0.22),
          ),
        ),
        Positioned(
          right: 2,
          bottom: 0,
          child: _CharacterShadow(
            width: 160,
            color: Colors.black.withValues(alpha: 0.42),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.24),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 2,
          left: 0,
          child: AnimatedBuilder(
            animation: _attackController,
            builder: (context, child) {
              final attackValue = _attackController.value;

              return Transform.translate(
                offset: Offset(attackValue * 28, attackValue * 8),
                child: Transform.scale(
                  scale: 1 + attackValue * 0.08,
                  child: child,
                ),
              );
            },
            child: Image.asset(
              _bossSprite,
              width: 284,
              height: 374,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              errorBuilder: _buildMissingImage,
            ),
          ),
        ),
        if (widget.currentAttackType == AttackType.perilous)
          Positioned(
            top: 0,
            left: 120,
            child: Image.asset(
              '${_imagePath}danger_kanji.png',
              width: 112,
              height: 112,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              errorBuilder: _buildMissingImage,
            ),
          ),
        if (widget.currentAttackType == AttackType.slash)
          Positioned(
            left: 160,
            bottom: 116,
            child: Image.asset(
              '${_imagePath}slash_effect.png',
              width: 230,
              height: 164,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              errorBuilder: _buildMissingImage,
            ),
          ),
        Positioned(
          left: 168,
          right: 24,
          bottom: 170,
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
          right: -4,
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
                  width: 212,
                  height: 248,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                  errorBuilder: _buildMissingImage,
                ),
              );
            },
          ),
        ),
      ],
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

class _CharacterShadow extends StatelessWidget {
  const _CharacterShadow({required this.width, required this.color});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(999),
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
