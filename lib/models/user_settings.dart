import 'dart:convert';
import 'package:flutter/material.dart';
import 'weather_data.dart';

enum NotificationFrequency {
  never('Không bao giờ', 'never'),
  important('Chỉ quan trọng', 'important'),
  normal('Bình thường', 'normal'),
  all('Tất cả', 'all');

  const NotificationFrequency(this.displayName, this.value);
  final String displayName;
  final String value;

  static NotificationFrequency fromString(String value) {
    return NotificationFrequency.values.firstWhere(
      (freq) => freq.value == value,
      orElse: () => NotificationFrequency.normal,
    );
  }
}

class UserSettings {
  // App Settings
  final bool isDarkMode;
  final String language;
  final double textScale;
  final bool enableHapticFeedback;
  final bool enableSounds;
  
  // Notification Settings
  final bool enableNotifications;
  final NotificationFrequency notificationFrequency;
  final bool enableWeatherAlerts;
  final bool enableShiftReminders;
  final bool enableAttendanceReminders;
  final int reminderMinutesBefore;
  final bool enableAlarmMode; // Bypass silent mode
  
  // Work Settings
  final String? currentShiftId;
  final bool simpleMode; // Only show "Go to Work" button
  final double hourlyRate;
  final String currency;
  final bool autoLocationDetection;
  final bool requireLocationForAttendance;
  
  // Weather Settings
  final bool enableWeatherWidget;
  final String? weatherApiKey;
  final List<String> weatherApiKeys;
  final WeatherLocation? homeLocation;
  final WeatherLocation? workLocation;
  final bool useSingleLocation;
  final int weatherCacheHours;
  final bool enableWeatherNotifications;
  
  // Privacy Settings
  final bool enableLocationHistory;
  final bool enableDataExport;
  final bool enableAnalytics;
  
