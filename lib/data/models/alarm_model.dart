// lib/data/models/alarm_model.dart
class AlarmModel {
  final int id;
  final int hour;
  final int minute;
  final List<int> repeatDays; // 1-7 for Monday-Sunday
  final String label;
  final String sound;
  final double volume;
  final bool vibrate;
  final bool isEnabled;
  final String missionType; // 'math', 'photo', 'shake', 'memory', etc.
  final Map<String, dynamic> missionSettings;
  final bool gradualVolume;
  final int snoozeCount;
  final int snoozeDuration; // in minutes

  AlarmModel({
    required this.id,
    required this.hour,
    required this.minute,
    this.repeatDays = const [],
    this.label = '',
    this.sound = 'default_alarm',
    this.volume = 1.0,
    this.vibrate = true,
    this.isEnabled = true,
    this.missionType = 'none',
    this.missionSettings = const {},
    this.gradualVolume = false,
    this.snoozeCount = 3,
    this.snoozeDuration = 5,
  });

  // Create a copy with updated fields
  AlarmModel copyWith({
    int? id,
    int? hour,
    int? minute,
    List<int>? repeatDays,
    String? label,
    String? sound,
    double? volume,
    bool? vibrate,
    bool? isEnabled,
    String? missionType,
    Map<String, dynamic>? missionSettings,
    bool? gradualVolume,
    int? snoozeCount,
    int? snoozeDuration,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      repeatDays: repeatDays ?? this.repeatDays,
      label: label ?? this.label,
      sound: sound ?? this.sound,
      volume: volume ?? this.volume,
      vibrate: vibrate ?? this.vibrate,
      isEnabled: isEnabled ?? this.isEnabled,
      missionType: missionType ?? this.missionType,
      missionSettings: missionSettings ?? this.missionSettings,
      gradualVolume: gradualVolume ?? this.gradualVolume,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'repeatDays': repeatDays,
      'label': label,
      'sound': sound,
      'volume': volume,
      'vibrate': vibrate,
      'isEnabled': isEnabled,
      'missionType': missionType,
      'missionSettings': missionSettings,
      'gradualVolume': gradualVolume,
      'snoozeCount': snoozeCount,
      'snoozeDuration': snoozeDuration,
    };
  }

  // Create from JSON
  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'],
      hour: json['hour'],
      minute: json['minute'],
      repeatDays: List<int>.from(json['repeatDays'] ?? []),
      label: json['label'] ?? '',
      sound: json['sound'] ?? 'default_alarm',
      volume: json['volume'] ?? 1.0,
      vibrate: json['vibrate'] ?? true,
      isEnabled: json['isEnabled'] ?? true,
      missionType: json['missionType'] ?? 'none',
      missionSettings: json['missionSettings'] ?? {},
      gradualVolume: json['gradualVolume'] ?? false,
      snoozeCount: json['snoozeCount'] ?? 3,
      snoozeDuration: json['snoozeDuration'] ?? 5,
    );
  }

  // Get formatted time string (e.g., "08:30 AM")
  String get formattedTime {
    final isPM = hour >= 12;
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr ${isPM ? 'PM' : 'AM'}';
  }

  // Get repeat days as string (e.g., "Mon, Wed, Fri")
  String get repeatDaysText {
    if (repeatDays.isEmpty) return 'Once';
    if (repeatDays.length == 7) return 'Every day';
    if (repeatDays.length == 5 &&
        repeatDays.contains(1) &&
        repeatDays.contains(2) &&
        repeatDays.contains(3) &&
        repeatDays.contains(4) &&
        repeatDays.contains(5)) {
      return 'Weekdays';
    }
    if (repeatDays.length == 2 &&
        repeatDays.contains(6) &&
        repeatDays.contains(7)) {
      return 'Weekends';
    }

    final dayNames = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return repeatDays.map((day) => dayNames[day]).join(', ');
  }
}
