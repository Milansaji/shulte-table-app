import 'package:flutter/material.dart';
import '../../data/repositories/settings_repository.dart';

/// Provider for user settings (sound, vibration, notifications).
class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repo = SettingsRepository();

  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = false;
  bool _hasSeenOnboarding = false;
  bool _isInitialized = false;

  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isInitialized => _isInitialized;

  /// Load all settings from disk. Call once at app start.
  Future<void> initialize() async {
    _soundEnabled = await _repo.getSoundEnabled();
    _vibrationEnabled = await _repo.getVibrationEnabled();
    _notificationsEnabled = await _repo.getNotificationsEnabled();
    _hasSeenOnboarding = await _repo.hasSeenOnboarding();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _repo.setSoundEnabled(value);
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    await _repo.setVibrationEnabled(value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _repo.setNotificationsEnabled(value);
    notifyListeners();
  }

  Future<void> markOnboardingSeen() async {
    _hasSeenOnboarding = true;
    await _repo.setOnboardingSeen();
    notifyListeners();
  }

  /// Reset all settings (except onboarding) and all game progress.
  Future<void> resetSettings() async {
    await _repo.resetAll();
    _soundEnabled = true;
    _vibrationEnabled = true;
    _notificationsEnabled = false;
    notifyListeners();
  }
}
