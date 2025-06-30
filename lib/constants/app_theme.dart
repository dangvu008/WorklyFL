import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryDarkColor = Color(0xFF1976D2);
  static const Color accentColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color successColor = Color(0xFF4CAF50);
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF000000);
  static const Color lightOnBackground = Color(0xFF000000);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  
  // Card Colors
  static const Color lightCardColor = Color(0xFFFFFFFF);
  static const Color darkCardColor = Color(0xFF2C2C2C);
  
  // Border Colors
  static const Color lightBorderColor = Color(0xFFE0E0E0);
  static const Color darkBorderColor = Color(0xFF404040);

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBackground,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: lightSurface,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: lightOnSurface,
        onError: Colors.white,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: lightCardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: lightTextPrimary),
        bodyMedium: TextStyle(color: lightTextPrimary),
        bodySmall: TextStyle(color: lightTextSecondary),
        labelLarge: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: lightTextSecondary),
        labelSmall: TextStyle(color: lightTextSecondary),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackground,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: darkSurface,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: darkOnSurface,
        onError: Colors.white,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: darkCardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: darkTextPrimary),
        bodyMedium: TextStyle(color: darkTextPrimary),
        bodySmall: TextStyle(color: darkTextSecondary),
        labelLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: darkTextSecondary),
        labelSmall: TextStyle(color: darkTextSecondary),
      ),
    );
  }
}

// App Constants
class AppConstants {
  // App Info
  static const String appName = 'Workly';
  static const String appVersion = '1.0.0';
  
  // API
  static const String weatherApiKey = 'f579dc21602c95c0fb90bdd68e7427c4';
  static const String weatherBaseUrl = 'https://api.openweathermap.org/data/2.5';
  
  // Storage Keys
  static const String keyUserSettings = 'user_settings';
  static const String keyShifts = 'shifts';
  static const String keyAttendanceLogs = 'attendance_logs';
  static const String keyNotes = 'notes';
  static const String keyWeatherCache = 'weather_cache';
  
  // Notification IDs
  static const int notificationIdReminder = 1000;
  static const int notificationIdWeatherAlert = 2000;
  static const int notificationIdShiftAlert = 3000;
  
  // Durations
  static const Duration weatherCacheDuration = Duration(hours: 2);
  static const Duration locationTimeout = Duration(seconds: 30);
  static const Duration apiTimeout = Duration(seconds: 15);
  
  // Distances (in meters)
  static const double nearbyLocationThreshold = 20000; // 20km
  static const double workLocationRadius = 500; // 500m
  
  // UI
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}
