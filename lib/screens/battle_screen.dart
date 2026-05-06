import 'dart:async';

import 'package:flutter/material.dart';

import '../game/battle_controller.dart';
import '../game/battle_state.dart';
import '../models/attack_type.dart';
import '../services/audio_service.dart';
import '../widgets/boss_panel.dart';
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
    if (previousState.currentAttack == null &&
        attack?.type == AttackType.perilous) {
      _audioService.playDanger();
    }

    if (currentState.bossPosture > previousState.bossPosture) {
      _audioService.playParry();
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
      appBar: AppBar(
        title: const Text('戰鬥畫面'),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: '返回主畫面',
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return _BattleContent(
              state: _controller.state,
              colorScheme: colorScheme,
              attackSequence: _controller.state.currentAttack,
              feedbackText: _feedbackText,
              onParry: _controller.parry,
              onDodge: _controller.dodge,
              onExecute: () {
                _audioService.playExecution();
                _openResult(BattleResult.victory);
              },
              onBackToTitle: () {
                _returnToTitle();
              },
              onVictoryTest: () {
                _openResult(BattleResult.victory);
              },
              onDefeatTest: () {
                _openResult(BattleResult.defeat);
              },
            );
          },
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
    required this.onParry,
    required this.onDodge,
    required this.onExecute,
    required this.onBackToTitle,
    required this.onVictoryTest,
    required this.onDefeatTest,
  });

  final BattleState state;
  final ColorScheme colorScheme;
  final Object? attackSequence;
  final String? feedbackText;
  final VoidCallback onParry;
  final VoidCallback onDodge;
  final VoidCallback onExecute;
  final VoidCallback onBackToTitle;
  final VoidCallback onVictoryTest;
  final VoidCallback onDefeatTest;

  @override
  Widget build(BuildContext context) {
    final canRespond = state.currentAttack != null && !state.isExecutionReady;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF12090D),
              border: Border.all(
                color: colorScheme.error.withValues(alpha: 0.45),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  StatBar(
                    label: 'Boss HP',
                    value: state.bossHp,
                    maxValue: state.maxBossHp,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  PostureBar(
                    value: state.bossPosture,
                    maxValue: state.maxBossPosture,
                  ),
                  const SizedBox(height: 12),
                  StatBar(
                    label: 'Player HP',
                    value: state.playerHp,
                    maxValue: state.maxPlayerHp,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '連續看破：${state.combo}',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BossPanel(
                      isAttacking: state.currentAttack != null,
                      isPlayerDamaged: feedbackText == '受傷',
                      showParryClash: feedbackText == '鏘！',
                      isBroken: state.isExecutionReady,
                      currentAttackType: state.currentAttack?.type,
                      playerSpriteState: _playerSpriteState,
                    ),
                    const SizedBox(height: 8),
                    _GuardCountdownBar(
                      attackSequence: attackSequence,
                      isVisible: canRespond,
                      colorScheme: colorScheme,
                    ),
                    SizedBox(
                      height: 34,
                      child: Center(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 140),
                          opacity: feedbackText == null ? 0 : 1,
                          child: Text(
                            feedbackText ?? '',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: feedbackText == '受傷'
                                      ? colorScheme.error
                                      : colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (state.isExecutionReady) ...[
            FilledButton(
              onPressed: onExecute,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                minimumSize: const Size.fromHeight(52),
                textStyle: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flash_on),
                  SizedBox(width: 8),
                  Text('處決'),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          PlayerActionPanel(
            onParry: canRespond ? onParry : null,
            onDodge: canRespond ? onDodge : null,
          ),
          const SizedBox(height: 10),
          TextButton(onPressed: onBackToTitle, child: const Text('返回主畫面')),
          Opacity(
            opacity: 0.45,
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onVictoryTest,
                    child: const Text('Debug 勝利'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: onDefeatTest,
                    child: const Text('Debug 失敗'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PlayerSpriteState get _playerSpriteState {
    if (state.isExecutionReady) {
      return PlayerSpriteState.execute;
    }
    if (feedbackText == '受傷') {
      return PlayerSpriteState.hit;
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
