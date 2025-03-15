// lib/features/alarm/screens/create_alarm_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_a/data/models/alarm_model.dart';
import 'package:project_a/features/alarm/providers/alarm_provider.dart';
import 'package:project_a/features/alarm/screens/mission_selection_screen.dart';
import 'package:project_a/features/alarm/screens/sound_selection_screen.dart';

class CreateAlarmScreen extends ConsumerStatefulWidget {
  final AlarmModel? alarm;

  const CreateAlarmScreen({Key? key, this.alarm}) : super(key: key);

  @override
  _CreateAlarmScreenState createState() => _CreateAlarmScreenState();
}

class _CreateAlarmScreenState extends ConsumerState<CreateAlarmScreen> {
  late TimeOfDay _selectedTime;
  late List<int> _selectedDays;
  late TextEditingController _labelController;
  late String _selectedSound;
  late double _volume;
  late bool _vibrate;
  late String _missionType;
  late Map<String, dynamic> _missionSettings;
  late bool _gradualVolume;
  late int _snoozeCount;
  late int _snoozeDuration;

  @override
  void initState() {
    super.initState();

    // Initialize with existing alarm data or defaults
    if (widget.alarm != null) {
      _selectedTime = TimeOfDay(
        hour: widget.alarm!.hour,
        minute: widget.alarm!.minute,
      );
      _selectedDays = List.from(widget.alarm!.repeatDays);
      _labelController = TextEditingController(text: widget.alarm!.label);
      _selectedSound = widget.alarm!.sound;
      _volume = widget.alarm!.volume;
      _vibrate = widget.alarm!.vibrate;
      _missionType = widget.alarm!.missionType;
      _missionSettings = Map.from(widget.alarm!.missionSettings);
      _gradualVolume = widget.alarm!.gradualVolume;
      _snoozeCount = widget.alarm!.snoozeCount;
      _snoozeDuration = widget.alarm!.snoozeDuration;
    } else {
      // Default values for new alarm
      final now = TimeOfDay.now();
      _selectedTime = TimeOfDay(
        hour: now.hour,
        minute: (now.minute ~/ 5 + 1) * 5 % 60, // Round to next 5 minutes
      );
      if (_selectedTime.minute == 0) {
        _selectedTime = TimeOfDay(
          hour: (_selectedTime.hour + 1) % 24,
          minute: 0,
        );
      }
      _selectedDays = [];
      _labelController = TextEditingController();
      _selectedSound = 'default_alarm';
      _volume = 1.0;
      _vibrate = true;
      _missionType = 'none';
      _missionSettings = {};
      _gradualVolume = false;
      _snoozeCount = 3;
      _snoozeDuration = 5;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _saveAlarm() {
    final alarmId = widget.alarm?.id ?? DateTime.now().millisecondsSinceEpoch;

    final alarm = AlarmModel(
      id: alarmId,
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
      repeatDays: _selectedDays,
      label: _labelController.text,
      sound: _selectedSound,
      volume: _volume,
      vibrate: _vibrate,
      isEnabled: true,
      missionType: _missionType,
      missionSettings: _missionSettings,
      gradualVolume: _gradualVolume,
      snoozeCount: _snoozeCount,
      snoozeDuration: _snoozeDuration,
    );

    if (widget.alarm == null) {
      ref.read(alarmsProvider.notifier).addAlarm(alarm);
    } else {
      ref.read(alarmsProvider.notifier).updateAlarm(alarm);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm == null ? 'Add Alarm' : 'Edit Alarm'),
        actions: [TextButton(onPressed: _saveAlarm, child: Text('Save'))],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time picker card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                          builder: (context, child) {
                            return Theme(
                              data:
                                  isDarkMode
                                      ? ThemeData.dark().copyWith(
                                        colorScheme: ColorScheme.dark(
                                          primary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          onPrimary: Colors.white,
                                          surface:
                                              Theme.of(
                                                context,
                                              ).colorScheme.surface,
                                          onSurface: Colors.white,
                                        ),
                                      )
                                      : ThemeData.light().copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        ),
                                      ),
                              child: child!,
                            );
                          },
                        );

