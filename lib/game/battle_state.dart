import '../models/boss_attack.dart';

class BattleState {
  const BattleState({
    required this.playerHp,
    required this.maxPlayerHp,
    required this.bossHp,
    required this.maxBossHp,
    required this.bossPosture,
    required this.maxBossPosture,
    required this.combo,
    required this.message,
    required this.canPlayerAttack,
    this.currentAttack,
  });

  factory BattleState.initial() {
    return const BattleState(
      playerHp: 100,
      maxPlayerHp: 100,
      bossHp: 100,
      maxBossHp: 100,
      bossPosture: 0,
      maxBossPosture: 100,
      combo: 0,
      message: '',
      canPlayerAttack: true,
    );
  }

  final int playerHp;
  final int maxPlayerHp;
  final int bossHp;
  final int maxBossHp;
  final int bossPosture;
  final int maxBossPosture;
  final int combo;
  final BossAttack? currentAttack;
  final String message;
  final bool canPlayerAttack;

  bool get isExecutionReady => bossPosture >= maxBossPosture;

  BattleState copyWith({
    int? playerHp,
    int? maxPlayerHp,
    int? bossHp,
    int? maxBossHp,
    int? bossPosture,
    int? maxBossPosture,
    int? combo,
    BossAttack? currentAttack,
    String? message,
    bool? canPlayerAttack,
    bool clearCurrentAttack = false,
  }) {
    return BattleState(
      playerHp: playerHp ?? this.playerHp,
      maxPlayerHp: maxPlayerHp ?? this.maxPlayerHp,
      bossHp: bossHp ?? this.bossHp,
      maxBossHp: maxBossHp ?? this.maxBossHp,
      bossPosture: bossPosture ?? this.bossPosture,
      maxBossPosture: maxBossPosture ?? this.maxBossPosture,
      combo: combo ?? this.combo,
      canPlayerAttack: canPlayerAttack ?? this.canPlayerAttack,
      currentAttack: clearCurrentAttack
          ? null
          : currentAttack ?? this.currentAttack,
      message: message ?? this.message,
    );
  }
}
