import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';
import '../services/storage_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService.instance;
  final StorageService _storage = StorageService.instance;
  
  WeatherData? _currentWeather;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdated;

  // Getters
  WeatherData? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  bool get hasWeatherData => _currentWeather != null;

  WeatherProvider() {
    _loadCachedWeather();
  }

  // Load cached weather data
  void _loadCachedWeather() {
    try {
      _currentWeather = _storage.getWeatherCache();
      if (_currentWeather != null) {
        _lastUpdated = _currentWeather!.timestamp;
        developer.log('Loaded cached weather data');
        notifyListeners();
      }
    } catch (e) {
      developer.log('Failed to load cached weather: $e');
    }
  }

  // Get current weather
  Future<void> getCurrentWeather({
    required double latitude,
    required double longitude,
    String? locationName,
    bool forceRefresh = false,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final weather = await _weatherService.getCurrentWeather(
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
        forceRefresh: forceRefresh,
      );

      if (weather != null) {
        _currentWeather = weather;
        _lastUpdated = weather.timestamp;
        developer.log('Weather data updated for ${weather.location.name}');
      } else {
        _setError('Không thể lấy dữ liệu thời tiết');
      }
    } catch (e) {
      _setError('Lỗi khi lấy thời tiết: $e');
      developer.log('Failed to get weather: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh weather data
  Future<void> refreshWeather() async {
    if (_currentWeather != null) {
      await getCurrentWeather(
        latitude: _currentWeather!.location.latitude,
        longitude: _currentWeather!.location.longitude,
        locationName: _currentWeather!.location.name,
        forceRefresh: true,
      );
    }
  }

  // Check weather alerts
  Future<void> checkWeatherAlerts({
    required DateTime departureTime,
  }) async {
    try {
      final settings = _storage.getUserSettings();
      await _weatherService.checkWeatherAlerts(
        settings: settings,
        departureTime: departureTime,
      );
    } catch (e) {
      developer.log('Failed to check weather alerts: $e');
    }
  }

  // Test API key
  Future<bool> testApiKey(String apiKey) async {
    try {
      return await _weatherService.testApiKey(apiKey);
    } catch (e) {
      developer.log('Failed to test API key: $e');
      return false;
    }
  }

  // Clear weather cache
  Future<void> clearCache() async {
    try {
      await _weatherService.clearCache();
      _currentWeather = null;
      _lastUpdated = null;
      notifyListeners();
      developer.log('Weather cache cleared');
    } catch (e) {
      developer.log('Failed to clear weather cache: $e');
    }
  }

  // Get cache age
  Duration? getCacheAge() {
    return _weatherService.getCacheAge();
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

  void _clearError() {
    _setError(null);
  }

  void clearError() {
    _clearError();
  }
}
