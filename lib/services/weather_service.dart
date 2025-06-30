import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../constants/app_theme.dart';
import '../models/weather_data.dart';
import '../models/user_settings.dart';
import 'storage_service.dart';
import 'notification_service.dart';

class WeatherService {
  static WeatherService? _instance;
  static WeatherService get instance => _instance ??= WeatherService._();
  
  WeatherService._();
  
  final StorageService _storage = StorageService.instance;
  final NotificationService _notifications = NotificationService.instance;
  
  int _currentApiKeyIndex = 0;
  
  // Default API keys (you can add more)
  static const List<String> _defaultApiKeys = [
    'f579dc21602c95c0fb90bdd68e7427c4',
    'd538391c9189a7d781acfe8a1564b809',
    'a186029bd5be168cc589285644d1b2da',
    '9527c56ae15c3b7c623f0c7b03f5de88',
    '1e6cec1180c55ea72dfe7968118c9fe6',
  ];

  // Get current weather data with caching
  Future<WeatherData?> getCurrentWeather({
    required double latitude,
    required double longitude,
    String? locationName,
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first (unless force refresh)
      if (!forceRefresh) {
        final cachedWeather = _storage.getWeatherCache(
          maxAge: AppConstants.weatherCacheDuration,
        );
        
        if (cachedWeather != null && 
            cachedWeather.location.latitude == latitude &&
            cachedWeather.location.longitude == longitude) {
          developer.log('Using cached weather data');
          return cachedWeather;
        }
      }

      // Get API keys
      final settings = _storage.getUserSettings();
      final apiKeys = _getAvailableApiKeys(settings);
      
      if (apiKeys.isEmpty) {
        developer.log('No API keys available');
        return null;
      }

      // Try to fetch weather data
      WeatherData? weatherData;
      for (int attempt = 0; attempt < apiKeys.length; attempt++) {
        final apiKey = apiKeys[_currentApiKeyIndex % apiKeys.length];
        
        try {
          weatherData = await _fetchWeatherData(
            latitude: latitude,
            longitude: longitude,
            locationName: locationName,
            apiKey: apiKey,
          );
          
          if (weatherData != null) {
            // Cache the successful result
            await _storage.saveWeatherCache(weatherData);
            developer.log('Weather data fetched and cached successfully');
            return weatherData;
          }
        } catch (e) {
          developer.log('API key failed: $apiKey, error: $e');
          _currentApiKeyIndex = (_currentApiKeyIndex + 1) % apiKeys.length;
          
          // If this was the last attempt, rethrow the error
          if (attempt == apiKeys.length - 1) {
            rethrow;
          }
        }
      }

      return null;
    } catch (e) {
      developer.log('Failed to get current weather: $e');
      return null;
    }
  }

  // Fetch weather data from OpenWeatherMap API
  Future<WeatherData?> _fetchWeatherData({
    required double latitude,
    required double longitude,
    String? locationName,
    required String apiKey,
  }) async {
    final url = Uri.parse(
      '${AppConstants.weatherBaseUrl}/weather'
      '?lat=$latitude'
      '&lon=$longitude'
      '&appid=$apiKey'
      '&units=metric'
      '&lang=vi'
    );

    final response = await http.get(url).timeout(AppConstants.apiTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseWeatherData(data, locationName);
    } else if (response.statusCode == 401) {
      throw Exception('Invalid API key');
    } else if (response.statusCode == 429) {
      throw Exception('API rate limit exceeded');
    } else {
      throw Exception('Weather API error: ${response.statusCode}');
    }
  }

  // Parse OpenWeatherMap API response
  WeatherData _parseWeatherData(Map<String, dynamic> data, String? locationName) {
    final main = data['main'] as Map<String, dynamic>;
    final weather = (data['weather'] as List).first as Map<String, dynamic>;
    final wind = data['wind'] as Map<String, dynamic>? ?? {};
    final sys = data['sys'] as Map<String, dynamic>;
    final coord = data['coord'] as Map<String, dynamic>;

    final location = WeatherLocation(
      latitude: (coord['lat'] as num).toDouble(),
      longitude: (coord['lon'] as num).toDouble(),
      name: locationName ?? data['name'] as String,
    );

    final weatherData = WeatherData(
      location: location,
      condition: WeatherCondition.fromOpenWeatherMap(weather['main'] as String),
      description: weather['description'] as String,
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      humidity: (main['humidity'] as num).toDouble(),
      pressure: (main['pressure'] as num).toDouble(),
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      windDirection: (wind['deg'] as num?)?.toDouble(),
      visibility: (data['visibility'] as num?)?.toDouble() ?? 10000.0,
      timestamp: DateTime.now(),
      sunrise: DateTime.fromMillisecondsSinceEpoch(
        (sys['sunrise'] as int) * 1000,
      ),
      sunset: DateTime.fromMillisecondsSinceEpoch(
        (sys['sunset'] as int) * 1000,
      ),
      iconCode: weather['icon'] as String,
    );

    // Generate alerts based on weather conditions
    final alerts = weatherData.generateAlerts();
    return weatherData.copyWith(alerts: alerts);
  }

