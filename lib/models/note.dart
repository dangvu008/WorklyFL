import 'dart:convert';

enum NotePriority {
  low('Thấp', 'low', 1),
  normal('Bình thường', 'normal', 2),
  high('Cao', 'high', 3),
  urgent('Khẩn cấp', 'urgent', 4);

  const NotePriority(this.displayName, this.value, this.level);
  final String displayName;
  final String value;
  final int level;

  static NotePriority fromString(String value) {
    return NotePriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => NotePriority.normal,
    );
  }

  static NotePriority fromLevel(int level) {
    return NotePriority.values.firstWhere(
      (priority) => priority.level == level,
      orElse: () => NotePriority.normal,
    );
  }
}

enum NoteType {
  general('Ghi chú chung', 'general'),
  workReminder('Nhắc nhở công việc', 'work_reminder'),
  shiftNote('Ghi chú ca làm', 'shift_note'),
  weatherAlert('Cảnh báo thời tiết', 'weather_alert'),
  personalReminder('Nhắc nhở cá nhân', 'personal_reminder');

  const NoteType(this.displayName, this.value);
  final String displayName;
  final String value;

  static NoteType fromString(String value) {
    return NoteType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NoteType.general,
    );
  }
}

class NoteReminder {
  final DateTime dateTime;
  final bool isRepeating;
  final Duration? repeatInterval;
  final List<int>? repeatDays; // 1-7 for Monday-Sunday
  final bool isActive;
  final int notificationId;

  NoteReminder({
    required this.dateTime,
    this.isRepeating = false,
    this.repeatInterval,
    this.repeatDays,
    this.isActive = true,
    required this.notificationId,
  });

  bool get isPastDue {
    if (isRepeating) return false;
    return DateTime.now().isAfter(dateTime);
  }

  DateTime? get nextReminderTime {
    if (!isActive) return null;
    
    final now = DateTime.now();
    
    if (!isRepeating) {
      return dateTime.isAfter(now) ? dateTime : null;
    }
    
    if (repeatDays != null && repeatDays!.isNotEmpty) {
      // Weekly repeat on specific days
      var nextDate = DateTime(now.year, now.month, now.day, dateTime.hour, dateTime.minute);
      
      for (int i = 0; i < 7; i++) {
        final checkDate = nextDate.add(Duration(days: i));
        if (repeatDays!.contains(checkDate.weekday) && checkDate.isAfter(now)) {
          return checkDate;
        }
      }
      
      // If no day found this week, check next week
      for (int i = 7; i < 14; i++) {
        final checkDate = nextDate.add(Duration(days: i));
        if (repeatDays!.contains(checkDate.weekday)) {
          return checkDate;
        }
      }
    }
    
    if (repeatInterval != null) {
      // Interval-based repeat
      var nextTime = dateTime;
      while (nextTime.isBefore(now)) {
        nextTime = nextTime.add(repeatInterval!);
      }
      return nextTime;
    }
    
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'isRepeating': isRepeating,
      'repeatInterval': repeatInterval?.inMilliseconds,
      'repeatDays': repeatDays,
      'isActive': isActive,
      'notificationId': notificationId,
    };
  }

  factory NoteReminder.fromJson(Map<String, dynamic> json) {
    return NoteReminder(
      dateTime: DateTime.parse(json['dateTime'] as String),
      isRepeating: json['isRepeating'] as bool? ?? false,
      repeatInterval: json['repeatInterval'] != null 
          ? Duration(milliseconds: json['repeatInterval'] as int)
          : null,
      repeatDays: json['repeatDays'] != null 
          ? List<int>.from(json['repeatDays'] as List)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      notificationId: json['notificationId'] as int,
    );
  }
}

class Note {
  final String id;
  final String title;
  final String content;
  final NoteType type;
  final NotePriority priority;
  final List<String> tags;
  final NoteReminder? reminder;
  final String? shiftId; // Associated shift if any
  final DateTime? workDate; // Associated work date if any
  final bool isCompleted;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.type = NoteType.general,
    this.priority = NotePriority.normal,
    this.tags = const [],
    this.reminder,
    this.shiftId,
    this.workDate,
    this.isCompleted = false,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  // Helper getters
  bool get hasReminder => reminder != null;
  bool get hasActiveReminder => reminder?.isActive == true;
  bool get isOverdue => reminder?.isPastDue == true && !isCompleted;
  
  String get priorityEmoji {
    switch (priority) {
      case NotePriority.low:
        return '🔵';
      case NotePriority.normal:
        return '⚪';
      case NotePriority.high:
        return '🟡';
      case NotePriority.urgent:
        return '🔴';
    }
  }

  String get typeEmoji {
    switch (type) {
      case NoteType.general:
        return '📝';
      case NoteType.workReminder:
        return '💼';
      case NoteType.shiftNote:
        return '⏰';
      case NoteType.weatherAlert:
        return '🌤️';
      case NoteType.personalReminder:
        return '👤';
    }
  }

  String get displayTitle {
    return isPinned ? '📌 $title' : title;
  }

  String get shortContent {
    if (content.length <= 100) return content;
    return '${content.substring(0, 97)}...';
  }

  // Check if note matches search query
  bool matchesSearch(String query) {
    if (query.isEmpty) return true;
    
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
           content.toLowerCase().contains(lowerQuery) ||
           tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
  }

  // Check if note matches filters
  bool matchesFilters({
    NoteType? typeFilter,
    NotePriority? priorityFilter,
    bool? completedFilter,
    bool? hasReminderFilter,
    String? shiftIdFilter,
  }) {
    if (typeFilter != null && type != typeFilter) return false;
    if (priorityFilter != null && priority != priorityFilter) return false;
    if (completedFilter != null && isCompleted != completedFilter) return false;
    if (hasReminderFilter != null && hasReminder != hasReminderFilter) return false;
    if (shiftIdFilter != null && shiftId != shiftIdFilter) return false;
    
    return true;
  }

  // Copy with modifications
  Note copyWith({
    String? id,
    String? title,
    String? content,
    NoteType? type,
    NotePriority? priority,
    List<String>? tags,
    NoteReminder? reminder,
    String? shiftId,
    DateTime? workDate,
    bool? isCompleted,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      reminder: reminder ?? this.reminder,
      shiftId: shiftId ?? this.shiftId,
      workDate: workDate ?? this.workDate,
      isCompleted: isCompleted ?? this.isCompleted,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      metadata: metadata ?? this.metadata,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type.value,
      'priority': priority.value,
      'tags': tags,
      'reminder': reminder?.toJson(),
      'shiftId': shiftId,
      'workDate': workDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'isPinned': isPinned,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: NoteType.fromString(json['type'] as String? ?? 'general'),
      priority: NotePriority.fromString(json['priority'] as String? ?? 'normal'),
      tags: List<String>.from(json['tags'] as List? ?? []),
      reminder: json['reminder'] != null 
          ? NoteReminder.fromJson(json['reminder'] as Map<String, dynamic>)
          : null,
      shiftId: json['shiftId'] as String?,
      workDate: json['workDate'] != null 
          ? DateTime.parse(json['workDate'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Note.fromJsonString(String jsonString) {
    return Note.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'Note(id: $id, title: $title, type: ${type.displayName}, priority: ${priority.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
