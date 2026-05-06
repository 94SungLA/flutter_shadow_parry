import 'package:flutter/material.dart';

enum BattleResult { victory, defeat }

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  final BattleResult result;

  bool get _isVictory => result == BattleResult.victory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isVictory ? '勝利' : '失敗',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isVictory ? '你成功處決了 Boss。' : '你的 HP 歸零了。',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('回主畫面'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