  // Check weather for alerts (called ~1 hour before departure)
  Future<void> checkWeatherAlerts({
    required UserSettings settings,
    required DateTime departureTime,
  }) async {
    if (!settings.enableWeatherAlerts || !settings.enableNotifications) {
      return;
    }

    try {
      final alerts = <WeatherAlert>[];

      // Check weather at home location (for departure)
      if (settings.homeLocation != null) {
        final homeWeather = await getCurrentWeather(
          latitude: settings.homeLocation!.latitude,
          longitude: settings.homeLocation!.longitude,
          locationName: settings.homeLocation!.name,
          forceRefresh: true,
        );

        if (homeWeather != null && homeWeather.severity != WeatherSeverity.normal) {
          alerts.addAll(homeWeather.alerts.map((alert) => alert.copyWith(
            title: 'Thời tiết tại nhà: ${alert.title}',
            message: 'Lúc đi làm: ${alert.message}',
          )));
        }
      }

      // Check weather at work location (for return trip)
      if (settings.workLocation != null && !settings.useSingleLocation) {
        final workWeather = await getCurrentWeather(
          latitude: settings.workLocation!.latitude,
          longitude: settings.workLocation!.longitude,
          locationName: settings.workLocation!.name,
          forceRefresh: true,
        );

        if (workWeather != null && workWeather.severity != WeatherSeverity.normal) {
          alerts.addAll(workWeather.alerts.map((alert) => alert.copyWith(
            title: 'Thời tiết tại công ty: ${alert.title}',
            message: 'Lúc tan làm: ${alert.message}',
          )));
        }
      }

      // Send notifications for severe alerts
      for (final alert in alerts) {
        if (alert.severity == WeatherSeverity.severe || 
            alert.severity == WeatherSeverity.extreme) {
          await _notifications.showWeatherAlert(
            title: alert.title,
            message: alert.message + (alert.actionSuggestion != null 
                ? '\n💡 ${alert.actionSuggestion}'
                : ''),
            severity: alert.severity.value,
          );
        }
      }

      developer.log('Weather alerts checked: ${alerts.length} alerts found');
    } catch (e) {
      developer.log('Failed to check weather alerts: $e');
    }
  }

  // Test API key
  Future<bool> testApiKey(String apiKey) async {
    try {
      // Use a known location (Hanoi) for testing
      final url = Uri.parse(
        '${AppConstants.weatherBaseUrl}/weather'
        '?lat=21.0285&lon=105.8542'
        '&appid=$apiKey'
        '&units=metric'
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      return response.statusCode == 200;
    } catch (e) {
      developer.log('API key test failed: $e');
      return false;
    }
  }

  // Get available API keys
  List<String> _getAvailableApiKeys(UserSettings settings) {
    final keys = <String>[];
    
    // Add user's custom API key first
    if (settings.weatherApiKey != null && settings.weatherApiKey!.isNotEmpty) {
      keys.add(settings.weatherApiKey!);
    }
    
    // Add user's additional API keys
    keys.addAll(settings.weatherApiKeys);
    
    // Add default API keys as fallback
    keys.addAll(_defaultApiKeys);
    
    return keys.toSet().toList(); // Remove duplicates
  }

  // Get weather forecast (3-hour intervals for next 5 days)
  Future<List<WeatherData>?> getWeatherForecast({
    required double latitude,
    required double longitude,
    String? locationName,
  }) async {
    try {
      final settings = _storage.getUserSettings();
      final apiKeys = _getAvailableApiKeys(settings);
      
      if (apiKeys.isEmpty) {
        developer.log('No API keys available for forecast');
        return null;
      }

      final apiKey = apiKeys[_currentApiKeyIndex % apiKeys.length];
      
      final url = Uri.parse(
        '${AppConstants.weatherBaseUrl}/forecast'
        '?lat=$latitude'
        '&lon=$longitude'
        '&appid=$apiKey'
        '&units=metric'
        '&lang=vi'
      );

      final response = await http.get(url).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = data['list'] as List;
        
        return list.map((item) {
          final itemData = item as Map<String, dynamic>;
          return _parseWeatherData(itemData, locationName);
        }).toList();
      } else {
        throw Exception('Forecast API error: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Failed to get weather forecast: $e');
      return null;
    }
  }

  // Clear weather cache
  Future<void> clearCache() async {
    await _storage.clearWeatherCache();
    developer.log('Weather cache cleared');
  }

  // Get cache age
  Duration? getCacheAge() {
    try {
      final jsonString = _storage.getString(AppConstants.keyWeatherCache);
      if (jsonString != null) {
        final cacheData = jsonDecode(jsonString) as Map<String, dynamic>;
        final timestamp = DateTime.parse(cacheData['timestamp'] as String);
        return DateTime.now().difference(timestamp);
      }
    } catch (e) {
      developer.log('Failed to get cache age: $e');
    }
    return null;
  }
}

// Extension to add copyWith method to WeatherAlert
extension WeatherAlertExtension on WeatherAlert {
  WeatherAlert copyWith({
    String? id,
    String? title,
    String? message,
    WeatherSeverity? severity,
    DateTime? timestamp,
    DateTime? expiresAt,
    WeatherCondition? relatedCondition,
    String? actionSuggestion,
  }) {
    return WeatherAlert(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
      expiresAt: expiresAt ?? this.expiresAt,
      relatedCondition: relatedCondition ?? this.relatedCondition,
      actionSuggestion: actionSuggestion ?? this.actionSuggestion,
    );
  }
}
