import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyDailyReminder = 'daily_reminder';
  static const String _keyReminderTime = 'reminder_time';
  static const String _keyAutoDeleteCompleted = 'auto_delete_completed';

  // Singleton pattern
  static final AppSettings _instance = AppSettings._internal();
  factory AppSettings() => _instance;
  AppSettings._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Theme Settings
  bool get isDarkMode => _prefs?.getBool(_keyThemeMode) ?? false;
  
  Future<void> setDarkMode(bool value) async {
    await _prefs?.setBool(_keyThemeMode, value);
  }

  // Notification Settings
  bool get notificationsEnabled => _prefs?.getBool(_keyNotificationsEnabled) ?? true;
  
  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs?.setBool(_keyNotificationsEnabled, value);
  }

  // Daily Reminder
  bool get dailyReminderEnabled => _prefs?.getBool(_keyDailyReminder) ?? true;
  
  Future<void> setDailyReminderEnabled(bool value) async {
    await _prefs?.setBool(_keyDailyReminder, value);
  }

  // Reminder Time (hour of day)
  int get reminderHour => _prefs?.getInt(_keyReminderTime) ?? 9; // 9 AM default
  
  Future<void> setReminderHour(int hour) async {
    await _prefs?.setInt(_keyReminderTime, hour);
  }

  // Auto Delete Completed Tasks
  bool get autoDeleteCompleted => _prefs?.getBool(_keyAutoDeleteCompleted) ?? false;
  
  Future<void> setAutoDeleteCompleted(bool value) async {
    await _prefs?.setBool(_keyAutoDeleteCompleted, value);
  }

  // Reset all settings
  Future<void> resetSettings() async {
    await _prefs?.clear();
  }
}