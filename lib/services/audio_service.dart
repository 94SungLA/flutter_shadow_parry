import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AudioService {
  AudioService() : _bgmPlayer = AudioPlayer(), _effectPlayer = AudioPlayer();

  static const String _assetPrefix = 'assets/audio/';
  static const String _audioSourcePrefix = 'audio/';
  static const String _bgmFile = 'bgm.mp3';
  static const String _attackWarningFile = 'attack_warning.mp3';
  static const String _parryFile = 'parry.mp3';
  static const String _dodgeSuccessFile = 'dodge_success.mp3';
  static const String _hitFile = 'hit.mp3';
  static const String _dangerFile = 'danger.mp3';
  static const String _postureBreakFile = 'posture_break.mp3';
  static const String _executionFile = 'execution.mp3';

  final AudioPlayer _bgmPlayer;
  final AudioPlayer _effectPlayer;

  Future<void> startBgm() async {
    if (!await _assetExists(_bgmFile)) {
      return;
    }

    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(_assetSource(_bgmFile), volume: 0.45);
    } on Exception {
      // Audio files are optional for this assignment build.
    }
  }

  Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
    } on Exception {
      // Ignore platform audio shutdown errors.
    }
  }

  Future<void> playAttackWarning() => _playEffect(_attackWarningFile);

  Future<void> playParry() => _playEffect(_parryFile);

  Future<void> playDodgeSuccess() => _playEffect(_dodgeSuccessFile);

  Future<void> playHit() => _playEffect(_hitFile);

  Future<void> playDanger() => _playEffect(_dangerFile);

  Future<void> playPostureBreak() => _playEffect(_postureBreakFile);

  Future<void> playExecution() => _playEffect(_executionFile);

  Future<void> dispose() async {
    await stopBgm();
    await _bgmPlayer.dispose();
    await _effectPlayer.dispose();
  }

  Future<void> _playEffect(String fileName) async {
    if (!await _assetExists(fileName)) {
      return;
    }

    try {
      await _effectPlayer.stop();
      await _effectPlayer.play(_assetSource(fileName));
    } on Exception {
      // Missing or unsupported placeholder audio should not break gameplay.
    }
  }

  Future<bool> _assetExists(String fileName) async {
    try {
      await rootBundle.load('$_assetPrefix$fileName');
      return true;
    } on FlutterError {
      return false;
    }
  }

  AssetSource _assetSource(String fileName) {
    return AssetSource('$_audioSourcePrefix$fileName');
  }
}
