import 'dart:async';

import 'package:flutter/material.dart';

import '../game/battle_controller.dart';
import '../game/battle_state.dart';
import '../models/attack_type.dart';
import '../services/audio_service.dart';
import '../widgets/boss_panel.dart';
import '../widgets/game_button.dart';
import '../widgets/ink_background.dart';
import '../widgets/player_action_panel.dart';
import '../widgets/posture_bar.dart';
import '../widgets/stat_bar.dart';
import 'result_screen.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late final BattleController _controller;
  late final AudioService _audioService;
  BattleState? _previousState;
  Timer? _feedbackTimer;
  String? _feedbackText;
  bool _hasOpenedResult = false;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();
    _controller = BattleController();
    _controller.addListener(_handleBattleStateChanged);
    _controller.startBattle();
    _previousState = _controller.state;
    _audioService.startBgm();
  }

  void _handleBattleStateChanged() {
    final previousState = _previousState;
    final currentState = _controller.state;

    if (previousState != null) {
      _playAudioFeedback(previousState, currentState);
      _showFeedback(previousState, currentState);
    }

    _previousState = currentState;

    if (_hasOpenedResult || _controller.state.playerHp > 0) {
      return;
    }

    _hasOpenedResult = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _openResult(BattleResult.defeat);
    });
  }

  void _playAudioFeedback(BattleState previousState, BattleState currentState) {
    final attack = currentState.currentAttack;
    if (previousState.currentAttack == null && attack != null) {
      switch (attack.type) {
        case AttackType.slash:
          _audioService.playAttackWarning();
        case AttackType.perilous:
          _audioService.playDanger();
      }
    }

    if (!previousState.isExecutionReady && currentState.isExecutionReady) {
      _audioService.playPostureBreak();
    }

    if (previousState.currentAttack?.type == AttackType.slash &&
        currentState.bossPosture > previousState.bossPosture) {
      _audioService.playParry();
    }

    if (previousState.message != currentState.message &&
        currentState.message == '閃身') {
      _audioService.playDodgeSuccess();
    }

    if (previousState.playerHp > currentState.playerHp) {
      _audioService.playHit();
    }
  }

  void _showFeedback(BattleState previousState, BattleState currentState) {
    String? nextFeedback;

    if (!previousState.isExecutionReady && currentState.isExecutionReady) {
      nextFeedback = '破防';
    } else if (previousState.playerHp > currentState.playerHp) {
      nextFeedback = '受傷';
    } else if (previousState.message != currentState.message) {
      nextFeedback = switch (currentState.message) {
        '鏘！完美格擋' => '鏘！',
        '閃身' => '閃身',
        '攻擊' => '斬擊',
        '反擊' => '反擊',
        _ => null,
      };
    }

    if (nextFeedback == null) {
      return;
    }

    _feedbackTimer?.cancel();
    setState(() {
      _feedbackText = nextFeedback;
    });
    _feedbackTimer = Timer(const Duration(milliseconds: 720), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _feedbackText = null;
      });
    });
  }

  void _returnToTitle() {
    _audioService.stopBgm();
    Navigator.of(context).pop();
  }

  void _openResult(BattleResult result) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => ResultScreen(result: result)),
    );
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleBattleStateChanged)
      ..dispose();
    _feedbackTimer?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF080608),
      body: SafeArea(
        child: InkBackground(
          imageAsset: 'assets/images/backgrounds/battle_bg.png',
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return _BattleContent(
                state: _controller.state,
                colorScheme: colorScheme,
                attackSequence: _controller.state.currentAttack,
                feedbackText: _feedbackText,
                onAttack: _controller.attack,
                onParry: _controller.parry,
                onDodge: _controller.dodge,
                onExecute: () {
                  _audioService.playExecution();
                  _openResult(BattleResult.victory);
                },
                onBackToTitle: () {
                  _returnToTitle();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BattleContent extends StatelessWidget {
  const _BattleContent({
    required this.state,
    required this.colorScheme,
    required this.attackSequence,
    required this.feedbackText,
    required this.onAttack,
    required this.onParry,
    required this.onDodge,
    required this.onExecute,
    required this.onBackToTitle,
  });

  final BattleState state;
  final ColorScheme colorScheme;
  final Object? attackSequence;
  final String? feedbackText;
  final VoidCallback onAttack;
  final VoidCallback onParry;
  final VoidCallback onDodge;
  final VoidCallback onExecute;
  final VoidCallback onBackToTitle;

  @override
  Widget build(BuildContext context) {
    final canRespond = state.currentAttack != null && !state.isExecutionReady;
    final canAttack =
        state.currentAttack == null &&
        state.canPlayerAttack &&
        !state.isExecutionReady;

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.52),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 10,
          child: _BattleHud(
            state: state,
            colorScheme: colorScheme,
            onBackToTitle: onBackToTitle,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 118,
          bottom: state.isExecutionReady ? 150 : 126,
          child: Stack(
            children: [
              BossPanel(
                isAttacking: state.currentAttack != null,
                isPlayerDamaged: feedbackText == '受傷',
                showParryClash: feedbackText == '鏘！',
                isBroken: state.isExecutionReady,
                currentAttackType: state.currentAttack?.type,
                playerSpriteState: _playerSpriteState,
              ),
              Positioned(
                left: 54,
                right: 54,
                bottom: 28,
                child: _GuardCountdownBar(
                  attackSequence: attackSequence,
                  isVisible: canRespond,
                  colorScheme: colorScheme,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 28,
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 140),
                    opacity: feedbackText == null ? 0 : 1,
                    child: Text(
                      feedbackText ?? '',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: feedbackText == '受傷'
                                ? colorScheme.error
                                : colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.75),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (state.isExecutionReady)
          Positioned(
            left: 16,
            right: 16,
            bottom: 104,
            child: GameButton(
              label: '處決',
              icon: Icons.flash_on,
              primary: true,
              onPressed: onExecute,
            ),
          ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 14,
          child: PlayerActionPanel(
            onAttack: canAttack ? onAttack : null,
            onParry: canRespond ? onParry : null,
            onDodge: canRespond ? onDodge : null,
          ),
        ),
      ],
    );
  }

  PlayerSpriteState get _playerSpriteState {
    if (state.isExecutionReady) {
      return PlayerSpriteState.execute;
    }
    if (feedbackText == '受傷') {
      return PlayerSpriteState.hit;
    }
    if (feedbackText == '斬擊') {
      return PlayerSpriteState.execute;
    }
    if (feedbackText == '鏘！') {
      return PlayerSpriteState.parry;
    }
    if (feedbackText == '閃身') {
      return PlayerSpriteState.dodge;
    }

    return PlayerSpriteState.idle;
  }
}

class _BattleHud extends StatelessWidget {
  const _BattleHud({
    required this.state,
    required this.colorScheme,
    required this.onBackToTitle,
  });

  final BattleState state;
  final ColorScheme colorScheme;
  final VoidCallback onBackToTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Shadow Parry',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFFFE3E6),
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
            TextButton(onPressed: onBackToTitle, child: const Text('離開')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StatBar(
                label: 'Boss HP',
                value: state.bossHp,
                maxValue: state.maxBossHp,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: StatBar(
                label: 'Player HP',
                value: state.playerHp,
                maxValue: state.maxPlayerHp,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        PostureBar(value: state.bossPosture, maxValue: state.maxBossPosture),
        const SizedBox(height: 5),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '連續看破：${state.combo}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.secondary,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GuardCountdownBar extends StatelessWidget {
  const _GuardCountdownBar({
    required this.attackSequence,
    required this.isVisible,
    required this.colorScheme,
  });

  final Object? attackSequence;
  final bool isVisible;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 90),
        opacity: isVisible ? 1 : 0,
        child: TweenAnimationBuilder<double>(
          key: ValueKey(attackSequence),
          tween: Tween<double>(begin: 1, end: 0),
          duration: const Duration(milliseconds: 900),
          builder: (context, value, _) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF16090C),
                border: Border.all(
                  color: colorScheme.secondary.withValues(alpha: 0.65),
                ),
                borderRadius: BorderRadius.circular(2),
              ),
              clipBehavior: Clip.antiAlias,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.secondary.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
