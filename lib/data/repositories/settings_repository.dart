import 'package:shared_preferences/shared_preferences.dart';

/// Persists user settings (sound, vibration, notifications).
class SettingsRepository {
  static const String _soundKey = 'setting_sound';
  static const String _vibrationKey = 'setting_vibration';
  static const String _notificationsKey = 'setting_notifications';
  static const String _notificationTimeKey = 'setting_notification_time';
  static const String _onboardingKey = 'has_seen_onboarding';

  Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundKey) ?? true;
  }

  Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, value);
  }

  Future<bool> getVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrationKey) ?? true;
  }

  Future<void> setVibrationEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, value);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? false;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
  }

  Future<String> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_notificationTimeKey) ?? '07:00';
  }

  Future<void> setNotificationTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationTimeKey, time);
  }

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  /// Reset all settings to defaults.
  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_soundKey);
    await prefs.remove(_vibrationKey);
    await prefs.remove(_notificationsKey);
    await prefs.remove(_notificationTimeKey);
    // Note: onboarding flag is NOT reset.
  }
}
