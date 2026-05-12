import 'package:flutter/material.dart';

import '../widgets/ink_background.dart';
import 'battle_screen.dart';

enum BattleResult { victory, defeat }

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  final BattleResult result;

  bool get _isVictory => result == BattleResult.victory;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final title = _isVictory ? '處決成功' : '敗北';
    final subtitle = _isVictory ? '一瞬破勢，斬斷暗影' : '刀慢一瞬，命懸一線';
    final titleColor = _isVictory
        ? const Color(0xFFFFE3E5)
        : const Color(0xFFB4A8AA);

    return Scaffold(
      backgroundColor: const Color(0xFF070507),
      body: InkBackground(
        isDefeat: !_isVictory,
        imageAsset: _isVictory
            ? 'assets/images/backgrounds/victory_bg.png'
            : 'assets/images/backgrounds/defeat_bg.png',
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    Center(
                      child: Container(
                        width: 180,
                        height: 180,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              (_isVictory ? colorScheme.error : Colors.black)
                                  .withValues(alpha: _isVictory ? 0.38 : 0.28),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Text(
                          _isVictory ? '斬' : '敗',
                          style: textTheme.displayLarge?.copyWith(
                            color: titleColor.withValues(alpha: 0.92),
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(
                                color:
                                    (_isVictory
                                            ? colorScheme.error
                                            : Colors.black)
                                        .withValues(alpha: 0.75),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: textTheme.displaySmall?.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.82),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: _isVictory
                            ? const Color(0xFFE8C3C7)
                            : const Color(0xFFB0A5A7),
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.78),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 120),
                    _ResultGhostButton(
                      label: '重新挑戰',
                      icon: Icons.refresh,
                      primary: true,
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => const BattleScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _ResultGhostButton(
                      label: '回主畫面',
                      icon: Icons.home_outlined,
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
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

class _ResultGhostButton extends StatefulWidget {
  const _ResultGhostButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool primary;

  @override
  State<_ResultGhostButton> createState() => _ResultGhostButtonState();
}

class _ResultGhostButtonState extends State<_ResultGhostButton> {
  bool _isHovering = false;
  bool _isPressing = false;

  @override
  Widget build(BuildContext context) {
    final isActive = _isHovering || _isPressing;
    final borderColor = widget.primary
        ? const Color(0xFFE35A68)
        : Colors.white.withValues(alpha: 0.48);
    final foregroundColor = widget.primary
        ? const Color(0xFFFFE4E7)
        : Colors.white.withValues(alpha: 0.72);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() {
        _isHovering = false;
        _isPressing = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressing = true),
        onTapCancel: () => setState(() => _isPressing = false),
        onTapUp: (_) => setState(() => _isPressing = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(10),
            splashColor:
                (widget.primary ? const Color(0xFFE04455) : Colors.white)
                    .withValues(alpha: 0.14),
            highlightColor:
                (widget.primary ? const Color(0xFFE04455) : Colors.white)
                    .withValues(alpha: 0.08),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              height: 54,
              decoration: BoxDecoration(
                color: Colors.black.withValues(
                  alpha: widget.primary
                      ? (isActive ? 0.44 : 0.34)
                      : (isActive ? 0.3 : 0.22),
                ),
                border: Border.all(
                  color: isActive
                      ? (widget.primary
                            ? const Color(0xFFFF8490)
                            : Colors.white.withValues(alpha: 0.68))
                      : borderColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color:
                        (widget.primary
                                ? const Color(0xFFC7283D)
                                : Colors.white)
                            .withValues(
                              alpha: widget.primary
                                  ? (isActive ? 0.32 : 0.2)
                                  : (isActive ? 0.12 : 0.06),
                            ),
                    blurRadius: widget.primary ? (isActive ? 20 : 14) : 8,
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 20, color: foregroundColor),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: foregroundColor,
                        fontWeight: widget.primary
                            ? FontWeight.bold
                            : FontWeight.w600,
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
