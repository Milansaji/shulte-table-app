import 'package:audioplayers/audioplayers.dart';

/// Singleton service for managing and playing game sound effects.
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _errorPlayer = AudioPlayer();
  final AudioPlayer _unlockPlayer = AudioPlayer();
  
  // Pool of players for rapid clicking to allow overlapping sounds.
  final List<AudioPlayer> _clickPool = List.generate(5, (_) => AudioPlayer());
  int _poolIndex = 0;
  
  bool _soundEnabled = true;

  set soundEnabled(bool value) => _soundEnabled = value;

  /// Preload sounds and set low latency mode where possible.
  Future<void> initialize() async {
    for (final player in _clickPool) {
      // Set source once to speed up subsequent plays
      await player.setSource(AssetSource('audio/click-sound.wav'));
    }
    await _errorPlayer.setSource(AssetSource('audio/error.wav'));
    await _unlockPlayer.setSource(AssetSource('audio/level unlock.mp3'));
  }

  /// Play the sound for a correct tap.
  Future<void> playCorrect() async {
    if (!_soundEnabled) return;
    
    final player = _clickPool[_poolIndex];
    _poolIndex = (_poolIndex + 1) % _clickPool.length;
    
    // For rapid clicks, we seek to zero and resume instead of stop/play
    // This allows the sounds to overlap if we use a pool
    await player.stop(); 
    player.play(AssetSource('audio/click-sound.wav'), mode: PlayerMode.lowLatency);
  }

  /// Play the sound for an incorrect tap.
  Future<void> playWrong() async {
    if (!_soundEnabled) return;
    await _errorPlayer.stop();
    _errorPlayer.play(AssetSource('audio/error.wav'), mode: PlayerMode.lowLatency);
  }

  /// Play the sound for game completion or level unlock.
  Future<void> playLevelUnlock() async {
    if (!_soundEnabled) return;
    await _unlockPlayer.stop();
    _unlockPlayer.play(AssetSource('audio/level unlock.mp3'));
  }

  void dispose() {
    for (final p in _clickPool) {
      p.dispose();
    }
    _errorPlayer.dispose();
    _unlockPlayer.dispose();
  }
}
