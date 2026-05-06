import 'package:flutter/material.dart';

class StatBar extends StatelessWidget {
  const StatBar({
    super.key,
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  final String label;
  final int value;
  final int maxValue;
  final Color color;

  double get _progress {
    if (maxValue <= 0) {
      return 0;
    }

    return (value / maxValue).clamp(0, 1).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: textTheme.labelLarge),
            Text('$value / $maxValue', style: textTheme.labelMedium),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            minHeight: 14,
            value: _progress,
            color: color,
            backgroundColor: color.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}
