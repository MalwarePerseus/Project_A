// lib/features/alarm/screens/alarm_ringing_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_a/data/models/alarm_model.dart';
import 'package:project_a/features/missions/screens/mission_factory.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class AlarmRingingScreen extends ConsumerStatefulWidget {
  final AlarmModel alarm;

  const AlarmRingingScreen({Key? key, required this.alarm}) : super(key: key);

  @override
  _AlarmRingingScreenState createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends ConsumerState<AlarmRingingScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _animationController;
  int _snoozeCount = 0;
  Timer? _volumeIncreaseTimer;
  double _currentVolume = 0.3;

  @override
  void initState() {
    super.initState();

    // Initialize animation
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Play alarm sound
    _playAlarmSound();

    // Start vibration if enabled
    if (widget.alarm.vibrate) {
      // In a real app, you would implement vibration here
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    _volumeIncreaseTimer?.cancel();
    super.dispose();
  }

  Future<void> _playAlarmSound() async {
    // In a real app, you would load the actual sound file
    await _audioPlayer.play(AssetSource('sounds/${widget.alarm.sound}.mp3'));
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);

    // Set initial volume
    await _audioPlayer.setVolume(_currentVolume);

    // If gradual volume increase is enabled
    if (widget.alarm.gradualVolume) {
      _volumeIncreaseTimer = Timer.periodic(Duration(seconds: 5), (timer) {
        if (_currentVolume < widget.alarm.volume) {
          _currentVolume = min(_currentVolume + 0.1, widget.alarm.volume);
          _audioPlayer.setVolume(_currentVolume);
        } else {
          _volumeIncreaseTimer?.cancel();
        }
      });
    } else {
      await _audioPlayer.setVolume(widget.alarm.volume);
    }
  }

  void _stopAlarm() {
    _audioPlayer.stop();
    // In a real app, you would stop vibration here
  }

  void _onSnooze() {
    if (_snoozeCount < widget.alarm.snoozeCount) {
      _stopAlarm();

      setState(() {
        _snoozeCount++;
      });

      // Show snooze confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Alarm snoozed for ${widget.alarm.snoozeDuration} minutes',
          ),
        ),
      );

      // Navigate back
      Navigator.pop(context);

      // In a real app, you would reschedule the alarm for snooze
    } else {
      // No more snoozes allowed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No more snoozes available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onDismiss() {
    _stopAlarm();

    if (widget.alarm.missionType != 'none') {
      // Show mission screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => MissionFactory.createMissionScreen(
                missionType: widget.alarm.missionType,
                missionSettings: widget.alarm.missionSettings,
                onMissionComplete: () {
                  // Navigate back to home when mission is complete
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
        ),
      );
    } else {
      // No mission, just go back to home
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade300, Colors.deepOrange.shade700],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top section with time and label
              Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      timeString,
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.alarm.label.isNotEmpty
                          ? widget.alarm.label
                          : 'Wake Up!',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Middle section with animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_animationController.value * 0.2),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      child: Icon(Icons.alarm, size: 100, color: Colors.white),
                    ),
                  );
                },
              ),

              // Bottom section with buttons
              Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Dismiss button
                    ElevatedButton(
                      onPressed: _onDismiss,
                      child: Text('Dismiss'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepOrange,
                        minimumSize: Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Snooze button
                    if (_snoozeCount < widget.alarm.snoozeCount)
                      OutlinedButton(
                        onPressed: _onSnooze,
                        child: Text(
                          'Snooze (${widget.alarm.snoozeCount - _snoozeCount} left)',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white),
                          minimumSize: Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double min(double a, double b) {
    return a < b ? a : b;
  }
}
