import 'package:flutter/material.dart';

import 'game_button.dart';

class PlayerActionPanel extends StatelessWidget {
  const PlayerActionPanel({
    super.key,
    this.onAttack,
    this.onParry,
    this.onDodge,
  });

  final VoidCallback? onAttack;
  final VoidCallback? onParry;
  final VoidCallback? onDodge;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GameButton(
            label: '攻擊',
            icon: Icons.gavel,
            primary: true,
            compact: true,
            onPressed: onAttack,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GameButton(
            label: '格擋',
            icon: Icons.shield,
            compact: true,
            onPressed: onParry,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GameButton(
            label: '閃身',
            icon: Icons.directions_run,
            compact: true,
            onPressed: onDodge,
          ),
        ),
      ],
    );
  }
}
