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
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            minHeight: 12,
            value: _progress,
            color: postureColor,
            backgroundColor: postureColor.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}
