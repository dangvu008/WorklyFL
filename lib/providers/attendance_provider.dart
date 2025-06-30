import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/attendance_log.dart';
import '../models/weather_data.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;
  final LocationService _location = LocationService.instance;
  final NotificationService _notifications = NotificationService.instance;
  final Uuid _uuid = const Uuid();
  
  List<AttendanceLog> _logs = [];
  bool _isLoading = false;
  String? _error;
  AttendanceAction? _currentAction;
  DateTime? _currentWorkDate;

  // Getters
  List<AttendanceLog> get logs => List.unmodifiable(_logs);
  bool get isLoading => _isLoading;
  String? get error => _error;
  AttendanceAction? get currentAction => _currentAction;
  DateTime? get currentWorkDate => _currentWorkDate;
  bool get hasLogs => _logs.isNotEmpty;

  AttendanceProvider() {
    _loadLogs();
    _determineCurrentAction();
  }

  // Load logs from storage
  Future<void> _loadLogs() async {
    try {
      _setLoading(true);
      _logs = _storage.getAttendanceLogs();
      developer.log('Loaded ${_logs.length} attendance logs');
    } catch (e) {
      _setError('Failed to load attendance logs: $e');
      developer.log('Failed to load attendance logs: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Save logs to storage
  Future<bool> _saveLogs() async {
    try {
      final success = await _storage.saveAttendanceLogs(_logs);
      if (success) {
        developer.log('Attendance logs saved successfully');
      } else {
        _setError('Failed to save attendance logs');
      }
      return success;
    } catch (e) {
      _setError('Failed to save attendance logs: $e');
      developer.log('Failed to save attendance logs: $e');
      return false;
    }
  }

  // Determine current action based on today's logs
  void _determineCurrentAction() {
    final today = DateTime.now();
    final todayLogs = getLogsForDate(today);
    
    if (todayLogs.isEmpty) {
      _currentAction = AttendanceAction.goToWork;
      _currentWorkDate = today;
    } else {
      // Sort logs by timestamp
      todayLogs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final lastAction = todayLogs.last.action;
      
      switch (lastAction) {
        case AttendanceAction.goToWork:
          _currentAction = AttendanceAction.checkIn;
          break;
        case AttendanceAction.checkIn:
          _currentAction = AttendanceAction.signWork;
          break;
        case AttendanceAction.signWork:
          _currentAction = AttendanceAction.checkOut;
          break;
        case AttendanceAction.checkOut:
          _currentAction = AttendanceAction.complete;
          break;
        case AttendanceAction.complete:
          _currentAction = null; // Work day completed
          break;
      }
      _currentWorkDate = today;
    }
    
    notifyListeners();
  }

  // Get logs for a specific date
  List<AttendanceLog> getLogsForDate(DateTime date) {
    return _logs.where((log) => 
      log.date.year == date.year &&
      log.date.month == date.month &&
      log.date.day == date.day
    ).toList();
  }

  // Get logs for a date range
  List<AttendanceLog> getLogsForDateRange(DateTime startDate, DateTime endDate) {
    return _logs.where((log) => 
      log.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
      log.date.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();
  }

  // Get daily work status for a date
  DailyWorkStatus getDailyWorkStatus(DateTime date, {String? shiftId}) {
    final dayLogs = getLogsForDate(date);
    return DailyWorkStatus.fromLogs(date, dayLogs, shiftId: shiftId);
  }

  // Get weekly work status
  List<DailyWorkStatus> getWeeklyWorkStatus(DateTime weekStart, {String? shiftId}) {
    final weeklyStatus = <DailyWorkStatus>[];
    
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      weeklyStatus.add(getDailyWorkStatus(date, shiftId: shiftId));
    }
    
    return weeklyStatus;
  }

  // Perform attendance action
  Future<bool> performAttendanceAction({
    required AttendanceAction action,
    required String shiftId,
    String? notes,
    bool requireLocation = false,
  }) async {
    try {
      _setLoading(true);
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      double? latitude;
      double? longitude;
      String? locationName;

      // Get location if required or if auto-detection is enabled
      final settings = _storage.getUserSettings();
      if (requireLocation || settings.autoLocationDetection) {
        final position = await _location.getCurrentPosition();
        if (position != null) {
          latitude = position.latitude;
          longitude = position.longitude;
          locationName = await _location.getAddressFromCoordinates(
            latitude: latitude,
            longitude: longitude,
          );
        } else if (requireLocation) {
          _setError('Không thể lấy vị trí hiện tại');
          return false;
        }
      }

      // Create attendance log
      final log = AttendanceLog(
        id: _uuid.v4(),
        shiftId: shiftId,
        date: today,
        action: action,
        timestamp: now,
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
        notes: notes,
      );

      // Add to logs
      _logs.add(log);
      
      // Update current action
      _determineCurrentAction();
      
      // Save to storage
      final success = await _saveLogs();
      if (success) {
        developer.log('Attendance action performed: ${action.displayName}');
        
        // Handle location setup for first-time actions
        await _handleLocationSetup(action, latitude, longitude, locationName);
        
        // Schedule next reminder if applicable
        await _scheduleNextReminder(shiftId, action);
      }
      
      return success;
    } catch (e) {
      _setError('Failed to perform attendance action: $e');
      developer.log('Failed to perform attendance action: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Handle location setup for first-time actions
  Future<void> _handleLocationSetup(
    AttendanceAction action,
    double? latitude,
    double? longitude,
    String? locationName,
  ) async {
    if (latitude == null || longitude == null) return;
    
    final settings = _storage.getUserSettings();
    
    // Set home location on first "Go to Work"
    if (action == AttendanceAction.goToWork && settings.homeLocation == null) {
      final homeLocation = WeatherLocation(
        latitude: latitude,
        longitude: longitude,
        name: locationName ?? 'Nhà',
        address: locationName,
      );
      
      // Update settings through AppProvider would be better, but for now:
      final updatedSettings = settings.copyWith(homeLocation: homeLocation);
      await _storage.saveUserSettings(updatedSettings);
      
      developer.log('Home location set: ${homeLocation.name}');
    }
    
    // Set work location on first "Check In"
    if (action == AttendanceAction.checkIn && settings.workLocation == null) {
      final workLocation = WeatherLocation(
        latitude: latitude,
        longitude: longitude,
        name: locationName ?? 'Công ty',
        address: locationName,
      );
      
      // Check if home and work are nearby
      bool useSingleLocation = false;
      if (settings.homeLocation != null) {
        final distance = _location.calculateDistance(
          lat1: settings.homeLocation!.latitude,
          lon1: settings.homeLocation!.longitude,
          lat2: latitude,
          lon2: longitude,
        );
        
        if (distance < 20000) { // 20km
          useSingleLocation = true;
        }
      }
      
      final updatedSettings = settings.copyWith(
        workLocation: workLocation,
        useSingleLocation: useSingleLocation,
      );
      await _storage.saveUserSettings(updatedSettings);
      
      developer.log('Work location set: ${workLocation.name}');
      if (useSingleLocation) {
        developer.log('Single location mode enabled (locations are nearby)');
      }
    }
  }

  // Schedule next reminder
  Future<void> _scheduleNextReminder(String shiftId, AttendanceAction completedAction) async {
    try {
      final settings = _storage.getUserSettings();

      // Only schedule if notifications are enabled
      if (!settings.enableNotifications || !settings.enableShiftReminders) {
        return;
      }

      // Get shift information (assuming we have access to shift data)
      // For now, we'll schedule a generic reminder based on the completed action
      final now = DateTime.now();
      DateTime nextReminderTime;
      String reminderTitle;
      String reminderBody;

      switch (completedAction) {
        case AttendanceAction.goToWork:
          // Remind to check in after arriving at work (e.g., 30 minutes later)
          nextReminderTime = now.add(const Duration(minutes: 30));
          reminderTitle = 'Nhắc nhở chấm công';
          reminderBody = 'Đừng quên chấm công vào khi đã đến nơi làm việc!';
          break;
        case AttendanceAction.checkIn:
          // Remind to sign work after check in (e.g., 5 minutes later)
          nextReminderTime = now.add(const Duration(minutes: 5));
          reminderTitle = 'Nhắc nhở ký tên';
          reminderBody = 'Hãy ký tên xác nhận bắt đầu làm việc!';
          break;
        case AttendanceAction.signWork:
          // Remind to check out at end of work day (e.g., 8 hours later)
          nextReminderTime = now.add(const Duration(hours: 8));
          reminderTitle = 'Nhắc nhở chấm công ra';
          reminderBody = 'Đã đến giờ kết thúc ca làm việc. Hãy chấm công ra!';
          break;
        case AttendanceAction.checkOut:
          // Remind to complete work day (e.g., 5 minutes later)
          nextReminderTime = now.add(const Duration(minutes: 5));
          reminderTitle = 'Hoàn thành ca làm việc';
          reminderBody = 'Hãy xác nhận hoàn thành ca làm việc hôm nay!';
          break;
        case AttendanceAction.complete:
          // No next reminder needed - work day is complete
          return;
      }

      // Generate unique notification ID based on shift and action
      final notificationId = shiftId.hashCode + completedAction.index + now.millisecondsSinceEpoch;

      await _notifications.scheduleNotification(
        id: notificationId,
        title: reminderTitle,
        body: reminderBody,
        scheduledDate: nextReminderTime,
        payload: 'attendance_reminder:$shiftId:${completedAction.name}',
        priority: NotificationPriority.normal,
      );

      developer.log('Scheduled next reminder for ${completedAction.displayName} at $nextReminderTime');
    } catch (e) {
      developer.log('Failed to schedule next reminder: $e');
    }
  }

  // Update attendance log
  Future<bool> updateAttendanceLog(AttendanceLog updatedLog) async {
    try {
      final index = _logs.indexWhere((log) => log.id == updatedLog.id);
      if (index == -1) {
        _setError('Attendance log not found');
        return false;
      }

      _logs[index] = updatedLog;
      notifyListeners();
      
      final success = await _saveLogs();
      if (success) {
        developer.log('Attendance log updated: ${updatedLog.action.displayName}');
      }
      return success;
    } catch (e) {
      _setError('Failed to update attendance log: $e');
      developer.log('Failed to update attendance log: $e');
      return false;
    }
  }

  // Delete attendance log
  Future<bool> deleteAttendanceLog(String logId) async {
    try {
      final index = _logs.indexWhere((log) => log.id == logId);
      if (index == -1) {
        _setError('Attendance log not found');
        return false;
      }

      final log = _logs[index];
      _logs.removeAt(index);
      
      // Recalculate current action
      _determineCurrentAction();
      
      final success = await _saveLogs();
      if (success) {
        developer.log('Attendance log deleted: ${log.action.displayName}');
      }
      return success;
    } catch (e) {
      _setError('Failed to delete attendance log: $e');
      developer.log('Failed to delete attendance log: $e');
      return false;
    }
  }

  // Get attendance statistics
  Map<String, dynamic> getAttendanceStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final filteredLogs = startDate != null && endDate != null
        ? getLogsForDateRange(startDate, endDate)
        : _logs;

    final stats = <String, dynamic>{
      'totalLogs': filteredLogs.length,
      'workDays': <String>{},
      'actionCounts': <String, int>{},
      'averageWorkTime': 0.0,
      'totalWorkTime': 0.0,
      'onTimePercentage': 0.0,
      'lateCount': 0,
      'earlyCount': 0,
    };

    if (filteredLogs.isEmpty) return stats;

    // Count actions and work days
    for (final log in filteredLogs) {
      final dateKey = '${log.date.year}-${log.date.month}-${log.date.day}';
      stats['workDays'].add(dateKey);
      
      final actionName = log.action.displayName;
      stats['actionCounts'][actionName] = (stats['actionCounts'][actionName] ?? 0) + 1;
      
      // Count status types
      switch (log.status) {
        case AttendanceStatus.late:
          stats['lateCount']++;
          break;
        case AttendanceStatus.early:
          stats['earlyCount']++;
          break;
        default:
          break;
      }
    }

    // Calculate work time statistics
    final workDays = (stats['workDays'] as Set<String>).length;
    stats['workDays'] = workDays;

    // Calculate on-time percentage
    final totalCheckIns = stats['actionCounts']['Chấm Công Vào'] ?? 0;
    if (totalCheckIns > 0) {
      final onTimeCount = totalCheckIns - stats['lateCount'];
      stats['onTimePercentage'] = (onTimeCount / totalCheckIns) * 100;
    }

    return stats;
  }

  // Search logs
  List<AttendanceLog> searchLogs(String query) {
    if (query.isEmpty) return _logs;
    
    final lowerQuery = query.toLowerCase();
    return _logs.where((log) {
      return log.action.displayName.toLowerCase().contains(lowerQuery) ||
             log.locationName?.toLowerCase().contains(lowerQuery) == true ||
             log.notes?.toLowerCase().contains(lowerQuery) == true;
    }).toList();
  }

  // Refresh logs from storage
  Future<void> refreshLogs() async {
    await _loadLogs();
    _determineCurrentAction();
  }

  // Clear all logs
  Future<bool> clearAllLogs() async {
    try {
      _logs.clear();
      _determineCurrentAction();
      
      final success = await _saveLogs();
      if (success) {
        developer.log('All attendance logs cleared');
      }
      return success;
    } catch (e) {
      _setError('Failed to clear attendance logs: $e');
      developer.log('Failed to clear attendance logs: $e');
      return false;
    }
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
