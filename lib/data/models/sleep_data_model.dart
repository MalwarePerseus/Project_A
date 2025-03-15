// lib/data/models/sleep_data_model.dart
class SleepData {
  final String id;
  final DateTime bedtime;
  final DateTime wakeTime;
  final int sleepDuration; // in minutes
  final Map<String, int>
  sleepStages; // 'deep', 'light', 'rem', 'awake' in minutes
  final List<SnoringEpisode> snoringEpisodes;
  final int sleepScore; // 0-100
  final Map<String, dynamic> environmentData; // 'temperature', 'noise', etc.
  final String notes;

  SleepData({
    required this.id,
    required this.bedtime,
    required this.wakeTime,
    required this.sleepDuration,
    required this.sleepStages,
    this.snoringEpisodes = const [],
    required this.sleepScore,
    this.environmentData = const {},
    this.notes = '',
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bedtime': bedtime.toIso8601String(),
      'wakeTime': wakeTime.toIso8601String(),
      'sleepDuration': sleepDuration,
      'sleepStages': sleepStages,
      'snoringEpisodes': snoringEpisodes.map((e) => e.toJson()).toList(),
      'sleepScore': sleepScore,
      'environmentData': environmentData,
      'notes': notes,
    };
  }

  // Create from JSON
  factory SleepData.fromJson(Map<String, dynamic> json) {
    return SleepData(
      id: json['id'],
      bedtime: DateTime.parse(json['bedtime']),
      wakeTime: DateTime.parse(json['wakeTime']),
      sleepDuration: json['sleepDuration'],
      sleepStages: Map<String, int>.from(json['sleepStages']),
      snoringEpisodes:
          (json['snoringEpisodes'] as List)
              .map((e) => SnoringEpisode.fromJson(e))
              .toList(),
      sleepScore: json['sleepScore'],
      environmentData: json['environmentData'] ?? {},
      notes: json['notes'] ?? '',
    );
  }
}

class SnoringEpisode {
  final DateTime startTime;
  final int duration; // in seconds
  final int intensity; // 1-10

  SnoringEpisode({
    required this.startTime,
    required this.duration,
    required this.intensity,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'duration': duration,
      'intensity': intensity,
    };
  }

  // Create from JSON
  factory SnoringEpisode.fromJson(Map<String, dynamic> json) {
    return SnoringEpisode(
      startTime: DateTime.parse(json['startTime']),
      duration: json['duration'],
      intensity: json['intensity'],
    );
  }
}
