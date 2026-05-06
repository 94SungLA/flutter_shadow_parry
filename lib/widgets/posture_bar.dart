import 'package:flutter/material.dart';

class PostureBar extends StatelessWidget {
  const PostureBar({super.key, required this.value, required this.maxValue});

  final int value;
  final int maxValue;

  double get _progress {
    if (maxValue <= 0) {
      return 0;
    }

    return (value / maxValue).clamp(0, 1).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    const postureColor = Color(0xFFE6B422);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Boss posture', style: textTheme.labelLarge),
            Text('$value / $maxValue', style: textTheme.labelMedium),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 14,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            border: Border.all(color: postureColor.withValues(alpha: 0.65)),
            borderRadius: BorderRadius.circular(3),
          ),
          clipBehavior: Clip.antiAlias,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progress,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: postureColor,
                boxShadow: [
                  BoxShadow(
                    color: postureColor.withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
