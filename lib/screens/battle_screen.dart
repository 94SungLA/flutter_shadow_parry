import 'package:flutter/material.dart';

import '../game/battle_state.dart';
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
  late BattleState _battleState = BattleState.initial();

  void _handleParry() {
    if (_battleState.isExecutionReady) {
      return;
    }

    setState(() {
      final nextPosture = (_battleState.bossPosture + 25).clamp(
        0,
        _battleState.maxBossPosture,
      );

      _battleState = _battleState.copyWith(
        bossPosture: nextPosture,
        message: nextPosture >= _battleState.maxBossPosture
            ? 'Boss 架勢已崩解，可以處決'
            : '格擋測試：Boss posture +25',
      );
    });
  }

  void _handleDodge() {
    setState(() {
      final nextPlayerHp = (_battleState.playerHp - 1).clamp(
        0,
        _battleState.maxPlayerHp,
      );

      _battleState = _battleState.copyWith(
        playerHp: nextPlayerHp,
        message: nextPlayerHp <= 0 ? '玩家 HP 歸零' : '閃避測試：玩家 HP -1',
      );
    });

    if (_battleState.playerHp <= 0) {
      _openResult(BattleResult.defeat);
    }
  }

  void _openResult(BattleResult result) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => ResultScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final attackMessage =
        _battleState.currentAttack?.warningText ?? _battleState.message;

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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatBar(
                label: 'Boss HP',
                value: _battleState.bossHp,
                maxValue: _battleState.maxBossHp,
                color: colorScheme.error,
              ),
              const SizedBox(height: 14),
              PostureBar(
                value: _battleState.bossPosture,
                maxValue: _battleState.maxBossPosture,
              ),
              const SizedBox(height: 14),
              StatBar(
                label: 'Player HP',
                value: _battleState.playerHp,
                maxValue: _battleState.maxPlayerHp,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const BossPanel(),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: colorScheme.outline),
                            borderRadius: BorderRadius.circular(8),
                            color: colorScheme.surfaceContainerHighest,
                          ),
                          child: Text(
                            attackMessage,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_battleState.isExecutionReady) ...[
                FilledButton.icon(
                  onPressed: () {
                    _openResult(BattleResult.victory);
                  },
                  icon: const Icon(Icons.flash_on),
                  label: const Text('處決'),
                ),
                const SizedBox(height: 12),
              ],
              PlayerActionPanel(onParry: _handleParry, onDodge: _handleDodge),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('返回主畫面'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  _openResult(BattleResult.victory);
                },
                child: const Text('前往勝利測試'),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () {
                  _openResult(BattleResult.defeat);
                },
                child: const Text('前往失敗測試'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
