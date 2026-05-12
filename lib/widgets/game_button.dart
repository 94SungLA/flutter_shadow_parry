import 'package:flutter/material.dart';

class GameButton extends StatelessWidget {
  const GameButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool primary;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null;
    final borderColor = primary
        ? const Color(0xFFE35A68)
        : colorScheme.outline.withValues(alpha: 0.65);
    final textColor = enabled
        ? (primary ? const Color(0xFFFFE5E8) : colorScheme.onSurface)
        : colorScheme.onSurface.withValues(alpha: 0.38);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        splashColor: const Color(0xFFE04455).withValues(alpha: 0.24),
        highlightColor: const Color(0xFFE04455).withValues(alpha: 0.12),
        child: Ink(
          height: compact ? 40 : 58,
          decoration: BoxDecoration(
            gradient: enabled && primary
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF330911), Color(0xFF8D182B)],
                  )
                : null,
            color: primary ? const Color(0xFF0D090B) : Colors.transparent,
            border: Border.all(
              color: enabled
                  ? borderColor
                  : colorScheme.outline.withValues(alpha: 0.25),
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: enabled && primary
                ? [
                    BoxShadow(
                      color: const Color(0xFFC7283D).withValues(alpha: 0.35),
                      blurRadius: 16,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: compact ? 17 : 20, color: textColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
