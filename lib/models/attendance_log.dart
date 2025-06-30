import 'dart:convert';

enum AttendanceAction {
  goToWork('Đi Làm', 'go_to_work'),
  checkIn('Chấm Công Vào', 'check_in'),
  signWork('Ký Công', 'sign_work'),
  checkOut('Chấm Công Ra', 'check_out'),
  complete('Hoàn Tất', 'complete');

  const AttendanceAction(this.displayName, this.value);
  final String displayName;
  final String value;

  static AttendanceAction fromString(String value) {
    return AttendanceAction.values.firstWhere(
      (action) => action.value == value,
      orElse: () => AttendanceAction.goToWork,
    );
  }
}

enum AttendanceStatus {
  onTime('Đúng giờ', 'on_time'),
  late('Muộn', 'late'),
  early('Sớm', 'early'),
  overtime('Tăng ca', 'overtime'),
  absent('Vắng mặt', 'absent'),
  incomplete('Chưa hoàn thành', 'incomplete');

  const AttendanceStatus(this.displayName, this.value);
  final String displayName;
  final String value;

  static AttendanceStatus fromString(String value) {
    return AttendanceStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AttendanceStatus.incomplete,
    );
  }
}

class AttendanceLog {
  final String id;
  final String shiftId;
  final DateTime date;
  final AttendanceAction action;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final String? notes;
  final AttendanceStatus status;
  final Duration? deviation; // Difference from expected time
  final Map<String, dynamic>? metadata;

  AttendanceLog({
    required this.id,
    required this.shiftId,
    required this.date,
    required this.action,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.locationName,
    this.notes,
    this.status = AttendanceStatus.incomplete,
    this.deviation,
    this.metadata,
  });

  // Helper getters
  bool get hasLocation => latitude != null && longitude != null;
  
