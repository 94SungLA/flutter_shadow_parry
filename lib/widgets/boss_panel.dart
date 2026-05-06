import 'package:flutter/material.dart';

class BossPanel extends StatelessWidget {
  const BossPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 144,
          height: 144,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            border: Border.all(color: colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 52,
                color: colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Shadow Boss',
                style: textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 36, color: colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                'Player',
                style: textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
