import 'package:flutter/material.dart';

import '../widgets/game_button.dart';
import '../widgets/game_panel.dart';
import '../widgets/ink_background.dart';
import 'battle_screen.dart';

class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF080608),
      body: InkBackground(
        imageAsset: 'assets/images/backgrounds/title_bg.png',
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 28),
                    Center(
                      child: Container(
                        width: 132,
                        height: 132,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFB92A3D).withValues(alpha: 0.36),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Transform.rotate(
                            angle: -0.7,
                            child: Container(
                              width: 6,
                              height: 112,
                              color: const Color(
                                0xFFE8D8D8,
                              ).withValues(alpha: 0.75),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Shadow Parry',
                      textAlign: TextAlign.center,
                      style: textTheme.displayMedium?.copyWith(
                        color: const Color(0xFFFFE8EA),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '影刃格擋',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '聽聲辨刃，一瞬破勢',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFE5D6D8),
                      ),
                    ),
                    const SizedBox(height: 34),
                    GameButton(
                      label: '開始遊戲',
                      icon: Icons.flash_on,
                      primary: true,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const BattleScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    GamePanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '操作說明',
                            style: textTheme.titleMedium?.copyWith(
                              color: const Color(0xFFFFE2E5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '聽見出刃聲時判斷攻勢。\n普通斬擊以「格擋」破勢，紅色危攻擊以「閃身」避開。\n架勢崩解後，抓住一瞬處決。',
                            style: textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFFD6C6C8),
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