  // Advanced Settings
  final bool enableDebugMode;
  final bool enableBetaFeatures;
  final int dataRetentionDays;
  final bool autoBackup;
  final String? backupPath;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSettings({
    // App Settings
    this.isDarkMode = false,
    this.language = 'vi',
    this.textScale = 1.0,
    this.enableHapticFeedback = true,
    this.enableSounds = true,
    
    // Notification Settings
    this.enableNotifications = true,
    this.notificationFrequency = NotificationFrequency.normal,
    this.enableWeatherAlerts = true,
    this.enableShiftReminders = true,
    this.enableAttendanceReminders = true,
    this.reminderMinutesBefore = 30,
    this.enableAlarmMode = false,
    
    // Work Settings
    this.currentShiftId,
    this.simpleMode = false,
    this.hourlyRate = 50000.0, // VND per hour
    this.currency = 'VND',
    this.autoLocationDetection = true,
    this.requireLocationForAttendance = false,
    
    // Weather Settings
    this.enableWeatherWidget = true,
    this.weatherApiKey,
    this.weatherApiKeys = const [],
    this.homeLocation,
    this.workLocation,
    this.useSingleLocation = false,
    this.weatherCacheHours = 2,
    this.enableWeatherNotifications = true,
    
    // Privacy Settings
    this.enableLocationHistory = true,
    this.enableDataExport = true,
    this.enableAnalytics = false,
    
    // Advanced Settings
    this.enableDebugMode = false,
    this.enableBetaFeatures = false,
    this.dataRetentionDays = 365,
    this.autoBackup = true,
    this.backupPath,
    
    // Timestamps
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Helper getters
  ThemeMode get themeMode {
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  String get formattedHourlyRate {
    if (currency == 'VND') {
      return '${hourlyRate.toStringAsFixed(0)} ₫';
    } else {
      return '${hourlyRate.toStringAsFixed(2)} $currency';
    }
  }

  bool get hasWeatherApiKey {
    return weatherApiKey != null && weatherApiKey!.isNotEmpty;
  }

  bool get hasWeatherLocations {
    return homeLocation != null || workLocation != null;
  }

  bool get canShowWeather {
    return enableWeatherWidget && (hasWeatherApiKey || weatherApiKeys.isNotEmpty);
  }

  List<String> get allWeatherApiKeys {
    final keys = <String>[];
    if (weatherApiKey != null && weatherApiKey!.isNotEmpty) {
      keys.add(weatherApiKey!);
    }
    keys.addAll(weatherApiKeys);
    return keys;
  }

  // Copy with modifications
  UserSettings copyWith({
    // App Settings
    bool? isDarkMode,
    String? language,
    double? textScale,
    bool? enableHapticFeedback,
    bool? enableSounds,
    
    // Notification Settings
    bool? enableNotifications,
    NotificationFrequency? notificationFrequency,
    bool? enableWeatherAlerts,
    bool? enableShiftReminders,
    bool? enableAttendanceReminders,
    int? reminderMinutesBefore,
    bool? enableAlarmMode,
    
    // Work Settings
    String? currentShiftId,
    bool? simpleMode,
    double? hourlyRate,
    String? currency,
    bool? autoLocationDetection,
    bool? requireLocationForAttendance,
    
    // Weather Settings
    bool? enableWeatherWidget,
    String? weatherApiKey,
    List<String>? weatherApiKeys,
    WeatherLocation? homeLocation,
    WeatherLocation? workLocation,
    bool? useSingleLocation,
    int? weatherCacheHours,
    bool? enableWeatherNotifications,
    
    // Privacy Settings
    bool? enableLocationHistory,
    bool? enableDataExport,
    bool? enableAnalytics,
    
    // Advanced Settings
    bool? enableDebugMode,
    bool? enableBetaFeatures,
    int? dataRetentionDays,
    bool? autoBackup,
    String? backupPath,
    
    // Timestamps
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      // App Settings
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      textScale: textScale ?? this.textScale,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      enableSounds: enableSounds ?? this.enableSounds,
      
      // Notification Settings
      enableNotifications: enableNotifications ?? this.enableNotifications,
      notificationFrequency: notificationFrequency ?? this.notificationFrequency,
      enableWeatherAlerts: enableWeatherAlerts ?? this.enableWeatherAlerts,
      enableShiftReminders: enableShiftReminders ?? this.enableShiftReminders,
      enableAttendanceReminders: enableAttendanceReminders ?? this.enableAttendanceReminders,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      enableAlarmMode: enableAlarmMode ?? this.enableAlarmMode,
      
      // Work Settings
      currentShiftId: currentShiftId ?? this.currentShiftId,
      simpleMode: simpleMode ?? this.simpleMode,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      currency: currency ?? this.currency,
      autoLocationDetection: autoLocationDetection ?? this.autoLocationDetection,
      requireLocationForAttendance: requireLocationForAttendance ?? this.requireLocationForAttendance,
      
      // Weather Settings
      enableWeatherWidget: enableWeatherWidget ?? this.enableWeatherWidget,
      weatherApiKey: weatherApiKey ?? this.weatherApiKey,
      weatherApiKeys: weatherApiKeys ?? this.weatherApiKeys,
      homeLocation: homeLocation ?? this.homeLocation,
      workLocation: workLocation ?? this.workLocation,
      useSingleLocation: useSingleLocation ?? this.useSingleLocation,
      weatherCacheHours: weatherCacheHours ?? this.weatherCacheHours,
      enableWeatherNotifications: enableWeatherNotifications ?? this.enableWeatherNotifications,
      
      // Privacy Settings
      enableLocationHistory: enableLocationHistory ?? this.enableLocationHistory,
      enableDataExport: enableDataExport ?? this.enableDataExport,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      
      // Advanced Settings
      enableDebugMode: enableDebugMode ?? this.enableDebugMode,
      enableBetaFeatures: enableBetaFeatures ?? this.enableBetaFeatures,
      dataRetentionDays: dataRetentionDays ?? this.dataRetentionDays,
      autoBackup: autoBackup ?? this.autoBackup,
      backupPath: backupPath ?? this.backupPath,
      
      // Timestamps
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      // App Settings
      'isDarkMode': isDarkMode,
      'language': language,
      'textScale': textScale,
      'enableHapticFeedback': enableHapticFeedback,
      'enableSounds': enableSounds,
      
      // Notification Settings
      'enableNotifications': enableNotifications,
      'notificationFrequency': notificationFrequency.value,
      'enableWeatherAlerts': enableWeatherAlerts,
      'enableShiftReminders': enableShiftReminders,
      'enableAttendanceReminders': enableAttendanceReminders,
      'reminderMinutesBefore': reminderMinutesBefore,
      'enableAlarmMode': enableAlarmMode,
      
      // Work Settings
      'currentShiftId': currentShiftId,
      'simpleMode': simpleMode,
      'hourlyRate': hourlyRate,
      'currency': currency,
      'autoLocationDetection': autoLocationDetection,
      'requireLocationForAttendance': requireLocationForAttendance,
      
      // Weather Settings
      'enableWeatherWidget': enableWeatherWidget,
      'weatherApiKey': weatherApiKey,
      'weatherApiKeys': weatherApiKeys,
      'homeLocation': homeLocation?.toJson(),
      'workLocation': workLocation?.toJson(),
      'useSingleLocation': useSingleLocation,
      'weatherCacheHours': weatherCacheHours,
      'enableWeatherNotifications': enableWeatherNotifications,
      
      // Privacy Settings
      'enableLocationHistory': enableLocationHistory,
      'enableDataExport': enableDataExport,
      'enableAnalytics': enableAnalytics,
      
      // Advanced Settings
      'enableDebugMode': enableDebugMode,
      'enableBetaFeatures': enableBetaFeatures,
      'dataRetentionDays': dataRetentionDays,
      'autoBackup': autoBackup,
      'backupPath': backupPath,
      
      // Timestamps
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      // App Settings
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      language: json['language'] as String? ?? 'vi',
      textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
      enableHapticFeedback: json['enableHapticFeedback'] as bool? ?? true,
      enableSounds: json['enableSounds'] as bool? ?? true,
      
      // Notification Settings
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      notificationFrequency: NotificationFrequency.fromString(
        json['notificationFrequency'] as String? ?? 'normal'
      ),
      enableWeatherAlerts: json['enableWeatherAlerts'] as bool? ?? true,
      enableShiftReminders: json['enableShiftReminders'] as bool? ?? true,
      enableAttendanceReminders: json['enableAttendanceReminders'] as bool? ?? true,
      reminderMinutesBefore: json['reminderMinutesBefore'] as int? ?? 30,
      enableAlarmMode: json['enableAlarmMode'] as bool? ?? false,
      
      // Work Settings
      currentShiftId: json['currentShiftId'] as String?,
      simpleMode: json['simpleMode'] as bool? ?? false,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 50000.0,
      currency: json['currency'] as String? ?? 'VND',
      autoLocationDetection: json['autoLocationDetection'] as bool? ?? true,
      requireLocationForAttendance: json['requireLocationForAttendance'] as bool? ?? false,
      
      // Weather Settings
      enableWeatherWidget: json['enableWeatherWidget'] as bool? ?? true,
      weatherApiKey: json['weatherApiKey'] as String?,
      weatherApiKeys: List<String>.from(json['weatherApiKeys'] as List? ?? []),
      homeLocation: json['homeLocation'] != null 
          ? WeatherLocation.fromJson(json['homeLocation'] as Map<String, dynamic>)
          : null,
      workLocation: json['workLocation'] != null 
          ? WeatherLocation.fromJson(json['workLocation'] as Map<String, dynamic>)
          : null,
      useSingleLocation: json['useSingleLocation'] as bool? ?? false,
      weatherCacheHours: json['weatherCacheHours'] as int? ?? 2,
      enableWeatherNotifications: json['enableWeatherNotifications'] as bool? ?? true,
      
      // Privacy Settings
      enableLocationHistory: json['enableLocationHistory'] as bool? ?? true,
      enableDataExport: json['enableDataExport'] as bool? ?? true,
      enableAnalytics: json['enableAnalytics'] as bool? ?? false,
      
      // Advanced Settings
      enableDebugMode: json['enableDebugMode'] as bool? ?? false,
      enableBetaFeatures: json['enableBetaFeatures'] as bool? ?? false,
      dataRetentionDays: json['dataRetentionDays'] as int? ?? 365,
      autoBackup: json['autoBackup'] as bool? ?? true,
      backupPath: json['backupPath'] as String?,
      
      // Timestamps
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserSettings.fromJsonString(String jsonString) {
    return UserSettings.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'UserSettings(language: $language, darkMode: $isDarkMode, currentShift: $currentShiftId)';
  }
}
