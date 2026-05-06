import 'package:flutter/material.dart';

class PlayerActionPanel extends StatelessWidget {
  const PlayerActionPanel({super.key, this.onParry, this.onDodge});

  final VoidCallback? onParry;
  final VoidCallback? onDodge;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onParry,
            icon: const Icon(Icons.shield),
            label: const Text('格擋'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: onDodge,
            icon: const Icon(Icons.directions_run),
            label: const Text('閃身'),
          ),
        ),
      ],
    );
  }
}
