import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_theme.dart';
import '../models/user_settings.dart';
import '../models/shift.dart';
import '../models/attendance_log.dart';
import '../models/note.dart';
import '../models/weather_data.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  
  StorageService._();
  
  SharedPreferences? _prefs;
  
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      developer.log('StorageService initialized successfully');
    } catch (e) {
      developer.log('Failed to initialize StorageService: $e');
      rethrow;
    }
  }
  
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Generic methods
  Future<bool> setString(String key, String value) async {
    try {
      return await prefs.setString(key, value);
    } catch (e) {
      developer.log('Failed to set string for key $key: $e');
      return false;
    }
  }

  String? getString(String key, {String? defaultValue}) {
    try {
      return prefs.getString(key) ?? defaultValue;
    } catch (e) {
      developer.log('Failed to get string for key $key: $e');
      return defaultValue;
    }
  }

  Future<bool> setBool(String key, bool value) async {
    try {
      return await prefs.setBool(key, value);
    } catch (e) {
      developer.log('Failed to set bool for key $key: $e');
      return false;
    }
  }

  bool getBool(String key, {bool defaultValue = false}) {
    try {
      return prefs.getBool(key) ?? defaultValue;
    } catch (e) {
      developer.log('Failed to get bool for key $key: $e');
      return defaultValue;
    }
  }

  Future<bool> setInt(String key, int value) async {
    try {
      return await prefs.setInt(key, value);
    } catch (e) {
      developer.log('Failed to set int for key $key: $e');
      return false;
    }
  }

  int getInt(String key, {int defaultValue = 0}) {
    try {
      return prefs.getInt(key) ?? defaultValue;
    } catch (e) {
      developer.log('Failed to get int for key $key: $e');
      return defaultValue;
    }
  }

  Future<bool> setDouble(String key, double value) async {
    try {
      return await prefs.setDouble(key, value);
    } catch (e) {
      developer.log('Failed to set double for key $key: $e');
      return false;
    }
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    try {
      return prefs.getDouble(key) ?? defaultValue;
    } catch (e) {
      developer.log('Failed to get double for key $key: $e');
      return defaultValue;
    }
  }

  Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await prefs.setStringList(key, value);
    } catch (e) {
      developer.log('Failed to set string list for key $key: $e');
      return false;
    }
  }

  List<String> getStringList(String key, {List<String>? defaultValue}) {
    try {
      return prefs.getStringList(key) ?? defaultValue ?? [];
    } catch (e) {
      developer.log('Failed to get string list for key $key: $e');
      return defaultValue ?? [];
    }
  }

  Future<bool> remove(String key) async {
    try {
      return await prefs.remove(key);
    } catch (e) {
      developer.log('Failed to remove key $key: $e');
      return false;
    }
  }

  Future<bool> clear() async {
    try {
      return await prefs.clear();
    } catch (e) {
      developer.log('Failed to clear storage: $e');
      return false;
    }
  }

  // User Settings
  Future<bool> saveUserSettings(UserSettings settings) async {
    try {
      final jsonString = settings.toJsonString();
      return await setString(AppConstants.keyUserSettings, jsonString);
    } catch (e) {
      developer.log('Failed to save user settings: $e');
      return false;
    }
  }

  UserSettings getUserSettings() {
    try {
      final jsonString = getString(AppConstants.keyUserSettings);
      if (jsonString != null) {
        return UserSettings.fromJsonString(jsonString);
      }
    } catch (e) {
      developer.log('Failed to get user settings: $e');
    }
    return UserSettings(); // Return default settings
  }

  // Shifts
  Future<bool> saveShifts(List<Shift> shifts) async {
    try {
      final jsonList = shifts.map((shift) => shift.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await setString(AppConstants.keyShifts, jsonString);
    } catch (e) {
      developer.log('Failed to save shifts: $e');
      return false;
    }
  }

  List<Shift> getShifts() {
    try {
      final jsonString = getString(AppConstants.keyShifts);
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List;
        return jsonList.map((json) => Shift.fromJson(json)).toList();
      }
    } catch (e) {
      developer.log('Failed to get shifts: $e');
    }
    return [];
  }

  Future<bool> saveShift(Shift shift) async {
    try {
      final shifts = getShifts();
      final index = shifts.indexWhere((s) => s.id == shift.id);
      
      if (index >= 0) {
        shifts[index] = shift;
      } else {
        shifts.add(shift);
      }
      
      return await saveShifts(shifts);
    } catch (e) {
      developer.log('Failed to save shift: $e');
      return false;
    }
  }

  Future<bool> deleteShift(String shiftId) async {
    try {
      final shifts = getShifts();
      shifts.removeWhere((shift) => shift.id == shiftId);
      return await saveShifts(shifts);
    } catch (e) {
      developer.log('Failed to delete shift: $e');
      return false;
    }
  }

  // Attendance Logs
  Future<bool> saveAttendanceLogs(List<AttendanceLog> logs) async {
    try {
      final jsonList = logs.map((log) => log.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await setString(AppConstants.keyAttendanceLogs, jsonString);
    } catch (e) {
      developer.log('Failed to save attendance logs: $e');
      return false;
    }
  }

  List<AttendanceLog> getAttendanceLogs() {
    try {
      final jsonString = getString(AppConstants.keyAttendanceLogs);
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List;
        return jsonList.map((json) => AttendanceLog.fromJson(json)).toList();
      }
    } catch (e) {
      developer.log('Failed to get attendance logs: $e');
    }
    return [];
  }

  Future<bool> saveAttendanceLog(AttendanceLog log) async {
    try {
      final logs = getAttendanceLogs();
      final index = logs.indexWhere((l) => l.id == log.id);
      
      if (index >= 0) {
        logs[index] = log;
      } else {
        logs.add(log);
      }
      
      return await saveAttendanceLogs(logs);
    } catch (e) {
      developer.log('Failed to save attendance log: $e');
      return false;
    }
  }

  Future<bool> deleteAttendanceLog(String logId) async {
    try {
      final logs = getAttendanceLogs();
      logs.removeWhere((log) => log.id == logId);
      return await saveAttendanceLogs(logs);
    } catch (e) {
      developer.log('Failed to delete attendance log: $e');
      return false;
    }
  }

  // Notes
  Future<bool> saveNotes(List<Note> notes) async {
    try {
      final jsonList = notes.map((note) => note.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await setString(AppConstants.keyNotes, jsonString);
    } catch (e) {
      developer.log('Failed to save notes: $e');
      return false;
    }
  }

  List<Note> getNotes() {
    try {
      final jsonString = getString(AppConstants.keyNotes);
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List;
        return jsonList.map((json) => Note.fromJson(json)).toList();
      }
    } catch (e) {
      developer.log('Failed to get notes: $e');
    }
    return [];
  }

  Future<bool> saveNote(Note note) async {
    try {
      final notes = getNotes();
      final index = notes.indexWhere((n) => n.id == note.id);
      
      if (index >= 0) {
        notes[index] = note;
      } else {
        notes.add(note);
      }
      
      return await saveNotes(notes);
    } catch (e) {
      developer.log('Failed to save note: $e');
      return false;
    }
  }

  Future<bool> deleteNote(String noteId) async {
    try {
      final notes = getNotes();
      notes.removeWhere((note) => note.id == noteId);
      return await saveNotes(notes);
    } catch (e) {
      developer.log('Failed to delete note: $e');
      return false;
    }
  }

  // Weather Cache
  Future<bool> saveWeatherCache(WeatherData weatherData) async {
    try {
      final cacheData = {
        'data': weatherData.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      final jsonString = jsonEncode(cacheData);
      return await setString(AppConstants.keyWeatherCache, jsonString);
    } catch (e) {
      developer.log('Failed to save weather cache: $e');
      return false;
    }
  }

  WeatherData? getWeatherCache({Duration? maxAge}) {
    try {
      final jsonString = getString(AppConstants.keyWeatherCache);
      if (jsonString != null) {
        final cacheData = jsonDecode(jsonString) as Map<String, dynamic>;
        final timestamp = DateTime.parse(cacheData['timestamp'] as String);
        
        // Check if cache is still valid
        if (maxAge != null) {
          final age = DateTime.now().difference(timestamp);
          if (age > maxAge) {
            return null; // Cache expired
          }
        }
        
        return WeatherData.fromJson(cacheData['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      developer.log('Failed to get weather cache: $e');
    }
    return null;
  }

  Future<bool> clearWeatherCache() async {
    return await remove(AppConstants.keyWeatherCache);
  }

  // Data Export/Import
  Future<Map<String, dynamic>> exportAllData() async {
    try {
      return {
        'userSettings': getUserSettings().toJson(),
        'shifts': getShifts().map((s) => s.toJson()).toList(),
        'attendanceLogs': getAttendanceLogs().map((l) => l.toJson()).toList(),
        'notes': getNotes().map((n) => n.toJson()).toList(),
        'exportedAt': DateTime.now().toIso8601String(),
        'version': AppConstants.appVersion,
      };
    } catch (e) {
      developer.log('Failed to export data: $e');
      rethrow;
    }
  }

  Future<bool> importAllData(Map<String, dynamic> data) async {
    try {
      // Import user settings
      if (data['userSettings'] != null) {
        final settings = UserSettings.fromJson(data['userSettings']);
        await saveUserSettings(settings);
      }

      // Import shifts
      if (data['shifts'] != null) {
        final shifts = (data['shifts'] as List)
            .map((json) => Shift.fromJson(json))
            .toList();
        await saveShifts(shifts);
      }

      // Import attendance logs
      if (data['attendanceLogs'] != null) {
        final logs = (data['attendanceLogs'] as List)
            .map((json) => AttendanceLog.fromJson(json))
            .toList();
        await saveAttendanceLogs(logs);
      }

      // Import notes
      if (data['notes'] != null) {
        final notes = (data['notes'] as List)
            .map((json) => Note.fromJson(json))
            .toList();
        await saveNotes(notes);
      }

      return true;
    } catch (e) {
      developer.log('Failed to import data: $e');
      return false;
    }
  }
}
