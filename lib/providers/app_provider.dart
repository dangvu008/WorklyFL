import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../models/user_settings.dart';
import '../models/weather_data.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;
  
  UserSettings _settings = UserSettings();
  bool _isLoading = false;
  String? _error;

  // Getters
  UserSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Theme getters
  bool get isDarkMode => _settings.isDarkMode;
  ThemeMode get themeMode => _settings.themeMode;
  double get textScale => _settings.textScale;
  
  // Language getters
  String get language => _settings.language;
  
  // Notification getters
  bool get enableNotifications => _settings.enableNotifications;
  bool get enableWeatherAlerts => _settings.enableWeatherAlerts;
  bool get enableShiftReminders => _settings.enableShiftReminders;
  
  // Work getters
  String? get currentShiftId => _settings.currentShiftId;
  bool get simpleMode => _settings.simpleMode;
  double get hourlyRate => _settings.hourlyRate;
  
  // Weather getters
  bool get enableWeatherWidget => _settings.enableWeatherWidget;
  bool get canShowWeather => _settings.canShowWeather;

  AppProvider() {
    _loadSettings();
  }

  // Load settings from storage
  Future<void> _loadSettings() async {
    try {
      _setLoading(true);
      _settings = _storage.getUserSettings();
      developer.log('Settings loaded successfully');
    } catch (e) {
      _setError('Failed to load settings: $e');
      developer.log('Failed to load settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Save settings to storage
  Future<bool> _saveSettings() async {
    try {
      final success = await _storage.saveUserSettings(_settings);
      if (success) {
        developer.log('Settings saved successfully');
      } else {
        _setError('Failed to save settings');
      }
      return success;
    } catch (e) {
      _setError('Failed to save settings: $e');
      developer.log('Failed to save settings: $e');
      return false;
    }
  }

  // Update theme mode
  Future<void> setThemeMode(bool isDarkMode) async {
    if (_settings.isDarkMode != isDarkMode) {
      _settings = _settings.copyWith(isDarkMode: isDarkMode);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update text scale
  Future<void> setTextScale(double scale) async {
    final clampedScale = scale.clamp(0.8, 1.4);
    if (_settings.textScale != clampedScale) {
      _settings = _settings.copyWith(textScale: clampedScale);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update language
  Future<void> setLanguage(String language) async {
    if (_settings.language != language) {
      _settings = _settings.copyWith(language: language);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update haptic feedback
  Future<void> setHapticFeedback(bool enabled) async {
    if (_settings.enableHapticFeedback != enabled) {
      _settings = _settings.copyWith(enableHapticFeedback: enabled);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update sounds
  Future<void> setSounds(bool enabled) async {
    if (_settings.enableSounds != enabled) {
      _settings = _settings.copyWith(enableSounds: enabled);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update notifications
  Future<void> setNotifications(bool enabled) async {
    if (_settings.enableNotifications != enabled) {
      _settings = _settings.copyWith(enableNotifications: enabled);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update notification frequency
  Future<void> setNotificationFrequency(NotificationFrequency frequency) async {
    if (_settings.notificationFrequency != frequency) {
      _settings = _settings.copyWith(notificationFrequency: frequency);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update weather alerts
  Future<void> setWeatherAlerts(bool enabled) async {
    if (_settings.enableWeatherAlerts != enabled) {
      _settings = _settings.copyWith(enableWeatherAlerts: enabled);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update shift reminders
  Future<void> setShiftReminders(bool enabled) async {
    if (_settings.enableShiftReminders != enabled) {
      _settings = _settings.copyWith(enableShiftReminders: enabled);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update attendance reminders
  Future<void> setAttendanceReminders(bool enabled) async {
    if (_settings.enableAttendanceReminders != enabled) {
      _settings = _settings.copyWith(enableAttendanceReminders: enabled);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update reminder minutes before
  Future<void> setReminderMinutesBefore(int minutes) async {
    final clampedMinutes = minutes.clamp(5, 120);
    if (_settings.reminderMinutesBefore != clampedMinutes) {
      _settings = _settings.copyWith(reminderMinutesBefore: clampedMinutes);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update alarm mode
  Future<void> setAlarmMode(bool enabled) async {
    if (_settings.enableAlarmMode != enabled) {
      _settings = _settings.copyWith(enableAlarmMode: enabled);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update current shift
  Future<void> setCurrentShift(String? shiftId) async {
    if (_settings.currentShiftId != shiftId) {
      _settings = _settings.copyWith(currentShiftId: shiftId);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update simple mode
  Future<void> setSimpleMode(bool enabled) async {
    if (_settings.simpleMode != enabled) {
      _settings = _settings.copyWith(simpleMode: enabled);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update hourly rate
  Future<void> setHourlyRate(double rate) async {
    if (_settings.hourlyRate != rate && rate > 0) {
      _settings = _settings.copyWith(hourlyRate: rate);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update currency
  Future<void> setCurrency(String currency) async {
    if (_settings.currency != currency) {
      _settings = _settings.copyWith(currency: currency);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update auto location detection
  Future<void> setAutoLocationDetection(bool enabled) async {
    if (_settings.autoLocationDetection != enabled) {
      _settings = _settings.copyWith(autoLocationDetection: enabled);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update require location for attendance
  Future<void> setRequireLocationForAttendance(bool enabled) async {
    if (_settings.requireLocationForAttendance != enabled) {
      _settings = _settings.copyWith(requireLocationForAttendance: enabled);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update weather widget
  Future<void> setWeatherWidget(bool enabled) async {
    if (_settings.enableWeatherWidget != enabled) {
      _settings = _settings.copyWith(enableWeatherWidget: enabled);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update weather API key
  Future<void> setWeatherApiKey(String? apiKey) async {
    if (_settings.weatherApiKey != apiKey) {
      _settings = _settings.copyWith(weatherApiKey: apiKey);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update weather API keys list
  Future<void> setWeatherApiKeys(List<String> apiKeys) async {
    _settings = _settings.copyWith(weatherApiKeys: apiKeys);
    notifyListeners();
    await _saveSettings();
  }

  // Update home location
  Future<void> setHomeLocation(WeatherLocation? location) async {
    _settings = _settings.copyWith(homeLocation: location);
    notifyListeners();
    await _saveSettings();
  }

  // Update work location
  Future<void> setWorkLocation(WeatherLocation? location) async {
    _settings = _settings.copyWith(workLocation: location);
    notifyListeners();
    await _saveSettings();
  }

  // Update use single location
  Future<void> setUseSingleLocation(bool enabled) async {
    if (_settings.useSingleLocation != enabled) {
      _settings = _settings.copyWith(useSingleLocation: enabled);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update weather cache hours
  Future<void> setWeatherCacheHours(int hours) async {
    final clampedHours = hours.clamp(1, 24);
    if (_settings.weatherCacheHours != clampedHours) {
      _settings = _settings.copyWith(weatherCacheHours: clampedHours);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update weather notifications
  Future<void> setWeatherNotifications(bool enabled) async {
    if (_settings.enableWeatherNotifications != enabled) {
      _settings = _settings.copyWith(enableWeatherNotifications: enabled);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update location history
  Future<void> setLocationHistory(bool enabled) async {
    if (_settings.enableLocationHistory != enabled) {
      _settings = _settings.copyWith(enableLocationHistory: enabled);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update data export
  Future<void> setDataExport(bool enabled) async {
    if (_settings.enableDataExport != enabled) {
      _settings = _settings.copyWith(enableDataExport: enabled);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update analytics
  Future<void> setAnalytics(bool enabled) async {
    if (_settings.enableAnalytics != enabled) {
      _settings = _settings.copyWith(enableAnalytics: enabled);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update debug mode
  Future<void> setDebugMode(bool enabled) async {
    if (_settings.enableDebugMode != enabled) {
      _settings = _settings.copyWith(enableDebugMode: enabled);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update beta features
  Future<void> setBetaFeatures(bool enabled) async {
    if (_settings.enableBetaFeatures != enabled) {
      _settings = _settings.copyWith(enableBetaFeatures: enabled);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update data retention days
  Future<void> setDataRetentionDays(int days) async {
    final clampedDays = days.clamp(30, 3650); // 30 days to 10 years
    if (_settings.dataRetentionDays != clampedDays) {
      _settings = _settings.copyWith(dataRetentionDays: clampedDays);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update auto backup
  Future<void> setAutoBackup(bool enabled) async {
    if (_settings.autoBackup != enabled) {
      _settings = _settings.copyWith(autoBackup: enabled);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Update backup path
  Future<void> setBackupPath(String? path) async {
    if (_settings.backupPath != path) {
      _settings = _settings.copyWith(backupPath: path);
      notifyListeners();
      await _saveSettings();
    }
  }

  // Reset settings to default
  Future<void> resetSettings() async {
    _settings = UserSettings();
    notifyListeners();
    await _saveSettings();
  }

  // Refresh settings from storage
  Future<void> refreshSettings() async {
    await _loadSettings();
  }

  // Helper methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  void clearError() {
    _setError(null);
  }
}