  String get timeString {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String get dateString {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String get deviationString {
    if (deviation == null) return '';
    
    final minutes = deviation!.inMinutes.abs();
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    String timeStr = '';
    if (hours > 0) {
      timeStr += '${hours}h';
    }
    if (remainingMinutes > 0) {
      timeStr += '${remainingMinutes}m';
    }
    
    if (deviation!.isNegative) {
      return 'Sớm $timeStr';
    } else {
      return 'Muộn $timeStr';
    }
  }

  // Calculate status based on expected time and deviation
  static AttendanceStatus calculateStatus(
    AttendanceAction action,
    Duration? deviation,
    {Duration lateThreshold = const Duration(minutes: 15)}
  ) {
    if (deviation == null) return AttendanceStatus.incomplete;
    
    switch (action) {
      case AttendanceAction.checkIn:
        if (deviation.inMinutes > lateThreshold.inMinutes) {
          return AttendanceStatus.late;
        } else if (deviation.inMinutes < -30) {
          return AttendanceStatus.early;
        } else {
          return AttendanceStatus.onTime;
        }
      
      case AttendanceAction.checkOut:
        if (deviation.inMinutes > 60) {
          return AttendanceStatus.overtime;
        } else if (deviation.inMinutes < -30) {
          return AttendanceStatus.early;
        } else {
          return AttendanceStatus.onTime;
        }
      
      default:
        return AttendanceStatus.onTime;
    }
  }

  // Copy with modifications
  AttendanceLog copyWith({
    String? id,
    String? shiftId,
    DateTime? date,
    AttendanceAction? action,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    String? locationName,
    String? notes,
    AttendanceStatus? status,
    Duration? deviation,
    Map<String, dynamic>? metadata,
  }) {
    return AttendanceLog(
      id: id ?? this.id,
      shiftId: shiftId ?? this.shiftId,
      date: date ?? this.date,
      action: action ?? this.action,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      deviation: deviation ?? this.deviation,
      metadata: metadata ?? this.metadata,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shiftId': shiftId,
      'date': date.toIso8601String(),
      'action': action.value,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'notes': notes,
      'status': status.value,
      'deviation': deviation?.inMilliseconds,
      'metadata': metadata,
    };
  }

  factory AttendanceLog.fromJson(Map<String, dynamic> json) {
    return AttendanceLog(
      id: json['id'] as String,
      shiftId: json['shiftId'] as String,
      date: DateTime.parse(json['date'] as String),
      action: AttendanceAction.fromString(json['action'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationName: json['locationName'] as String?,
      notes: json['notes'] as String?,
      status: AttendanceStatus.fromString(json['status'] as String? ?? 'incomplete'),
      deviation: json['deviation'] != null 
          ? Duration(milliseconds: json['deviation'] as int)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory AttendanceLog.fromJsonString(String jsonString) {
    return AttendanceLog.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'AttendanceLog(id: $id, action: ${action.displayName}, time: $timeString, status: ${status.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceLog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Daily work summary
class DailyWorkStatus {
  final DateTime date;
  final String? shiftId;
  final List<AttendanceLog> logs;
  final AttendanceStatus overallStatus;
  final Duration? totalWorkTime;
  final Duration? expectedWorkTime;
  final double? totalPay;
  final bool isComplete;

  DailyWorkStatus({
    required this.date,
    this.shiftId,
    required this.logs,
    required this.overallStatus,
    this.totalWorkTime,
    this.expectedWorkTime,
    this.totalPay,
    required this.isComplete,
  });

  // Helper getters
  AttendanceLog? get checkInLog {
    try {
      return logs.where((log) => log.action == AttendanceAction.checkIn).first;
    } catch (e) {
      return null;
    }
  }

  AttendanceLog? get checkOutLog {
    try {
      return logs.where((log) => log.action == AttendanceAction.checkOut).first;
    } catch (e) {
      return null;
    }
  }

  bool get hasCheckIn => checkInLog != null;
  bool get hasCheckOut => checkOutLog != null;

  String get statusDisplayName => overallStatus.displayName;

  String get workTimeString {
    if (totalWorkTime == null) return '--';
    
    final hours = totalWorkTime!.inHours;
    final minutes = totalWorkTime!.inMinutes % 60;
    return '${hours}h${minutes}m';
  }

  // Calculate work status from logs
  static DailyWorkStatus fromLogs(DateTime date, List<AttendanceLog> logs, {String? shiftId}) {
    final dayLogs = logs.where((log) => 
      log.date.year == date.year &&
      log.date.month == date.month &&
      log.date.day == date.day
    ).toList();

    dayLogs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate overall status
    AttendanceStatus overallStatus = AttendanceStatus.incomplete;
    Duration? totalWorkTime;
    bool isComplete = false;

    AttendanceLog? checkIn;
    AttendanceLog? checkOut;

    try {
      checkIn = dayLogs.where((log) => log.action == AttendanceAction.checkIn).first;
    } catch (e) {
      checkIn = null;
    }

    try {
      checkOut = dayLogs.where((log) => log.action == AttendanceAction.checkOut).first;
    } catch (e) {
      checkOut = null;
    }

    if (checkIn != null && checkOut != null) {
      totalWorkTime = checkOut.timestamp.difference(checkIn.timestamp);
      isComplete = true;
      
      // Determine overall status based on individual log statuses
      if (dayLogs.any((log) => log.status == AttendanceStatus.late)) {
        overallStatus = AttendanceStatus.late;
      } else if (dayLogs.any((log) => log.status == AttendanceStatus.overtime)) {
        overallStatus = AttendanceStatus.overtime;
      } else {
        overallStatus = AttendanceStatus.onTime;
      }
    } else if (checkIn != null) {
      overallStatus = AttendanceStatus.incomplete;
    } else if (dayLogs.isEmpty) {
      overallStatus = AttendanceStatus.absent;
    }

    return DailyWorkStatus(
      date: date,
      shiftId: shiftId,
      logs: dayLogs,
      overallStatus: overallStatus,
      totalWorkTime: totalWorkTime,
      isComplete: isComplete,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'shiftId': shiftId,
      'logs': logs.map((log) => log.toJson()).toList(),
      'overallStatus': overallStatus.value,
      'totalWorkTime': totalWorkTime?.inMilliseconds,
      'expectedWorkTime': expectedWorkTime?.inMilliseconds,
      'totalPay': totalPay,
      'isComplete': isComplete,
    };
  }

  factory DailyWorkStatus.fromJson(Map<String, dynamic> json) {
    return DailyWorkStatus(
      date: DateTime.parse(json['date'] as String),
      shiftId: json['shiftId'] as String?,
      logs: (json['logs'] as List).map((logJson) => AttendanceLog.fromJson(logJson)).toList(),
      overallStatus: AttendanceStatus.fromString(json['overallStatus'] as String),
      totalWorkTime: json['totalWorkTime'] != null 
          ? Duration(milliseconds: json['totalWorkTime'] as int)
          : null,
      expectedWorkTime: json['expectedWorkTime'] != null 
          ? Duration(milliseconds: json['expectedWorkTime'] as int)
          : null,
      totalPay: (json['totalPay'] as num?)?.toDouble(),
      isComplete: json['isComplete'] as bool,
    );
  }
}
