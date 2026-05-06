import 'attack_type.dart';

class BossAttack {
  const BossAttack({
    required this.type,
    required this.warningText,
    required this.requiredActionText,
  });

  final AttackType type;
  final String warningText;
  final String requiredActionText;
}
