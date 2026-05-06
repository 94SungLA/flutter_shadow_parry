import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/attack_type.dart';
import '../models/boss_attack.dart';
import 'battle_state.dart';

class BattleController extends ChangeNotifier {
  BattleController({Random? random}) : _random = random ?? Random();

  final Random _random;

  BattleState _state = BattleState.initial();
  Timer? _attackTimer;
  Timer? _reactionTimer;
  bool _isBattleRunning = false;

  BattleState get state => _state;

  void startBattle() {
    if (_isBattleRunning) {
      return;
    }

    _isBattleRunning = true;
    _state = BattleState.initial();
    notifyListeners();

    _attackTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _createBossAttack();
    });
  }

  void parry() {
    _respondWith(AttackType.slash);
  }

  void dodge() {
    _respondWith(AttackType.perilous);
  }

  void _createBossAttack() {
    if (!_isBattleRunning ||
        _state.currentAttack != null ||
        _state.isExecutionReady ||
        _state.playerHp <= 0) {
      return;
    }

    final attackType = _random.nextBool()
        ? AttackType.slash
        : AttackType.perilous;

    _state = _state.copyWith(
      currentAttack: _buildAttack(attackType),
      message: 'Boss 出招了',
    );
    notifyListeners();

    _reactionTimer?.cancel();
    _reactionTimer = Timer(const Duration(seconds: 1), _handleReactionTimeout);
  }

  BossAttack _buildAttack(AttackType type) {
    switch (type) {
      case AttackType.slash:
        return const BossAttack(
          type: AttackType.slash,
          warningText: '普通攻擊：請格擋',
          requiredActionText: '格擋',
        );
      case AttackType.perilous:
        return const BossAttack(
          type: AttackType.perilous,
          warningText: '危攻擊：請閃避',
          requiredActionText: '閃避',
        );
    }
  }

  void _respondWith(AttackType playerAction) {
    final attack = _state.currentAttack;
    if (!_isBattleRunning || attack == null) {
      return;
    }

    _reactionTimer?.cancel();

    if (attack.type == playerAction) {
      _handleSuccessfulResponse(attack.type);
    } else {
      _damagePlayer('判斷錯誤！受到傷害');
    }
  }

  void _handleSuccessfulResponse(AttackType attackType) {
    final nextPosture = (_state.bossPosture + 25).clamp(
      0,
      _state.maxBossPosture,
    );
    final isExecutionReady = nextPosture >= _state.maxBossPosture;
    final successMessage = switch (attackType) {
      AttackType.slash => '鏘！完美格擋',
      AttackType.perilous => '閃過危攻擊',
    };

    _state = _state.copyWith(
      bossPosture: nextPosture,
      clearCurrentAttack: true,
      message: isExecutionReady ? '架勢崩解！可以處決' : successMessage,
    );

    if (isExecutionReady) {
      _stopBossAttack();
    }

    notifyListeners();
  }

  void _handleReactionTimeout() {
    if (!_isBattleRunning || _state.currentAttack == null) {
      return;
    }

    _damagePlayer('反應太慢！受到傷害');
  }

  void _damagePlayer(String message) {
    final nextPlayerHp = (_state.playerHp - 1).clamp(0, _state.maxPlayerHp);
    final isDefeated = nextPlayerHp <= 0;

    _state = _state.copyWith(
      playerHp: nextPlayerHp,
      clearCurrentAttack: true,
      message: message,
    );

    if (isDefeated) {
      _stopBossAttack();
    }

    notifyListeners();
  }

  void _stopBossAttack() {
    _isBattleRunning = false;
    _attackTimer?.cancel();
    _attackTimer = null;
    _reactionTimer?.cancel();
    _reactionTimer = null;
  }

  @override
  void dispose() {
    _stopBossAttack();
    super.dispose();
  }
}
