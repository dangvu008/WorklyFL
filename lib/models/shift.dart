import 'dart:convert';

enum ShiftType {
  day('Ngày', 'day'),
  night('Đêm', 'night'),
  swing('Xoay ca', 'swing');

  const ShiftType(this.displayName, this.value);
  final String displayName;
  final String value;

  static ShiftType fromString(String value) {
    return ShiftType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ShiftType.day,
    );
  }
}

class Shift {
  final String id;
  final String name;
  final ShiftType type;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;
  final bool requiresSignIn;
  final bool requiresSignOut;
  final double overtimeRate;
  final double nightShiftRate;
  final double sundayRate;
  final double holidayRate;
  final List<int> workDays; // 1-7 (Monday-Sunday)
  final DateTime createdAt;
  final DateTime? updatedAt;

  Shift({
    required this.id,
    required this.name,
    required this.type,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
    this.requiresSignIn = true,
    this.requiresSignOut = true,
    this.overtimeRate = 1.5,
    this.nightShiftRate = 1.3,
    this.sundayRate = 2.0,
    this.holidayRate = 2.5,
    this.workDays = const [1, 2, 3, 4, 5], // Monday to Friday
    required this.createdAt,
    this.updatedAt,
  });

  // Duration calculations
  Duration get duration {
    final start = DateTime(2000, 1, 1, startTime.hour, startTime.minute);
    var end = DateTime(2000, 1, 1, endTime.hour, endTime.minute);
    
    // Handle overnight shifts
    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }
    
    return end.difference(start);
  }

  bool get isNightShift {
    return type == ShiftType.night || 
           startTime.hour >= 22 || 
           endTime.hour <= 6;
  }

  bool get isOvernightShift {
    return endTime.hour < startTime.hour;
  }

  // Check if shift is active on a specific day
  bool isActiveOnDay(DateTime date) {
    if (!isActive) return false;
    return workDays.contains(date.weekday);
  }

  // Get formatted time strings
  String get startTimeString {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  String get endTimeString {
    return '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  String get timeRangeString {
    return '$startTimeString - $endTimeString';
  }

  // Calculate expected work hours for a date
  double calculateExpectedHours(DateTime date) {
    if (!isActiveOnDay(date)) return 0.0;
    return duration.inMinutes / 60.0;
  }

  // Calculate rates for different time periods
  double getHourlyRate(DateTime dateTime, double baseRate) {
    double rate = baseRate;
    
    // Night shift bonus
    if (isNightShift) {
      rate *= nightShiftRate;
    }
    
    // Sunday bonus
    if (dateTime.weekday == 7) {
      rate *= sundayRate;
    }
    
    // Holiday bonus (simplified - you can add holiday logic)
    // if (isHoliday(dateTime)) {
    //   rate *= holidayRate;
    // }
    
    return rate;
  }

  // Copy with modifications
  Shift copyWith({
    String? id,
    String? name,
    ShiftType? type,
    DateTime? startTime,
    DateTime? endTime,
    bool? isActive,
    bool? requiresSignIn,
    bool? requiresSignOut,
    double? overtimeRate,
    double? nightShiftRate,
    double? sundayRate,
    double? holidayRate,
    List<int>? workDays,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Shift(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      requiresSignIn: requiresSignIn ?? this.requiresSignIn,
      requiresSignOut: requiresSignOut ?? this.requiresSignOut,
      overtimeRate: overtimeRate ?? this.overtimeRate,
      nightShiftRate: nightShiftRate ?? this.nightShiftRate,
      sundayRate: sundayRate ?? this.sundayRate,
      holidayRate: holidayRate ?? this.holidayRate,
      workDays: workDays ?? this.workDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.value,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isActive': isActive,
      'requiresSignIn': requiresSignIn,
      'requiresSignOut': requiresSignOut,
      'overtimeRate': overtimeRate,
      'nightShiftRate': nightShiftRate,
      'sundayRate': sundayRate,
      'holidayRate': holidayRate,
      'workDays': workDays,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] as String,
      name: json['name'] as String,
      type: ShiftType.fromString(json['type'] as String),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      isActive: json['isActive'] as bool? ?? true,
      requiresSignIn: json['requiresSignIn'] as bool? ?? true,
      requiresSignOut: json['requiresSignOut'] as bool? ?? true,
      overtimeRate: (json['overtimeRate'] as num?)?.toDouble() ?? 1.5,
      nightShiftRate: (json['nightShiftRate'] as num?)?.toDouble() ?? 1.3,
      sundayRate: (json['sundayRate'] as num?)?.toDouble() ?? 2.0,
      holidayRate: (json['holidayRate'] as num?)?.toDouble() ?? 2.5,
      workDays: List<int>.from(json['workDays'] as List? ?? [1, 2, 3, 4, 5]),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Shift.fromJsonString(String jsonString) {
    return Shift.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'Shift(id: $id, name: $name, type: ${type.displayName}, time: $timeRangeString)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Shift && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
