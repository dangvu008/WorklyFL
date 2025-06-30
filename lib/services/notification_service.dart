import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../constants/app_theme.dart';
import '../models/user_settings.dart';
import '../models/shift.dart';
import '../models/note.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();
  
  NotificationService._();
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      // Android initialization
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS initialization
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      // Request permissions
      await _requestPermissions();
      
      _isInitialized = true;
      developer.log('NotificationService initialized successfully');
    } catch (e) {
      developer.log('Failed to initialize NotificationService: $e');
      rethrow;
    }
  }

  Future<void> _requestPermissions() async {
    try {
      // Android 13+ permission request
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        
        if (androidPlugin != null) {
          await androidPlugin.requestNotificationsPermission();
          await androidPlugin.requestExactAlarmsPermission();
        }
      }
      
      // iOS permission request
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        
        if (iosPlugin != null) {
          await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
        }
      }
    } catch (e) {
      developer.log('Failed to request notification permissions: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    developer.log('Notification tapped: ${response.payload}');
    // Handle notification tap - you can add navigation logic here
  }

  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationPriority priority = NotificationPriority.normal,
    bool enableVibration = true,
    bool enableSound = true,
  }) async {
    if (!_isInitialized) {
      developer.log('NotificationService not initialized');
      return;
    }

    try {
      final androidDetails = AndroidNotificationDetails(
        'workly_general',
        'Workly General',
        channelDescription: 'General notifications from Workly',
        importance: _getAndroidImportance(priority),
        priority: _getAndroidPriority(priority),
        enableVibration: enableVibration,
        playSound: enableSound,
        icon: '@mipmap/ic_launcher',
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: enableSound,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(id, title, body, details, payload: payload);
      developer.log('Notification shown: $title');
    } catch (e) {
      developer.log('Failed to show notification: $e');
    }
  }

  // Schedule notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationPriority priority = NotificationPriority.normal,
    bool enableVibration = true,
    bool enableSound = true,
    bool isAlarmMode = false,
  }) async {
    if (!_isInitialized) {
      developer.log('NotificationService not initialized');
      return;
    }

    try {
      final scheduledTz = tz.TZDateTime.from(scheduledDate, tz.local);
      
      final androidDetails = AndroidNotificationDetails(
        isAlarmMode ? 'workly_alarms' : 'workly_scheduled',
        isAlarmMode ? 'Workly Alarms' : 'Workly Scheduled',
        channelDescription: isAlarmMode 
            ? 'Important alarms from Workly that bypass Do Not Disturb'
            : 'Scheduled notifications from Workly',
        importance: isAlarmMode ? Importance.max : _getAndroidImportance(priority),
        priority: isAlarmMode ? Priority.max : _getAndroidPriority(priority),
        enableVibration: enableVibration,
        playSound: enableSound,
        icon: '@mipmap/ic_launcher',
        fullScreenIntent: isAlarmMode,
        category: isAlarmMode ? AndroidNotificationCategory.alarm : null,
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: enableSound,
        interruptionLevel: isAlarmMode 
            ? InterruptionLevel.critical 
            : InterruptionLevel.active,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTz,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      developer.log('Notification scheduled: $title at $scheduledDate');
    } catch (e) {
      developer.log('Failed to schedule notification: $e');
    }
  }

  // Schedule repeating notification
  Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required DateTime firstDate,
    required RepeatInterval repeatInterval,
    String? payload,
    NotificationPriority priority = NotificationPriority.normal,
    bool enableVibration = true,
    bool enableSound = true,
  }) async {
    if (!_isInitialized) {
      developer.log('NotificationService not initialized');
      return;
    }

    try {
      final androidDetails = AndroidNotificationDetails(
        'workly_repeating',
        'Workly Repeating',
        channelDescription: 'Repeating notifications from Workly',
        importance: _getAndroidImportance(priority),
        priority: _getAndroidPriority(priority),
        enableVibration: enableVibration,
        playSound: enableSound,
        icon: '@mipmap/ic_launcher',
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: enableSound,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.periodicallyShow(
        id,
        title,
        body,
        repeatInterval,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      developer.log('Repeating notification scheduled: $title');
    } catch (e) {
      developer.log('Failed to schedule repeating notification: $e');
    }
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      developer.log('Notification cancelled: $id');
    } catch (e) {
      developer.log('Failed to cancel notification: $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      developer.log('All notifications cancelled');
    } catch (e) {
      developer.log('Failed to cancel all notifications: $e');
    }
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      developer.log('Failed to get pending notifications: $e');
      return [];
    }
  }

  // Shift-specific notifications
  Future<void> scheduleShiftReminder({
    required Shift shift,
    required DateTime workDate,
    required UserSettings settings,
  }) async {
    if (!settings.enableShiftReminders || !settings.enableNotifications) {
      return;
    }

    final reminderTime = DateTime(
      workDate.year,
      workDate.month,
      workDate.day,
      shift.startTime.hour,
      shift.startTime.minute,
    ).subtract(Duration(minutes: settings.reminderMinutesBefore));

    if (reminderTime.isBefore(DateTime.now())) {
      return; // Don't schedule past reminders
    }

    await scheduleNotification(
      id: AppConstants.notificationIdShiftAlert + shift.id.hashCode,
      title: 'Nhắc nhở ca làm việc',
      body: 'Ca "${shift.name}" sẽ bắt đầu trong ${settings.reminderMinutesBefore} phút',
      scheduledDate: reminderTime,
      payload: 'shift_reminder:${shift.id}',
      priority: NotificationPriority.high,
      isAlarmMode: settings.enableAlarmMode,
    );
  }

  // Weather alert notification
  Future<void> showWeatherAlert({
    required String title,
    required String message,
    required String severity,
  }) async {
    final priority = severity == 'extreme' 
        ? NotificationPriority.max
        : severity == 'severe'
            ? NotificationPriority.high
            : NotificationPriority.normal;

    await showNotification(
      id: AppConstants.notificationIdWeatherAlert + DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: message,
      payload: 'weather_alert:$severity',
      priority: priority,
    );
  }

  // Note reminder notification
  Future<void> scheduleNoteReminder(Note note) async {
    if (note.reminder == null || !note.reminder!.isActive) {
      return;
    }

    final reminderTime = note.reminder!.nextReminderTime;
    if (reminderTime == null || reminderTime.isBefore(DateTime.now())) {
      return;
    }

    await scheduleNotification(
      id: note.reminder!.notificationId,
      title: 'Nhắc nhở: ${note.title}',
      body: note.content.length > 100 
          ? '${note.content.substring(0, 97)}...'
          : note.content,
      scheduledDate: reminderTime,
      payload: 'note_reminder:${note.id}',
      priority: _getNotificationPriorityFromNote(note.priority),
    );
  }

  // Helper methods
  Importance _getAndroidImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.min:
        return Importance.min;
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.normal:
        return Importance.defaultImportance;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.max:
        return Importance.max;
    }
  }

  Priority _getAndroidPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.min:
        return Priority.min;
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.normal:
        return Priority.defaultPriority;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.max:
        return Priority.max;
    }
  }

  NotificationPriority _getNotificationPriorityFromNote(NotePriority priority) {
    switch (priority) {
      case NotePriority.low:
        return NotificationPriority.low;
      case NotePriority.normal:
        return NotificationPriority.normal;
      case NotePriority.high:
        return NotificationPriority.high;
      case NotePriority.urgent:
        return NotificationPriority.max;
    }
  }
}

enum NotificationPriority {
  min,
  low,
  normal,
  high,
  max,
}
