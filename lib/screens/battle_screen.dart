import 'package:flutter/material.dart';

import '../game/battle_controller.dart';
import '../game/battle_state.dart';
import '../models/attack_type.dart';
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
  bool _hasOpenedResult = false;

  @override
  void initState() {
    super.initState();
    _controller = BattleController();
    _controller.addListener(_handleBattleStateChanged);
    _controller.startBattle();
  }

  void _handleBattleStateChanged() {
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
              onParry: _controller.parry,
              onDodge: _controller.dodge,
              onExecute: () {
                _openResult(BattleResult.victory);
              },
              onBackToTitle: () {
                Navigator.of(context).pop();
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
    required this.onParry,
    required this.onDodge,
    required this.onExecute,
    required this.onBackToTitle,
    required this.onVictoryTest,
    required this.onDefeatTest,
  });

  final BattleState state;
  final ColorScheme colorScheme;
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatBar(
            label: 'Boss HP',
            value: state.bossHp,
            maxValue: state.maxBossHp,
            color: colorScheme.error,
          ),
          const SizedBox(height: 14),
          PostureBar(value: state.bossPosture, maxValue: state.maxBossPosture),
          const SizedBox(height: 14),
          StatBar(
            label: 'Player HP',
            value: state.playerHp,
            maxValue: state.maxPlayerHp,
            color: colorScheme.primary,
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
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BossPanel(
                      isAttacking: state.currentAttack != null,
                      isPlayerDamaged: state.message.contains('受到傷害'),
                      showParryClash: state.message == '鏘！完美格擋',
                      isBroken: state.isExecutionReady,
                    ),
                    const SizedBox(height: 24),
                    _AttackPrompt(state: state, colorScheme: colorScheme),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
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
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onBackToTitle, child: const Text('返回主畫面')),
          const SizedBox(height: 12),
          FilledButton(onPressed: onVictoryTest, child: const Text('前往勝利測試')),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: onDefeatTest,
            child: const Text('前往失敗測試'),
          ),
        ],
      ),
    );
  }
}

class _AttackPrompt extends StatelessWidget {
  const _AttackPrompt({required this.state, required this.colorScheme});

  final BattleState state;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final attack = state.currentAttack;
    final isPerilous = attack?.type == AttackType.perilous;
    final isSlash = attack?.type == AttackType.slash;
    final backgroundColor = isPerilous
        ? colorScheme.errorContainer
        : isSlash
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final foregroundColor = isPerilous
        ? colorScheme.onErrorContainer
        : isSlash
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isPerilous ? colorScheme.error : colorScheme.outline,
          width: isPerilous ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: backgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isPerilous) ...[
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.error,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '危',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onError,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Text(
              attack?.warningText ?? '等待 Boss 出招',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: foregroundColor,
                fontWeight: isPerilous || isSlash ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
