import 'package:flutter/material.dart';

import '../widgets/boss_panel.dart';
import '../widgets/player_action_panel.dart';
import '../widgets/posture_bar.dart';
import '../widgets/stat_bar.dart';
import 'result_screen.dart';

class BattleScreen extends StatelessWidget {
  const BattleScreen({super.key});

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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatBar(
                label: 'Boss HP',
                value: 100,
                maxValue: 100,
                color: colorScheme.error,
              ),
              const SizedBox(height: 14),
              const PostureBar(value: 0, maxValue: 100),
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
                            '等待 Boss 出招',
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
              PlayerActionPanel(onParry: () {}, onDodge: () {}),
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
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const ResultScreen(result: BattleResult.victory),
                    ),
                  );
                },
                child: const Text('前往勝利測試'),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const ResultScreen(result: BattleResult.defeat),
                    ),
                  );
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