                        if (pickedTime != null) {
                          setState(() {
                            _selectedTime = pickedTime;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            '${_selectedTime.hour == 0
                                ? 12
                                : _selectedTime.hour > 12
                                ? _selectedTime.hour - 12
                                : _selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.hour >= 12 ? 'PM' : 'AM'}',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    // Repeat days selector
                    Text(
                      'Repeat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildDayButton(1, 'M'),
                        _buildDayButton(2, 'T'),
                        _buildDayButton(3, 'W'),
                        _buildDayButton(4, 'T'),
                        _buildDayButton(5, 'F'),
                        _buildDayButton(6, 'S'),
                        _buildDayButton(7, 'S'),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Quick repeat options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickRepeatChip('Weekdays', [1, 2, 3, 4, 5]),
                        _buildQuickRepeatChip('Weekends', [6, 7]),
                        _buildQuickRepeatChip('Every day', [
                          1,
                          2,
                          3,
                          4,
                          5,
                          6,
                          7,
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Alarm options card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label field
                    TextField(
                      controller: _labelController,
                      decoration: InputDecoration(
                        labelText: 'Label',
                        hintText: 'e.g., Work, Gym, etc.',
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Sound selection
                    ListTile(
                      leading: Icon(Icons.music_note),
                      title: Text('Sound'),
                      subtitle: Text(_getReadableSoundName(_selectedSound)),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => SoundSelectionScreen(
                                  selectedSound: _selectedSound,
                                ),
                          ),
                        );

                        if (result != null) {
                          setState(() {
                            _selectedSound = result;
                          });
                        }
                      },
                    ),
                    // Volume slider
                    ListTile(
                      leading: Icon(
                        _volume == 0
                            ? Icons.volume_off
                            : _volume < 0.5
                            ? Icons.volume_down
                            : Icons.volume_up,
                      ),
                      title: Text('Volume'),
                      subtitle: Slider(
                        value: _volume,
                        onChanged: (value) {
                          setState(() {
                            _volume = value;
                          });
                        },
                        divisions: 10,
                      ),
                    ),
                    // Vibration toggle
                    SwitchListTile(
                      title: Text('Vibrate'),
                      value: _vibrate,
                      onChanged: (value) {
                        setState(() {
                          _vibrate = value;
                        });
                      },
                    ),
                    // Gradual volume toggle
                    SwitchListTile(
                      title: Text('Gradual Volume Increase'),
                      subtitle: Text('Starts quiet and gets louder'),
                      value: _gradualVolume,
                      onChanged: (value) {
                        setState(() {
                          _gradualVolume = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Mission card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wake Up Mission',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Complete a mission to turn off the alarm',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(_getMissionTypeIcon(_missionType)),
                      title: Text(_getMissionTypeText(_missionType)),
                      subtitle:
                          _missionType == 'none'
                              ? Text('No mission selected')
                              : Text(
                                _getMissionDescription(
                                  _missionType,
                                  _missionSettings,
                                ),
                              ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => MissionSelectionScreen(
                                  selectedMission: _missionType,
                                  missionSettings: _missionSettings,
                                ),
                          ),
                        );

                        if (result != null) {
                          setState(() {
                            _missionType = result['type'];
                            _missionSettings = result['settings'];
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Snooze options card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Snooze Options',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    // Snooze count
                    Row(
                      children: [
                        Text('Snooze Count:'),
                        Spacer(),
                        DropdownButton<int>(
                          value: _snoozeCount,
                          items:
                              [0, 1, 2, 3, 5, 10]
                                  .map(
                                    (count) => DropdownMenuItem<int>(
                                      value: count,
                                      child: Text(
                                        count == 0
                                            ? 'No snooze'
                                            : count.toString(),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _snoozeCount = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Snooze duration
                    Row(
                      children: [
                        Text('Snooze Duration:'),
                        Spacer(),
                        DropdownButton<int>(
                          value: _snoozeDuration,
                          items:
                              [1, 3, 5, 10, 15, 20]
                                  .map(
                                    (duration) => DropdownMenuItem<int>(
                                      value: duration,
                                      child: Text('$duration minutes'),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _snoozeDuration = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDayButton(int day, String label) {
    final isSelected = _selectedDays.contains(day);

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedDays.remove(day);
          } else {
            _selectedDays.add(day);
          }
        });
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade400,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickRepeatChip(String label, List<int> days) {
    final isSelected =
        _selectedDays.length == days.length &&
        days.every((day) => _selectedDays.contains(day));

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedDays = List.from(days);
          } else {
            _selectedDays = [];
          }
        });
      },
    );
  }

  String _getReadableSoundName(String soundId) {
    switch (soundId) {
      case 'default_alarm':
        return 'Default Alarm';
      case 'gentle_chime':
        return 'Gentle Chime';
      case 'morning_birds':
        return 'Morning Birds';
      case 'energetic_beats':
        return 'Energetic Beats';
      default:
        return soundId.replaceAll('_', ' ').capitalize();
    }
  }

  IconData _getMissionTypeIcon(String missionType) {
    switch (missionType) {
      case 'math':
        return Icons.calculate;
      case 'photo':
        return Icons.camera_alt;
      case 'shake':
        return Icons.vibration;
      case 'memory':
        return Icons.grid_view;
      case 'barcode':
        return Icons.qr_code;
      case 'steps':
        return Icons.directions_walk;
      default:
        return Icons.alarm_off;
    }
  }

  String _getMissionTypeText(String missionType) {
    switch (missionType) {
      case 'math':
        return 'Math Problem';
      case 'photo':
        return 'Photo Mission';
      case 'shake':
        return 'Shake Mission';
      case 'memory':
        return 'Memory Game';
      case 'barcode':
        return 'Scan Barcode';
      case 'steps':
        return 'Step Counter';
      case 'none':
        return 'No Mission';
      default:
        return 'Unknown Mission';
    }
  }

  String _getMissionDescription(
    String missionType,
    Map<String, dynamic> settings,
  ) {
    switch (missionType) {
      case 'math':
        final difficulty = settings['difficulty'] ?? 'medium';
        final count = settings['count'] ?? 3;
        return '$count ${difficulty.capitalize()} math problems';
      case 'photo':
        return 'Take a photo of ${settings['description'] ?? 'a specific location'}';
      case 'shake':
        final count = settings['count'] ?? 30;
        return 'Shake your phone $count times';
      case 'memory':
        final pairs = settings['pairs'] ?? 6;
        return 'Match $pairs pairs of cards';
      case 'barcode':
        return 'Scan ${settings['description'] ?? 'a barcode'}';
      case 'steps':
        final count = settings['count'] ?? 20;
        return 'Take $count steps';
      default:
        return '';
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
